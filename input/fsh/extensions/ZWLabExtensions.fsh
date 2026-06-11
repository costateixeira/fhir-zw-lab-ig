// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Extensions
// ─────────────────────────────────────────────────────────────────────────────

Extension: DateOfBirthEstimated
Id: date-of-birth-estimated
Title: "Date of Birth Estimated"
Description: "Indicates that the client's date of birth is an estimate rather than the precise birth date. Corresponds to the Impilo→Senaite contract field `dateOfBirthEstimated`."
Context: Patient
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/date-of-birth-estimated"
* ^status = #active
* value[x] only boolean


Extension: ReportReviewState
Id: report-review-state
Title: "Report Review State"
Description: "The LIMS workflow/publication state of a laboratory report (ZW.LAB.A.DE73). This mutable status is separate from the FHIR `DiagnosticReport.status` lifecycle status, which tracks the clinical finality of the report."
Context: DiagnosticReport
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/report-review-state"
* ^status = #active
* value[x] only CodeableConcept
* valueCodeableConcept from VSZWReportReviewState (required)
