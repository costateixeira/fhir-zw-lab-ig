// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Order-Side Profiles
// Mapped from: Lab workflow integration.xlsx (LIMS Order Contract sheet)
//              Zimbabwe_lab_data_dictionary_2_0.xlsx — ZW.LAB.A1 (DE1–DE72)
// ─────────────────────────────────────────────────────────────────────────────

// NOTE: ZWLabPatient is defined in ZWLabPatient.fsh

// ─── Laboratory (Organization) ───────────────────────────────────────────────

Profile: ZWLaboratory
Parent: Organization
Id: zw-laboratory
Title: "ZW Laboratory (Organization)"
Description: "A laboratory in the national Zimbabwe laboratory network. Used as the receiving laboratory for an order (ZW.LAB.A.DE10) and as the reporting organisation for a DiagnosticReport."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-laboratory"
* ^status = #active

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains nationalLabCode 1..1 MS

* identifier[nationalLabCode].system 1..1
* identifier[nationalLabCode].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-laboratories"
* identifier[nationalLabCode].value 1..1 MS
* identifier[nationalLabCode] ^short = "National laboratory code (e.g. ZWLHRE002)"

* type 1..* MS
* type ^short = "Organization type — must include 'Laboratory'"

* name 1..1 MS


// ─── Facility (Location) ─────────────────────────────────────────────────────

Profile: ZWFacility
Parent: Location
Id: zw-facility
Title: "ZW Health Facility (Location)"
Description: "A health facility placing a laboratory order in Zimbabwe (ZW.LAB.A.DE11)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-facility"
* ^status = #active

* name 1..1 MS
* name ^short = "Ordering facility name (ZW.LAB.A.DE11)"


// ─── ServiceRequest (Test order) ─────────────────────────────────────────────

Profile: ZWLabServiceRequest
Parent: ServiceRequest
Id: zw-lab-service-request
Title: "ZW Lab Service Request"
Description: "A laboratory test request from a Zimbabwe health facility to a laboratory (ZW.LAB.A1 DE17–DE72)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-service-request"
* ^status = #active

* status 1..1 MS
* intent 1..1 MS
* intent = #order

* code 1..1 MS
* code ^short = "Test requested (ZW.LAB.A.DE17)"
* code from VSZWLabTests (required)

* reasonCode 0..* MS
* reasonCode ^short = "Reason for test (ZW.LAB.A.DE30)"
* reasonCode from VSZWReasonForTest (preferred)

* subject 1..1 MS
* subject only Reference (ZWLabPatient)

* requester 0..1 MS
* requester ^short = "Ordering clinician/provider"

* specimen 0..1 MS
* specimen only Reference(ZWSpecimen)
* specimen ^short = "Specimen for this test request"

* locationReference 0..1 MS
* locationReference only Reference(ZWFacility)
* locationReference ^short = "Ordering facility (ZW.LAB.A.DE11)"


// ─── Specimen ────────────────────────────────────────────────────────────────

Profile: ZWSpecimen
Parent: Specimen
Id: zw-specimen
Title: "ZW Lab Specimen"
Description: "A laboratory specimen collected in the Zimbabwe lab workflow (ZW.LAB.A1 DE52–DE72)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-specimen"
* ^status = #active

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains clientSampleId 1..1 MS

* identifier[clientSampleId].system 1..1
* identifier[clientSampleId].system = "http://mohcc.gov.zw/fhir/lab/identifier/client-sample-id"
* identifier[clientSampleId].value 1..1 MS
* identifier[clientSampleId] ^short = "Client sample identifier (ZW.LAB.A.DE52)"

* type 0..1 MS
* type ^short = "Sample type (ZW.LAB.A.DE53)"
* type from VSZWSampleTypes (preferred)

* subject 1..1 MS
* subject only Reference(ZWLabPatient)

* request 0..1 MS
* request only Reference(ZWLabServiceRequest)

* collection.collected[x] 0..1 MS
* collection.collected[x] ^short = "Date/time collected (ZW.LAB.A.DE72)"

* condition 0..* MS
* condition ^short = "Specimen rejection reason(s) (ZW.LAB.A.DE88)"
* condition from VSZWRejectionReasons (required)

* note 0..* MS
* note ^short = "Additional notes on specimen condition or rejection"


// ─── Task (Order wrapper) ────────────────────────────────────────────────────

Profile: ZWLabTask
Parent: Task
Id: zw-lab-task
Title: "ZW Lab Order Task"
Description: "Task that wraps a laboratory test order sent from Impilo (EHR) to a LIMS via OpenHIM. Carries the ServiceRequest plus contextual clinical information (ZW.LAB.A1)."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-task"
* ^status = #active

* status 1..1 MS
* intent 1..1 MS
* intent = #order

* for 1..1 MS
* for only Reference(ZWLabPatient)
* for ^short = "Patient subject of the order"

* basedOn 1..1 MS
* basedOn only Reference(ZWLabServiceRequest)
* basedOn ^short = "The ServiceRequest this Task fulfils"

* focus 0..1 MS
* focus only Reference(ZWLabServiceRequest)

* requester 0..1 MS
* requester ^short = "Ordering provider (Practitioner or Organization)"

* location 0..1 MS
* location only Reference(ZWFacility)
* location ^short = "Ordering facility"

* restriction.recipient 0..1 MS
* restriction.recipient only Reference(ZWLaboratory)
* restriction.recipient ^short = "Receiving laboratory (ZW.LAB.A.DE10)"

// ─── Task.input slices for clinical context ───────────────────────────────────
* input ^slicing.discriminator.type = #value
* input ^slicing.discriminator.path = "type.coding.code"
* input ^slicing.rules = #open
* input ^slicing.description = "Clinical context inputs carried on the order Task."

* input contains
    pregnant 0..1 MS and
    breastfeeding 0..1 MS and
    artStartDate 0..1 MS and
    regimen 0..1 MS

* input[pregnant].type.coding.code = #pregnant
* input[pregnant].type.coding.system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[pregnant].value[x] only boolean
* input[pregnant] ^short = "Pregnant at time of ordering (ZW.LAB.A.DE13)"

* input[breastfeeding].type.coding.code = #breastfeeding
* input[breastfeeding].type.coding.system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[breastfeeding].value[x] only boolean
* input[breastfeeding] ^short = "Breastfeeding at time of ordering (ZW.LAB.A.DE14)"

* input[artStartDate].type.coding.code = #art-start-date
* input[artStartDate].type.coding.system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[artStartDate].value[x] only date
* input[artStartDate] ^short = "ART start date (ZW.LAB.A.DE15)"

* input[regimen].type.coding.code = #regimen
* input[regimen].type.coding.system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[regimen].value[x] only string
* input[regimen] ^short = "Current ART regimen (ZW.LAB.A.DE16)"

// ─── Task.output: reference to DiagnosticReport when result arrives ───────────
* output ^slicing.discriminator.type = #value
* output ^slicing.discriminator.path = "type.coding.code"
* output ^slicing.rules = #open

* output contains diagnosticReport 0..1 MS

* output[diagnosticReport].type.coding.code = #diagnostic-report
* output[diagnosticReport].type.coding.system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-output-type"
* output[diagnosticReport].value[x] only Reference(ZWLabDiagnosticReport)
* output[diagnosticReport] ^short = "DiagnosticReport produced by the LIMS"
