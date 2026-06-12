# ZW Lab IG — Karate API tests

[Karate](https://github.com/karatelabs/karate) tests that exercise a FHIR server against the
Zimbabwe Lab ordering/result flow. The tests are split by **transaction**, and **all the data that
changes per test lives in external JSON files** under
[`src/test/java/zwlab/data/`](src/test/java/zwlab/data/), so you drive each case by editing those
files rather than the `.feature` scripts.

## What is tested

One feature per transaction:

| Feature | Transaction | Scenarios |
|---------|-------------|-----------|
| `submit-orders.feature`  | Submit order (`ServiceRequest`)     | valid POST accepted (`2xx`); invalid POST rejected (`4xx` + `OperationOutcome`); valid order **conforms** to the ZW order profile (`$validate`, no error issues); non-conforming order **flagged** (`$validate`, has error issues) |
| `poll-orders.feature`    | Poll orders (`ServiceRequest`)      | patient with no orders → empty `searchset`; after submitting → the order is returned |
| `submit-results.feature` | Submit result (`DiagnosticReport`)  | same four as submit-orders, against the ZW result profile |
| `poll-results.feature`   | Poll results (`DiagnosticReport`)   | patient with no results → empty `searchset`; after submitting → the result is returned |

The `$validate` scenarios POST to `[base]/{Type}/$validate?profile=<ZW canonical>` and assert on the
returned `OperationOutcome` — **no `error`/`fatal` issues** for a conforming resource, **at least one**
for a non-conforming one. This is what forces validation against the Zimbabwe profiles rather than
base FHIR.

> Note: a ZW result (`DiagnosticReport`) requires `basedOn` (1..1) pointing at a ZW order, so the
> submit-result and poll-result flows create an order first and link the result to it.

## Prerequisites

- Java 17+
- Maven 3.8+
- A reachable FHIR R4 server **with the ZW IG content loaded** (so the profiles resolve for
  `$validate`). **Default is the ZW test server** `http://173.212.195.88/fhir`. Localhost is opt-in
  via `-Dkarate.env=local`.

## Running

```bash
cd karate

# all transactions against the default ZW server
mvn test

# a single transaction
mvn test -Dkarate.features=classpath:zwlab/submit-orders.feature
mvn test -Dkarate.features=classpath:zwlab/poll-results.feature

# point at a different server
mvn test -DargLine="-DbaseUrl=https://my.fhir.server/fhir"

# named environments
mvn test -Dkarate.env=local   # http://localhost:8080/fhir
mvn test -Dkarate.env=hapi    # public HAPI R4 sandbox
```

## Reports

Run the tests first, then build the report from the JUnit XML Karate emits:

```bash
mvn test          # produces target/karate-reports/*.xml
mvn allure:serve  # builds the Allure report and opens it in your browser
# or, for a static report on disk:
mvn allure:report # -> target/site/allure-maven-plugin/index.html
```

- **Allure (pretty dashboard):** open via `mvn allure:serve` — **do not** double-click
  `target/site/allure-maven-plugin/index.html`. Allure loads its data over AJAX, which browsers block
  under `file://`, so opening the file directly shows an empty "Allure Report — unknown" skeleton.
  Serve it over HTTP instead (`mvn allure:serve`, or `allure open target/site/allure-maven-plugin`).
- Karate's own report opens fine as a file: `target/karate-reports/karate-summary.html`

> First `allure:*` run downloads the Allure distribution, so it takes a minute.

The runner writes `executor.json`, `environment.properties` (base URL, FHIR version, ZW profile
canonicals) and `categories.json` into the results dir, so the Allure **Environment** and
**Categories** tabs and the report name are populated automatically.

## Testing the three actors

The exchange has three actors, each tested differently:

| Actor | Role | How it's tested |
|-------|------|-----------------|
| **SHR** | repository (stores orders & results) | the **`mvn test` suite** above drives it as a client (submit + poll) |
| **EHR** | order placer + results consumer | an **interceptor** that *waits* for the EHR |
| **Lab system** | order consumer + report submitter | an **interceptor** that *waits* for the lab |

The interceptors don't reimplement a FHIR server. They sit in front of the real one and, per request:

- **a submission** (EHR placing an order / lab submitting a report) is forwarded to the real server's
  `$validate` against the matching ZW profile — so the producer's payload is **validated, never stored**;
  the client gets the `OperationOutcome` back.
- **a query** (lab fetching orders / EHR fetching results) is **gated**: it must be scoped to a patient
  (`subject` or `patient` param) or it's rejected `400`; a correct query is forwarded to the repository.

Every request is logged so you can see exactly what the client did.

### Running the "wait for the client" tests

```bash
cd karate

# EHR conformance - listens on :8080, waits for the EHR client
mvn test-compile exec:java -Dexec.args="ehr 8080"

# Lab-system conformance - listens on :8081, waits for the lab client
mvn test-compile exec:java -Dexec.args="lab 8081"

# choose the real server used for $validate / forwarding (default is the ZW server)
mvn test-compile exec:java -Dexec.args="ehr 8080" -Dtarget=http://173.212.195.88/fhir
```

Each command **blocks and waits**. Point the system under test at `http://localhost:<port>`, drive it
through its order/result flow, and watch the responses (and the interceptor log) show whether it placed
conformant resources and issued correct queries. Stop with `Ctrl+C`.

Interceptor features live in [src/test/resources/zwlab/mock/](src/test/resources/zwlab/mock/)
(`ehr.feature`, `lab.feature`); the launcher is
[ZwLab `LabMockServer`](src/test/java/zwlab/LabMockServer.java).

## Layout

```
karate/
├── pom.xml
├── src/test/java/zwlab/
│   └── ZwLabTest.java                # JUnit 5 runner (runs every feature under zwlab/)
└── src/test/resources/
    ├── karate-config.js              # base URL, ZW profile canonicals, global HTTP config
    └── zwlab/
        ├── submit-orders.feature
        ├── poll-orders.feature
        ├── submit-results.feature
        ├── poll-results.feature
        ├── _submit-order.feature     # @ignore helper, called for preconditions
        ├── _submit-result.feature    # @ignore helper, called for preconditions
        └── data/                     # <-- the data you edit per test
            ├── order-create.json            # valid, ZW-conformant order
            ├── order-create-invalid.json    # malformed -> server rejects on POST
            ├── order-profile-invalid.json   # parses, but violates the ZW profile -> $validate error
            ├── order-search-empty.json      # query params: patient with no orders
            ├── order-search-match.json      # query params: patient used by order-create.json
            └── result-*.json                # same set for DiagnosticReport
```

> Features and data live under `src/test/resources` (not `src/test/java`) so they're on the classpath
> for **both** `mvn test` and the IDE test runner.

## The data files

| File | Role | Must satisfy |
|------|------|--------------|
| `*-create.json` | valid, **ZW-conformant** body | accepted on POST (`2xx`) **and** clean under `$validate` |
| `*-create-invalid.json` | malformed body | rejected on POST (`4xx`); the stub uses an illegal `status` code |
| `*-profile-invalid.json` | parses, but breaks a ZW constraint | produces `error` issues under `$validate` (order omits the required `code`; result omits the required `basedOn`) |
| `*-search-empty.json` | query params for the "no data" case | a FHIR search map for a patient with **no** orders/results |
| `*-search-match.json` | query params for the post-then-poll case | must **select the patient used by `*-create.json`** |

Notes:

- **Referential integrity** — the default server enforces it, so `*-create.json` references a real
  `Patient` id on that server (`9d480e52-…`). Point these at a patient that exists on *your* server.
  `submit-results` / `poll-results` create the order at runtime and wire `result.basedOn` to it, so
  that reference always resolves.
- **`$validate` references** — `$validate` does not need referenced resources to exist (unresolved
  references are warnings, not errors), so `order-profile-invalid.json` / `result-profile-invalid.json`
  exercise pure profile constraints.
- **Search params are just a JSON map** — `And params query` expands every key/value into the query
  string, so you can add `status`, `code`, `identifier`, `_lastUpdated`, etc. without touching the
  feature.
- **ZW profile canonicals** live in `karate-config.js` (`profiles.order`, `profiles.result`) and are
  passed as the `?profile=` parameter to `$validate`.
- **Bundles** — to test the `ZWLabOrderBundle` / `ZWLabResultBundle` end to end, point a create file
  at a `transaction` Bundle and POST it to the base URL (`Given path ''`) instead of the type endpoint.

The `_submit-order.feature` / `_submit-result.feature` files (tagged `@ignore`, so the runner skips
them) are reusable helpers `call`ed to set up preconditions. Constant headers and the validation-error
helper live in `karate-config.js`.
