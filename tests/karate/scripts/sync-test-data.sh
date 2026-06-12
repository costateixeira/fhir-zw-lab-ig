#!/usr/bin/env bash
# Derives the Karate test payloads in data/ from the IG's own generated
# examples (fsh-generated/resources/), so test data cannot drift from the spec.
# Run after `sushi .` (or a full IG build) from anywhere:
#   tests/karate/scripts/sync-test-data.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="../../fsh-generated/resources"
if [ ! -d "$SRC" ]; then
  echo "ERROR: $SRC not found — run 'sushi .' in the repo root first" >&2
  exit 1
fi
mkdir -p data

python3 - "$SRC" <<'PY'
import copy
import json
import os
import sys
from urllib.parse import quote

src = sys.argv[1]

def load(name):
    with open(os.path.join(src, name)) as f:
        return json.load(f)

def save(name, obj):
    with open(os.path.join('data', name), 'w') as f:
        json.dump(obj, f, indent=2)
        f.write('\n')

# ── Order transaction bundle (Lab Order Placer payload) ──────────────────────
order = load('Bundle-example-zw-lab-order-bundle.json')
order.pop('id', None)

# The Task/ServiceRequest reference the ordering facility (Location) and the
# receiving laboratory (Organization), which won't exist on a fresh server.
# Append them as conditional-create entries so the transaction is
# self-contained and idempotent for shared context resources.
facility = load('Location-example-order-facility.json')
laboratory = load('Organization-example-national-virology-lab.json')
lab_code = laboratory['identifier'][0]
order['entry'].append({
    'fullUrl': 'urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0005',
    'resource': facility,
    'request': {
        'method': 'POST',
        'url': 'Location',
        'ifNoneExist': 'name=' + quote(facility['name']),
    },
})
order['entry'].append({
    'fullUrl': 'urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0006',
    'resource': laboratory,
    'request': {
        'method': 'POST',
        'url': 'Organization',
        'ifNoneExist': 'identifier=' + quote(lab_code['system'] + '|' + lab_code['value'], safe=''),
    },
})

# Rewrite intra-bundle relative references to the entry fullUrls (urn:uuid) so
# the server rewires them to the created resources when processing the
# transaction.
refmap = {}
for e in order.get('entry', []):
    r = e.get('resource', {})
    if r.get('id'):
        refmap[r['resourceType'] + '/' + r['id']] = e['fullUrl']

def rewrite(node):
    if isinstance(node, dict):
        if node.get('reference') in refmap:
            node['reference'] = refmap[node['reference']]
        for v in node.values():
            rewrite(v)
    elif isinstance(node, list):
        for v in node:
            rewrite(v)

for e in order['entry']:
    rewrite(e['resource'])
    e['resource'].pop('id', None)   # POST entries get server-assigned ids
    e['resource'].pop('text', None)
save('order-bundle.json', order)

# Invalid variant: ServiceRequest without a test code, Patient without the
# required EHR identifier — must fail ZWLabOrderBundle profile validation.
bad = copy.deepcopy(order)
for e in bad['entry']:
    r = e['resource']
    if r['resourceType'] == 'ServiceRequest':
        r.pop('code', None)
    if r['resourceType'] == 'Patient':
        r.pop('identifier', None)
        e['request'].pop('ifNoneExist', None)
save('order-bundle-invalid.json', bad)

# Offline sandboxes cannot validate LOINC (HAPI only accepts LOINC via its
# terminology uploader), and an unknown code system inside a bound
# CodeableConcept fails validation. The wire payloads therefore carry only the
# national codes — which is what the profiles require. The IG examples keep
# the LOINC translations; validating them is deferred to a
# terminology-capable validator.
def strip_loinc_codings(node):
    if isinstance(node, dict):
        for key in ('code',):
            cc = node.get(key)
            if isinstance(cc, dict) and isinstance(cc.get('coding'), list):
                kept = [c for c in cc['coding'] if c.get('system') != 'http://loinc.org']
                if kept:
                    cc['coding'] = kept
        for v in node.values():
            strip_loinc_codings(v)
    elif isinstance(node, list):
        for v in node:
            strip_loinc_codings(v)

# ── Report document bundle (Lab Result Provider payload, stored whole) ───────
report = load('Bundle-example-zw-vl-report-bundle.json')
report.pop('id', None)
for e in report.get('entry', []):
    if e.get('resource', {}).get('resourceType') in ('Observation', 'DiagnosticReport'):
        strip_loinc_codings(e['resource'])
save('report-bundle.json', report)

# Invalid variant: DiagnosticReport without a test code, Patient without the
# required EHR identifier — must fail ZWLabReportBundle profile validation.
bad_report = copy.deepcopy(report)
for e in bad_report['entry']:
    r = e['resource']
    if r['resourceType'] == 'DiagnosticReport':
        r.pop('code', None)
    if r['resourceType'] == 'Patient':
        r.pop('identifier', None)
save('report-bundle-invalid.json', bad_report)

# ── Standalone result resources (provider creates these against live ids) ────
obs = load('Observation-example-zw-vl-observation.json')
for k in ('id', 'text', 'subject', 'basedOn', 'specimen'):
    obs.pop(k, None)
strip_loinc_codings(obs)
save('observation.json', obs)

dr = load('DiagnosticReport-example-zw-vl-diagnostic-report.json')
for k in ('id', 'text', 'subject', 'basedOn', 'specimen', 'result',
          'performer', 'resultsInterpreter'):
    dr.pop(k, None)
save('diagnostic-report.json', dr)

# ── Static search parameter files ─────────────────────────────────────────────
save('order-search-none.json', {
    'patient.identifier':
        'http://mohcc.gov.zw/fhir/lab/identifier/ehr-patient-id|NO-SUCH-PATIENT'
})

print('Test payloads written to tests/karate/data/')
PY
