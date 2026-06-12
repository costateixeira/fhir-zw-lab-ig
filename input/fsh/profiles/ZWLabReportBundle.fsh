// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Report Document Bundle
// Pattern based on HL7 Europe Laboratory Report (Bundle-eu-lab):
//   document Bundle with a Composition first entry, sliced entries per profile.
// Used to send laboratory results as a signed-off snapshot document.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Composition ─────────────────────────────────────────────────────────────

Profile: ZWLabReportComposition
Parent: Composition
Id: zw-lab-report-composition
Title: "ZW Lab Report Composition"
Description: "Composition for a Zimbabwe laboratory result report document. The legal attester records the sign-off of the report by the responsible laboratory authority (ZW.LAB.A.DE80/DE82)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-report-composition"
* ^status = #active

* status 1..1 MS
* status ^short = "Composition status — 'final' for a signed-off report"

* type 1..1 MS
* type = $LNC#11502-2 "Laboratory report"
* type ^short = "Kind of composition: Laboratory report (LOINC 11502-2)"

* subject 1..1 MS
* subject only Reference(ZWLabPatient)

* date 1..1 MS
* date ^short = "Report edit/composition date"

* author 1..* MS
* author ^short = "Who authored the report (laboratory or practitioner)"

* title 1..1 MS

* custodian 0..1 MS
* custodian only Reference(ZWLaboratory)
* custodian ^short = "Laboratory maintaining the report"

// ─── Sign-off ────────────────────────────────────────────────────────────────
* attester 1..* MS
* attester ^short = "Report sign-off"
* attester ^slicing.discriminator.type = #value
* attester ^slicing.discriminator.path = "mode"
* attester ^slicing.rules = #open
* attester contains legalAttester 1..1 MS
* attester[legalAttester].mode = #legal
* attester[legalAttester].time 1..1 MS
* attester[legalAttester].time ^short = "When the report was signed off (ZW.LAB.A.DE82)"
* attester[legalAttester].party 1..1 MS
* attester[legalAttester].party ^short = "Who signed off the report (ZW.LAB.A.DE80)"

// ─── Sections ────────────────────────────────────────────────────────────────
* section 1..* MS
* section ^slicing.discriminator.type = #value
* section ^slicing.discriminator.path = "code"
* section ^slicing.rules = #open
* section contains labResults 1..1 MS
* section[labResults].title 1..1 MS
* section[labResults].code 1..1 MS
* section[labResults].code = $LNC#30954-2 "Relevant diagnostic tests/laboratory data note"
* section[labResults].entry 1..* MS
* section[labResults].entry only Reference(ZWLabDiagnosticReport or ZWLabResultObservation)
* section[labResults].entry ^short = "The laboratory report(s) and result(s) in this document"


// ─── Document Bundle ─────────────────────────────────────────────────────────

Profile: ZWLabReportBundle
Parent: Bundle
Id: zw-lab-report-bundle
Title: "ZW Lab Report Document Bundle"
Description: "Document Bundle carrying a signed-off snapshot of a Zimbabwe laboratory result report: a ZWLabReportComposition followed by the DiagnosticReport, Observations, Patient, Specimen and supporting resources."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-report-bundle"
* ^status = #active

* type 1..1 MS
* type = #document
* identifier 1..1 MS
* identifier ^short = "Persistent identifier of this document instance"
* timestamp 1..1 MS
* timestamp ^short = "When the document was assembled"
* signature 0..1 MS
* signature ^short = "Optional digital signature over the document"

* entry 2..* MS
* entry ^slicing.discriminator.type = #type
* entry ^slicing.discriminator.path = "resource"
* entry ^slicing.rules = #open
* entry ^slicing.description = "Slice bundle entries by resource profile"

* entry contains
    composition 1..1 MS and
    diagnosticReport 1..* MS and
    patient 1..1 MS and
    observation 0..* MS and
    specimen 0..* MS and
    serviceRequest 0..* MS and
    organization 0..* MS and
    practitioner 0..* MS and
    location 0..* MS

* entry[composition].resource 1..1
* entry[composition].resource only ZWLabReportComposition
* entry[composition].fullUrl 1..1
* entry[composition] ^short = "The report Composition (first entry)"

* entry[diagnosticReport].resource 1..1
* entry[diagnosticReport].resource only ZWLabDiagnosticReport
* entry[diagnosticReport].fullUrl 1..1
* entry[diagnosticReport] ^short = "Laboratory report(s)"

* entry[patient].resource 1..1
* entry[patient].resource only ZWLabPatient
* entry[patient].fullUrl 1..1
* entry[patient] ^short = "Subject of the report"

* entry[observation].resource 1..1
* entry[observation].resource only ZWLabResultObservation
* entry[observation].fullUrl 1..1
* entry[observation] ^short = "Individual laboratory result(s)"

* entry[specimen].resource 1..1
* entry[specimen].resource only ZWSpecimen
* entry[specimen].fullUrl 1..1
* entry[specimen] ^short = "Specimen(s) analysed"

* entry[serviceRequest].resource 1..1
* entry[serviceRequest].resource only ZWLabServiceRequest
* entry[serviceRequest].fullUrl 1..1
* entry[serviceRequest] ^short = "Originating test request(s)"

* entry[organization].resource 1..1
* entry[organization].resource only ZWLaboratory
* entry[organization].fullUrl 1..1
* entry[organization] ^short = "Laboratory and other organisations"

* entry[practitioner].resource 1..1
* entry[practitioner].resource only Practitioner
* entry[practitioner].fullUrl 1..1
* entry[practitioner] ^short = "Practitioners (submitter, verifier)"

* entry[location].resource 1..1
* entry[location].resource only ZWFacility
* entry[location].fullUrl 1..1
* entry[location] ^short = "Facilities referenced by the report"
