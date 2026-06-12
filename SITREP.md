# SITREP — ZW Lab IG: Actor-Based Conformance Testing

*Status as of Fri Jun 12, 2026. Branch: `actor-test-kit` (PR into `costateixeira:testing`). This file is untracked — it's a briefing, not a deliverable.*

## 1. What we're building and why

The Zimbabwe Lab IG specifies laboratory ordering and results exchange for the national architecture: **Impilo EHR** places orders and consumes results, the **Shared Health Record** (HAPI FHIR, fronted by OpenHIM) stores everything, and **Senaite LIMS** fulfils orders and produces results. Until this week the IG had profiles and terminology but nothing that said *who must do what* — and nothing executable to prove that a real system does it.

The goal of the current work: make the workflow **testable per actor**, demo-friendly for a connectathon/workshop, using Gherkin/Karate so the tests read like the specification they enforce.

## 2. The actor model

Six conformance roles (the whiteboard names), played by three systems:

| Actor | System | Does |
|---|---|---|
| Lab Order Placer | Impilo EHR | pushes orders |
| Lab Order Repository | SHR | validates, stores, serves orders |
| Lab Order Fulfiller | Senaite LIMS | pulls + claims orders |
| Lab Result Provider | Senaite LIMS | pushes signed-off results |
| Lab Result Repository | SHR | validates, stores, serves results |
| Lab Result Consumer | Impilo EHR | pulls results |

Four transactions connect them:

1. **Order push** — `ZWLabOrderBundle`, a *transaction* Bundle (Task + ServiceRequest + Patient + Specimen, optional pregnancy/breastfeeding Observations), `POST [base]`. The repository executes it atomically and rewires the `urn:uuid` references.
2. **Order pull** — the fulfiller searches `Task?status=requested` (+ patient scope), then claims by updating Task status through the FHIR workflow state machine (`requested → accepted → in-progress → completed`).
3. **Result push** — `ZWLabReportBundle`, a *document* Bundle (Composition with mandatory legal attester per ZW.LAB.A.DE80/DE82, DiagnosticReport, Observations), `POST [base]/Bundle` and **stored whole** so the signed snapshot stays intact; the DiagnosticReport links back to the order via `basedOn`.
4. **Result pull** — the consumer searches `DiagnosticReport` by patient identifier and `based-on`, and fetches the stored document by its identifier.

Each transaction has a `Requirements` resource stating the SHALL/SHOULD obligations of both sides; each role has an `ActorDefinition`. Both are R5 resource types legally embedded in this R4 IG (SUSHI ≥ 3.19).

## 3. What was already there vs what our PR adds

**Already on `testing` (Jose):** the IG scaffold and build chain; the core profiles (`ZWLabTask`, `ZWLabServiceRequest`, `ZWSpecimen`, `ZWLabPatient`, `ZWLabDiagnosticReport`, `ZWLabResultObservation`), terminology, logical models; per-transaction Karate smoke tests (Maven-based, data-driven JSON payloads); a collection-Bundle order profile + minimal result-document profiles (`bundles.fsh`); pregnancy/breastfeeding Observation profiles (`observations.fsh`); and — newest — **actor interceptors** (`mock/ehr.feature`, `mock/lab.feature` + a Maven launcher).

