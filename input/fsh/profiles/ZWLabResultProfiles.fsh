// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Result-Side Profiles
// Mapped from: Lab workflow integration.xlsx (LIMS Order Contract — FROM THE LIMS section)
//              Zimbabwe_lab_data_dictionary_2_0.xlsx — ZW.LAB.A2 (DE73–DE99)
// ─────────────────────────────────────────────────────────────────────────────

// ─── DiagnosticReport ────────────────────────────────────────────────────────

Profile: ZWLabDiagnosticReport
Parent: DiagnosticReport
Id: zw-lab-diagnostic-report
Title: "ZW Lab Diagnostic Report"
Description: "A laboratory result report produced by a Zimbabwe LIMS and pushed to the Shared Health Record (ZW.LAB.A2 DE73–DE99)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-diagnostic-report"
* ^status = #active

* extension contains ReportReviewState named reportReviewState 0..1 MS
* extension[reportReviewState] ^short = "LIMS workflow state (ZW.LAB.A.DE73)"

* status 1..1 MS
* status ^short = "Result status (preliminary | final | amended | corrected | cancelled)"

* category 0..* MS
* category ^short = "Laboratory report category"

* code 1..1 MS
* code ^short = "Report/panel code — use the test code from VSZWLabTests"
* code from VSZWLabTests (preferred)

* subject 1..1 MS
* subject only Reference(ZWLabPatient)

* basedOn 1..1 MS
* basedOn only Reference(ZWLabServiceRequest)
* basedOn ^short = "ServiceRequest that initiated this report"

* specimen 0..1 MS
* specimen only Reference(ZWSpecimen)
* specimen ^short = "Specimen analysed"

* effective[x] 0..1 MS
* effectiveDateTime ^short = "Date result submitted (ZW.LAB.A.DE81)"

* issued 0..1 MS
* issued ^short = "Date result verified/issued (ZW.LAB.A.DE82)"

* performer 0..* MS
* performer ^short = "Result submitter (ZW.LAB.A.DE79)"

* resultsInterpreter 0..* MS
* resultsInterpreter ^short = "Results verifier (ZW.LAB.A.DE80)"

* result 0..* MS
* result only Reference(ZWLabResultObservation)
* result ^short = "Individual test result Observation(s)"


// ─── Observation (individual result) ─────────────────────────────────────────

Profile: ZWLabResultObservation
Parent: Observation
Id: zw-lab-result-observation
Title: "ZW Lab Result Observation"
Description: "A single laboratory test result measured by a Zimbabwe LIMS (ZW.LAB.A2 DE83–DE87)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-result-observation"
* ^status = #active

* status 1..1 MS
* status ^short = "Result status (ZW.LAB.A.DE85)"
* status from http://hl7.org/fhir/ValueSet/observation-status (required)

* category 0..* MS
* category ^short = "Laboratory category"

* code 1..1 MS
* code ^short = "Test code (ZW.LAB.A.DE17)"
* code from VSZWLabTests (required)

* subject 1..1 MS
* subject only Reference(ZWLabPatient)

* basedOn 0..1 MS
* basedOn only Reference(ZWLabServiceRequest)
* basedOn ^short = "ServiceRequest that triggered this observation"

* specimen 0..1 MS
* specimen only Reference(ZWSpecimen)

* performer 0..* MS
* performer ^short = "Performer(s) of the observation"

* value[x] 0..1 MS
* value[x] ^short = "Result value (ZW.LAB.A.DE83)"

* valueQuantity.unit ^short = "Result unit — UCUM (ZW.LAB.A.DE84)"

* method 0..1 MS
* method ^short = "Testing method (ZW.LAB.A.DE86)"
