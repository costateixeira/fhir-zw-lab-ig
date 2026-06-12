#!/usr/bin/env bash
# Generates simulator/ehr-simulator.html — a zero-dependency page (open it
# straight from disk in any browser) that plays the EHR: pick a payload, click
# Submit, and it POSTs to the conformance proxy / server you point it at.
# Payloads are embedded from tests/karate/data/ so the page works from file://.
# Re-run after changing the data files.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p simulator

python3 - <<'PY'
import json

def load(p):
    with open(p) as f:
        return json.dumps(json.load(f), indent=2)

payloads = {
    'valid': load('data/order-bundle.json'),
    'invalid': load('data/order-bundle-invalid.json'),
    'impilo': load('data/impilo-order-sample.json'),
}

html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>ZW Lab — EHR Simulator</title>
<style>
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, Segoe UI, Helvetica, Arial, sans-serif; max-width: 1000px;
         margin: 24px auto; padding: 0 16px; line-height: 1.45; }
  h1 { font-size: 20px; } h1 small { font-weight: normal; color: #777; font-size: 13px; }
  fieldset { border: 1px solid #bbb4; border-radius: 8px; margin-bottom: 14px; padding: 10px 14px; }
  legend { font-size: 12px; color: #888; padding: 0 6px; }
  label { font-size: 13px; margin-right: 14px; }
  input[type=text] { width: 320px; font-family: ui-monospace, monospace; font-size: 13px; padding: 4px 6px; }
  select { font-size: 13px; padding: 3px; }
  textarea { width: 100%; height: 260px; font-family: ui-monospace, monospace; font-size: 12px;
             border: 1px solid #bbb4; border-radius: 6px; padding: 8px; box-sizing: border-box; }
  button { font-size: 14px; padding: 7px 16px; border-radius: 6px; border: 1px solid #888a;
           cursor: pointer; margin-right: 8px; background: transparent; }
  button.primary { background: #1f6feb; color: white; border-color: #1f6feb; }
  #verdict { font-size: 14px; font-weight: 600; margin: 12px 0 6px; }
  #verdict.pass { color: #1a7f37; } #verdict.fail { color: #cf222e; } #verdict.info { color: #777; }
  pre#out { border: 1px solid #bbb4; border-radius: 6px; padding: 10px; font-size: 11.5px;
            max-height: 420px; overflow: auto; white-space: pre-wrap; }
</style>
</head>
<body>
<h1>ZW Lab — EHR Simulator <small>plays the Lab Order Placer / Result Consumer</small></h1>

<fieldset>
  <legend>where to send</legend>
  <label>Proxy / server base <input type="text" id="base" value="http://localhost:8080"/></label>
  <label><input type="checkbox" id="fresh" checked/> fresh patient &amp; sample identifiers per submit</label>
</fieldset>

<fieldset>
  <legend>payload</legend>
  <label>Choose:
    <select id="pick" onchange="pickPayload()">
      <option value="valid">Valid order bundle (from the IG example)</option>
      <option value="invalid">Invalid order bundle (missing code + identifier)</option>
      <option value="impilo">Real Impilo order sample</option>
      <option value="custom">Custom (paste your own)</option>
    </select>
  </label>
  <textarea id="payload" spellcheck="false"></textarea>
</fieldset>

<div>
  <button class="primary" onclick="submitOrder()">Submit order (POST bundle)</button>
  <button onclick="pullScoped()">Pull results (patient-scoped)</button>
  <button onclick="pullUnscoped()">Pull results (unscoped — should be refused)</button>
</div>

<div id="verdict" class="info">no request sent yet</div>
<pre id="out"></pre>

<script>
const PAYLOADS = {
  valid: __VALID__,
  invalid: __INVALID__,
  impilo: __IMPILO__
};

function pickPayload() {
  const k = document.getElementById('pick').value;
  if (k !== 'custom') document.getElementById('payload').value = JSON.stringify(PAYLOADS[k], null, 2);
}
pickPayload();

function base() { return document.getElementById('base').value.replace(/\\/+$/, ''); }

function freshen(text) {
  if (!document.getElementById('fresh').checked) return text;
  const ts = Date.now();
  return text
    .replaceAll('EHR-ZW-00123', 'EHR-SIM-' + ts)
    .replaceAll('ZW-SPEC-2024-00456', 'SPEC-SIM-' + ts);
}

function show(kind, headline, body) {
  const v = document.getElementById('verdict');
  v.className = kind; v.textContent = headline;
  document.getElementById('out').textContent = body;
}

async function send(method, url, bodyText) {
  show('info', '… sending ' + method + ' ' + url, '');
  try {
    const res = await fetch(url, {
      method,
      headers: bodyText ? { 'Content-Type': 'application/fhir+json' } : { 'Accept': 'application/fhir+json' },
      body: bodyText || undefined
    });
    const verdict = res.headers.get('X-ZW-Validation');
    const text = await res.text();
    let pretty = text;
    try { pretty = JSON.stringify(JSON.parse(text), null, 2); } catch (e) {}
    const ok = res.ok && (!verdict || verdict.startsWith('0 '));
    const head = 'HTTP ' + res.status + (verdict ? '   ·   conformance: ' + verdict : '');
    show(ok ? 'pass' : 'fail', (ok ? '✓ ' : '✗ ') + head, pretty);
  } catch (e) {
    show('fail', '✗ request failed — is the proxy running?', String(e));
  }
}

function submitOrder() {
  const text = freshen(document.getElementById('payload').value);
  send('POST', base() + '/', text);
}
function pullScoped() {
  send('GET', base() + '/DiagnosticReport?patient=Patient/9d480e52-5ae2-4c5d-bebb-1cdb9e3c4683');
}
function pullUnscoped() {
  send('GET', base() + '/DiagnosticReport');
}
</script>
</body>
</html>
"""

html = html.replace('__VALID__', payloads['valid']).replace('__INVALID__', payloads['invalid']).replace('__IMPILO__', payloads['impilo'])
with open('simulator/ehr-simulator.html', 'w') as f:
    f.write(html)
print('simulator/ehr-simulator.html written')
PY
