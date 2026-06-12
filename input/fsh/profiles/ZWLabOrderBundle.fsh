// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Order Transaction Bundle
// The payload pushed by the Lab Order Placer (EHR) to the Lab Order Repository
// (SHR, via OpenHIM): a transaction Bundle carrying the order Task, the
// ServiceRequest it wraps, the Patient, and any collected Specimens.
// Counterpart of ZWLabReportBundle (results side).
// ─────────────────────────────────────────────────────────────────────────────

Profile: ZWLabOrderBundle
Parent: Bundle
Id: zw-lab-order-bundle
Title: "ZW Lab Order Transaction Bundle"
Description: "Transaction Bundle used to submit a laboratory order to the Shared Health Record: a ZWLabTask wrapping a ZWLabServiceRequest, together with the ZWLabPatient and any ZWSpecimen resources. Submitted by the Lab Order Placer as a FHIR transaction (step 1 of the HIE transaction flow). Entries may be created with POST or submitted as idempotent client-id updates with PUT."
* ^url = "http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-order-bundle"
* ^status = #active

* type 1..1 MS
* type = #transaction

* entry 3..* MS
* entry ^slicing.discriminator.type = #profile
* entry ^slicing.discriminator.path = "resource"
* entry ^slicing.rules = #open
* entry ^slicing.description = "Slice bundle entries by resource profile"

* entry contains
    task 1..1 MS and
    serviceRequest 1..1 MS and
    patient 1..1 MS and
    specimen 0..* MS and
    pregnancy 0..1 and
    breastfeeding 0..1

* entry[task].resource 1..1
* entry[task].resource only ZWLabTask
* entry[task].fullUrl 1..1
* entry[task].request 1..1 MS
* entry[task].request obeys zw-order-entry-method
* entry[task] ^short = "The order Task (workflow wrapper)"

* entry[serviceRequest].resource 1..1
* entry[serviceRequest].resource only ZWLabServiceRequest
* entry[serviceRequest].fullUrl 1..1
* entry[serviceRequest].request 1..1 MS
* entry[serviceRequest].request obeys zw-order-entry-method
* entry[serviceRequest] ^short = "The test request being placed"

* entry[patient].resource 1..1
* entry[patient].resource only ZWLabPatient
* entry[patient].fullUrl 1..1
* entry[patient].request 1..1 MS
* entry[patient].request obeys zw-order-entry-method
* entry[patient] ^short = "Subject of the order"

* entry[specimen].resource 1..1
* entry[specimen].resource only ZWSpecimen
* entry[specimen].fullUrl 1..1
* entry[specimen].request 1..1 MS
* entry[specimen].request obeys zw-order-entry-method
* entry[specimen] ^short = "Specimen(s) collected for the order"

// Clinical context may also travel as standalone Observations (alternative
// to the ZWLabTask input slices) so LIMS systems that don't process Task
// inputs can still receive it.
* entry[pregnancy].resource 1..1
* entry[pregnancy].resource only ZWPregnancyStatus
* entry[pregnancy].fullUrl 1..1
* entry[pregnancy].request 1..1
* entry[pregnancy].request obeys zw-order-entry-method
* entry[pregnancy] ^short = "Pregnancy status at time of ordering (ZW.LAB.A.DE13)"

* entry[breastfeeding].resource 1..1
* entry[breastfeeding].resource only ZWBreastfeedingStatus
* entry[breastfeeding].fullUrl 1..1
* entry[breastfeeding].request 1..1
* entry[breastfeeding].request obeys zw-order-entry-method
* entry[breastfeeding] ^short = "Breastfeeding status at time of ordering (ZW.LAB.A.DE14)"

Invariant: zw-order-entry-method
Description: "Order bundle entries are submitted as creates (POST) or idempotent client-id updates (PUT)."
Expression: "method = 'POST' or method = 'PUT'"
Severity: #error
