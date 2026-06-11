// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Logical Models — WHO L3 DAK style
// Activity ZW.LAB.A1: Order laboratory test(s) (DE1–DE72)
// Activity ZW.LAB.A2: Report laboratory result(s) (DE73–DE99)
// Source: Zimbabwe_lab_data_dictionary_2_0.xlsx
// ─────────────────────────────────────────────────────────────────────────────

Logical: ZWLabOrder
Id: zw-lab-order
Title: "ZW Lab Order (ZW.LAB.A1)"
Description: "Logical model for ordering a laboratory test in Zimbabwe. Covers all data elements defined in activity ZW.LAB.A1 of the Zimbabwe Lab DAK data dictionary."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-order"
* ^status = #active

// ─── Patient demographics (DE1–DE9) ──────────────────────────────────────────
* ehrPatientId 1..1 string "EHR Patient ID (ZW.LAB.A.DE1)" "Unique identifier of the client in the ordering EMR."
* clientIdentifier 0..1 Identifier "Client Identifier (ZW.LAB.A.DE2)" "National or other client identifier used for identity matching."
* name 0..1 HumanName "Client Name (ZW.LAB.A.DE3-DE4)" "Client's given name (DE3) and family name (DE4)."
* dateOfBirth 1..1 date "Date of Birth (ZW.LAB.A.DE5)" "Client's date of birth."
* sex 1..1 code "Sex (ZW.LAB.A.DE6)" "Client's administrative sex."
* sex from http://hl7.org/fhir/ValueSet/administrative-gender (required)
* artNumber 0..1 string "ART Number (ZW.LAB.A.DE9)" "Client's antiretroviral therapy (ART) number."

// ─── Order context (DE10–DE16) ────────────────────────────────────────────────
* receivingLaboratory 0..1 CodeableConcept "Receiving Laboratory (ZW.LAB.A.DE10)" "Laboratory designated to perform the order, coded against the national laboratory list."
* receivingLaboratory from VSZWLaboratories (required)
* orderingFacility 1..1 string "Ordering Facility (ZW.LAB.A.DE11)" "Health facility placing the order."
* orderStatus 0..1 code "Order Status (ZW.LAB.A.DE12)" "Lifecycle status of the fulfilment of the laboratory order."
* pregnant 0..1 boolean "Pregnant (ZW.LAB.A.DE13)" "Whether the client is pregnant at time of ordering."
* breastfeeding 0..1 boolean "Breastfeeding (ZW.LAB.A.DE14)" "Whether the client is breastfeeding at time of ordering."
* artStartDate 0..1 date "ART Start Date (ZW.LAB.A.DE15)" "Date the client started antiretroviral therapy."
* currentArtRegimen 0..1 string "Current ART Regimen (ZW.LAB.A.DE16)" "Client's current ART regimen."

// ─── Test request (DE17) ──────────────────────────────────────────────────────
* testRequested 1..1 CodeableConcept "Test Requested (ZW.LAB.A.DE17)" "Laboratory test being requested, coded against the national test list."
* testRequested from VSZWLabTests (required)

// ─── Reason for test (DE30) ───────────────────────────────────────────────────
* reasonForTest 1..1 CodeableConcept "Reason for Test (ZW.LAB.A.DE30)" "Clinical reason the test is being requested."
* reasonForTest from VSZWReasonForTest (required)

// ─── Specimen (DE52–DE72) ─────────────────────────────────────────────────────
* clientSampleId 0..1 string "Client Sample Identifier (ZW.LAB.A.DE52)" "Identifier assigned to the specimen at collection; the exchange key linking specimen, order and result."
* sampleType 0..1 CodeableConcept "Sample Type (ZW.LAB.A.DE53)" "Type of specimen collected, coded against the national sample type list."
* sampleType from VSZWSampleTypes (preferred)
* dateCollected 0..1 dateTime "Date Collected (ZW.LAB.A.DE72)" "Date and time the specimen was collected."


// ─────────────────────────────────────────────────────────────────────────────
// Activity ZW.LAB.A2: Report laboratory result(s)
// ─────────────────────────────────────────────────────────────────────────────

Logical: ZWLabResultReport
Id: zw-lab-result-report
Title: "ZW Lab Result Report (ZW.LAB.A2)"
Description: "Logical model for reporting a laboratory result in Zimbabwe. Covers all data elements defined in activity ZW.LAB.A2 of the Zimbabwe Lab DAK data dictionary."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-result-report"
* ^status = #active

// ─── Report workflow state (DE73–DE78) ───────────────────────────────────────
* reportReviewState 0..1 CodeableConcept "Report Review State (ZW.LAB.A.DE73)" "Review/publication state of the result report in the laboratory workflow."
* reportReviewState from VSZWReportReviewState (required)

// ─── Provenance (DE79–DE82) ───────────────────────────────────────────────────
* resultSubmitter 1..1 string "Result Submitter (ZW.LAB.A.DE79)" "Person who submitted the result."
* resultVerifier 1..1 string "Results Verifier (ZW.LAB.A.DE80)" "Person who verified/interpreted the result."
* dateSubmitted 1..1 dateTime "Date Submitted (ZW.LAB.A.DE81)" "Date and time the result was submitted."
* dateVerified 1..1 dateTime "Date Verified (ZW.LAB.A.DE82)" "Date and time the result was verified/issued."

// ─── Result value (DE83–DE85) ─────────────────────────────────────────────────
* resultValue 1..1 string "Result Value (ZW.LAB.A.DE83)" "Measured/observed value of the test result."
* resultUnit 0..1 string "Result Unit (ZW.LAB.A.DE84)" "Unit of measure for the result value (UCUM). Required when the result is a quantity."
* resultStatus 1..1 code "Result Status (ZW.LAB.A.DE85)" "Status of the individual result (e.g. preliminary, final, amended)."
* resultStatus from http://hl7.org/fhir/ValueSet/observation-status (required)

// ─── Method (DE86) ───────────────────────────────────────────────────────────
* testingMethod 0..1 string "Testing Method (ZW.LAB.A.DE86)" "Method used to produce the result."

// ─── Specimen rejection (DE88–DE99) ──────────────────────────────────────────
* specimenRejectionReason 0..* CodeableConcept "Specimen Rejection Reason (ZW.LAB.A.DE88)" "Reason(s) the specimen was rejected by the laboratory, if applicable."
* specimenRejectionReason from VSZWRejectionReasons (required)
