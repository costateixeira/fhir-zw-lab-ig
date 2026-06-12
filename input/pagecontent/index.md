<div>
<p>This implementation guide and set of artifacts are still undergoing development.</p>
<p>Content is for demonstration and practice purposes only.</p>
</div>{:.stu-note}

### Summary

This Implementation Guide (IG) defines FHIR R4 profiles, logical models, and terminology for **laboratory test ordering and result reporting in Zimbabwe**. It supports the national digital health architecture connecting:

- **Impilo EHR** — the ordering electronic health record system used at health facilities
- **OpenHIM** — the Health Information Exchange (HIE) interoperability layer (routing, validation, audit)
- **Shared Health Record (SHR)** — the HAPI FHIR server storing all orders and results
- **Senaite LIMS** — the national Laboratory Information Management System

### Transaction Flow

The exchange uses a **push-and-pull** model:

1. **Order submission (push):** Impilo submits a `Task` + `ServiceRequest` + `Specimen` to OpenHIM (FHIR `POST`). OpenHIM validates and stores the order in the SHR.
2. **Order retrieval (pull):** Senaite LIMS periodically queries the SHR (`FHIR Search`) to retrieve orders assigned to it.
3. **Result submission (push):** After testing, Senaite pushes a `DiagnosticReport` + `Observation` to OpenHIM, which stores the result in the SHR.
4. **Result retrieval (pull):** Impilo queries the SHR to retrieve results for its patients.

Patient identity is resolved via **VITO (MPI/Client Registry)** and terminology is validated via **Butano** (SNOMED CT, LOINC, ICD-10).

### Scope — Iteration 1

This first iteration includes:

- **Logical models:** `ZWLabOrder` (ZW.LAB.A1) and `ZWLabResultReport` (ZW.LAB.A2) derived from the Zimbabwe Lab DAK data dictionary.
- **Profiles:** `ZWLabPatient`, `ZWLabTask`, `ZWLabServiceRequest`, `ZWSpecimen`, `ZWLaboratory`, `ZWFacility`, `ZWLabDiagnosticReport`, `ZWLabResultObservation`.
- **Exchange bundles:** `ZWLabOrderBundle` (order transaction) and `ZWLabReportBundle` (signed-off result report document with `ZWLabReportComposition`).
- **Actors and requirements:** the six [workflow actors](actors.html) (Lab Order Placer/Repository/Fulfiller, Lab Result Provider/Repository/Consumer) and per-transaction Requirements.
- **Extensions:** `DateOfBirthEstimated`, `ReportReviewState`.
- **Terminology:** National code systems and value sets for tests, sample types, reasons for test, rejection reasons, report review states, and the national laboratory list.
- **Examples:** End-to-end Viral Load Plasma order and result scenario.
- **Testing:** a Gherkin/Karate [actor conformance test kit](testing.html) exercising the workflow transactions.

### Out of Scope (Iteration 1)

CapabilityStatements, ConceptMaps, Questionnaires, decision-support logic, indicator measures, ICD-11/LOINC/SNOMED terminologist mappings.

### Relationship to Other Guides

This IG targets Zimbabwe national use. It draws on design patterns from the [HL7 Europe Laboratory Report IG](https://build.fhir.org/ig/hl7-eu/laboratory/) for logical model structure and profile conventions.
