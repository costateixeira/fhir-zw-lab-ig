### Testing

This IG ships with an executable **actor conformance test kit** written in Gherkin and run with [Karate](https://karatelabs.io/). The kit lives in the source repository under [`tests/karate/`](https://github.com/mohcc/fhir-zw-lab-ig/tree/main/tests/karate) and exercises the [workflow actors](actors.html) against a FHIR server playing the repository roles (by default a [hapi-sandbox](https://github.com/costateixeira/hapi-sandbox) instance with this IG and the ZW Core IG loaded).

#### What is tested

Each actor has a feature file tagged with its role. The Karate suite plays the client roles itself; the server under test plays the repository roles.

| Feature | Tag | What it asserts |
|---|---|---|
| `order-placer.feature` | `@lab-order-placer` | A conformant [ZWLabOrderBundle](StructureDefinition-zw-lab-order-bundle.html) validates and is accepted as a FHIR transaction |
| `order-repository.feature` | `@lab-order-repository` | Search semantics for stored orders (Task by status, ServiceRequest by patient); rejection of invalid submissions |
| `order-fulfiller.feature` | `@lab-order-fulfiller` | Orders directed to a laboratory can be found and claimed (Task status workflow) |
| `result-provider.feature` | `@lab-result-provider` | A conformant [ZWLabReportBundle](StructureDefinition-zw-lab-report-bundle.html) validates and is stored whole |
| `result-repository.feature` | `@lab-result-repository` | Search and retrieval semantics for stored results and report documents |
| `result-consumer.feature` | `@lab-result-consumer` | Results for a patient can be retrieved and correlated to the originating order |
| `end-to-end.feature` | `@e2e` | The full ①→④ loop, chaining the role features with shared identifiers |
| `auditor.feature` | `@auditor` | Payloads submitted by *external* systems (a real EHR/LIMS, or manual POST) are found on the server and validated against the IG profiles |
| `transactions/*.feature` | — | Transaction-level smoke tests (submit/poll orders and results as single resources), driven entirely by external JSON data files |

#### Layered validation

1. **Workflow assertions** in every scenario: status codes, Bundle shapes, search semantics, Task state transitions, referential linkage between results and orders.
2. **Profile validation** (`@validation`-tagged steps): payloads and responses are checked with `$validate?profile=...` against this IG's profiles — requires the server to have the IG packages loaded.
3. **Validation-on-write** (planned): the sandbox rejects non-conformant writes, making the negative scenarios (`@pending-validation`) executable.

#### Running the kit

Prerequisite: Java 17+. From the repository root:

```bash
cd tests/karate
./scripts/load-ig.sh            # one-time: load the IG packages onto the server
./run-tests.sh                  # full happy-path suite against the default server
./run-tests.sh @lab-order-placer   # one actor's suite
SHR_URL=https://my-shr/fhir ./run-tests.sh   # against any FHIR server
```

The script downloads the standalone `karate.jar` on first use and writes an HTML report to `tests/karate/target/karate-reports/`.

Scenarios tagged `@workshop` are intentionally unimplemented placeholders for hands-on workshop sessions; they are excluded from the default run.

#### Testing your own system

- **Playing a client role** (Order Placer, Fulfiller, Result Provider, Consumer), live: start an **actor interceptor** (`./run-interceptor.sh ehr 8080` or `lab 8081`) and point your system at it. Pushes are forwarded to the real server's `$validate` (your system receives the OperationOutcome; nothing is stored) and pulls are gated for correct patient scoping, then forwarded.
- **Playing a client role**, after the fact: let your system submit to the sandbox, then run `auditor.feature` with your patient identifier to validate everything that arrived.
- **Playing a repository role**: set the base URL to your server (`SHR_URL=https://your-server/fhir ./run-tests.sh`) and run the repository suites against it.