**Our PR ([fhir-zw-lab-ig #1](https://github.com/costateixeira/fhir-zw-lab-ig/pull/1)) adds/changes:**

- **Specification layer.** Six `ActorDefinition`s, four `Requirements`, Actors + Testing narrative pages with menu entries, and the `ZWLabOrderBundle` transaction profile + a full order-bundle example in the Viral Load scenario. The previously uncommitted `ZWLabReportBundle`/`ZWLabReportComposition` (document + legal attester) are included.
- **Profile reconciliation.** Jose's `bundles.fsh` defined `ZWLabOrderBundle` as a *collection* and a thinner result-document pair. We kept **one** order bundle — the transaction form, since that's the documented push mechanism — and folded in his idea as optional pregnancy/breastfeeding entry slices pinned to his Observation profiles. His `ZWLabResultBundle`/`ZWLabResultComposition` were dropped in favour of the more complete `ZWLabReportBundle` (attester, identifier/timestamp, fullUrl constraints, sections). Flagged in the PR for his review; `observations.fsh` kept intact. The empty `ZimLabResults.fsh` placeholder was removed.
- **One unified Karate kit** (`tests/karate/`), standalone `karate.jar` (no Maven; Java pinned via `.sdkmanrc`, runner self-bootstraps from SDKMAN candidates):
  - *Actor suites* — one role-tagged feature per actor + `end-to-end.feature` walking the full T1→T4 loop with live identifiers, + `@workshop` placeholder scenarios (11) to be authored with participants.
  - *Transaction smoke tests* — Jose's features relocated verbatim to `features/transactions/`, plus an idempotent `_ensure-patient` helper so his fixed-patient payloads also work on fresh servers with referential integrity (previously they only worked on the ZW test server).
  - *Interceptors* — Jose's ehr/lab mock features relocated to `features/interceptors/`, launched by `run-interceptor.sh <ehr|lab> <port>` via the standalone jar's `mock` mode. One functional fix: `karate.proceed()` returns an empty body under karate 2.x, so the gated pull scenarios now forward explicitly. Verified live: pushes relay the `$validate` OperationOutcome, profile-invalid pushes return the errors, unscoped pulls are gated 400, scoped pulls return the searchset. The Maven scaffold (pom, JUnit runner, mock launcher) was retired; trivially restorable for CI later.
  - *Auditor* — finds everything a real system submitted for a given patient and `$validate`s it against the IG.
  - *Test data discipline* — `scripts/sync-test-data.sh` derives all bundle payloads from the IG's own built examples (rewriting intra-bundle refs to `urn:uuid`, generating invalid variants), so test data cannot drift from the spec. `scripts/load-ig.sh` loads both IG packages onto any server by canonical-URL conditional update (this caught a real id collision: both IGs ship an SD with id `citizenship`).

**Verification:** SUSHI 0 errors/0 warnings; IG publisher build clean; 28/28 active scenarios green against a local hapi-sandbox; all four interceptor behaviours verified live.

## 4. Validation story (the layered approach)

1. **Workflow assertions** in every scenario — status codes, searchset shapes, Task state machine, `basedOn` linkage. Tests behaviour even on a permissive server.
2. **Explicit `$validate`** (`@validation`-tagged) — payloads *and server responses* checked against the IG profiles; needs the IG packages on the server.
3. **Validation-on-write** — the [hapi-sandbox PR](https://github.com/costateixeira/hapi-sandbox/pull/1) (base: `zimbabwe`) loads both IG packages (field-verified config: `packageUrl`, `installMode: STORE_AND_INSTALL`, `validate_resource_status_for_package_upload: false` for the draft ci-build resources) and enables `validation.requests_enabled`, making the repository actors genuinely reject non-conformant writes. Three `@pending-validation` rejection scenarios activate when it merges.
4. **Deferred:** an independent validator service (Matchbox / validator-wrapper) for terminology-complete, server-neutral validation — the known gap is LOINC: an offline HAPI can't validate it, so kit payloads carry national codes only while the IG examples keep the LOINC translations.

## 5. Connectathon plan

**Track A — real systems.** Start the interceptor for the role under test (`./run-interceptor.sh ehr 8080` or `lab 8081`, `TARGET=<sandbox>`); point the system's FHIR base URL at it; drive the workflow from the system's own UI. Pushes come back with the profile-validation OperationOutcome (nothing stored), badly scoped queries get 400 — live, per-request feedback with zero changes to the system. When clean, repoint at the real sandbox, submit, then score with the auditor (`AUDIT_PATIENT_IDENTIFIER=... ./run-tests.sh @auditor`) and optionally run the role's suite.

**Track B — Postman/curl.** Use the kit's payloads (`tests/karate/data/` bundles, `features/transactions/data/` single resources) directly against the sandbox: POST the order transaction, `$validate` it, claim the Task, POST the report document, pull results by patient identifier, then send the invalid variants and watch the repository reject them. Self-score with the auditor. On a shared sandbox, uniquify patient/sample/document identifiers per run (the Karate helpers do this automatically).

## 6. Open items and decision points

- **Jose's review of the profile reconciliation** — order bundle semantics (transaction vs collection) and result-document naming (`ZWLabReportBundle` vs his `ZWLabResultBundle`).
- **Hosted sandbox URL** — placeholder in `karate-config.js` (`hosted` env); `zw` env targets 173.212.195.88.
- **Sandbox PR merge** — activates the rejection scenarios; carries a flagged trade-off (validation-on-write will also reject valid payloads with unknown-terminology codings, e.g. LOINC).
- **SVG diagrams for the IG pages** — drafted but stashed (`git stash list`: "deferred: IG SVG diagrams"); they have a character-encoding problem (one page invalid XHTML) to fix before committing.
- **11 workshop placeholder scenarios** — the deliberate hands-on material.
- **Later:** CI job running the kit, Maven/JUnit wrapper if wanted, independent validator service, TestPlan resources formally wrapping the Gherkin.
