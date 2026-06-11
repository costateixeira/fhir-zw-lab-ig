
// ─── Patient ─────────────────────────────────────────────────────────────────

Profile: ZWLabPatient
Parent: ZimPatient
Id: zw-lab-patient
Title: "ZW Lab Patient"
Description: "Patient demographics exchanged in the Zimbabwe lab ordering workflow (ZW.LAB.A1 DE1–DE9)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-patient"
* ^status = #active

* identifier MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice patient identifiers by system URI."

* identifier contains
    ehrPatientId 1..1 MS and
    artNumber 0..1 MS

* identifier[ehrPatientId].system 1..1
* identifier[ehrPatientId].system = "http://mohcc.gov.zw/fhir/lab/identifier/ehr-patient-id"
* identifier[ehrPatientId].value 1..1 MS
* identifier[ehrPatientId] ^short = "EHR Patient ID (ZW.LAB.A.DE1)"

* identifier[artNumber].system 1..1
* identifier[artNumber].system = "http://mohcc.gov.zw/fhir/lab/identifier/art-number"
* identifier[artNumber].value 1..1 MS
* identifier[artNumber] ^short = "ART Number (ZW.LAB.A.DE9)"


