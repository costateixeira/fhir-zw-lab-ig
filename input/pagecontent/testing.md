### Testing

This IG has a dedicated **conformance test kit**, published as its own implementation guide so the test data and the executable suite can iterate quickly without destabilising this specification.

The test kit provides:

- **Validated test payloads** — the exact on-the-wire order and report bundles, published as examples and validated against this IG's profiles on every build.
- **An executable actor conformance suite** — Gherkin/[Karate](https://karatelabs.io/) feature files that play each [workflow actor](actors.html) against a FHIR server under test, plus actor interceptors and browser simulators for testing a live system.
- **Layered validation** — workflow assertions, `$validate` profile checks, and validation-on-write rejection of non-conformant payloads.

➡️ **[Zimbabwe Lab IG Conformance Test Kit](https://build.fhir.org/ig/pmanko/fhir-zw-lab-test-ig)** — the published test kit IG (`zw.fhir.ig.lab.test`).

➡️ **[Source repository](https://github.com/pmanko/fhir-zw-lab-test-ig)** — the Karate suite, interceptors, and simulators under `karate/`, with instructions for running them against your own system.
