// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Workflow Actors
// The six conformance roles in the Zimbabwe laboratory ordering and results
// workflow. Roles are played by systems in the national architecture:
//   - Impilo EHR        → Lab Order Placer + Lab Result Consumer
//   - SHR (via OpenHIM) → Lab Order Repository + Lab Result Repository
//   - Senaite LIMS      → Lab Order Fulfiller + Lab Result Provider
// ActorDefinition is an R5 resource permitted in R4 IGs (SUSHI >= 3.19).
// ─────────────────────────────────────────────────────────────────────────────

Instance: lab-order-placer
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Order Placer"
Description: "System that creates laboratory orders and submits them to the Lab Order Repository."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-placer"
* name = "LabOrderPlacer"
* title = "Lab Order Placer"
* status = #draft
* type = #system
* description = "System that captures a laboratory test order for a patient and pushes it to the Lab Order Repository as a ZWLabOrderBundle transaction (FHIR `POST` of a transaction Bundle carrying ZWLabTask, ZWLabServiceRequest, ZWLabPatient and ZWSpecimen). In the Zimbabwe national architecture this role is played by the Impilo EHR (transaction ① — order push)."
* documentation = "Obligations: SHALL submit orders conforming to the ZWLabOrderBundle profile; SHALL populate the order Task with status `requested` and the receiving laboratory as `restriction.recipient`."

Instance: lab-order-repository
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Order Repository"
Description: "System that stores submitted laboratory orders and makes them available for retrieval."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-repository"
* name = "LabOrderRepository"
* title = "Lab Order Repository"
* status = #draft
* type = #system
* description = "System that accepts ZWLabOrderBundle transactions from Lab Order Placers, validates and stores the contained order resources, and exposes them to Lab Order Fulfillers via FHIR search (Task, ServiceRequest). In the Zimbabwe national architecture this role is played by the Shared Health Record (HAPI FHIR), fronted by OpenHIM."
* documentation = "Obligations: SHALL support FHIR transaction processing of ZWLabOrderBundle submissions; SHALL reject payloads that do not conform to the profile; SHALL support search of Task by status and owner/recipient, and of ServiceRequest by patient."

Instance: lab-order-fulfiller
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Order Fulfiller"
Description: "Laboratory system that retrieves orders from the Lab Order Repository and performs the requested testing."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-fulfiller"
* name = "LabOrderFulfiller"
* title = "Lab Order Fulfiller"
* status = #draft
* type = #system
* description = "Laboratory system that polls the Lab Order Repository for orders directed to it (FHIR search on Task by recipient and status — transaction ② — order pull), claims them by updating Task status, and performs the requested testing. In the Zimbabwe national architecture this role is played by the Senaite LIMS."
* documentation = "Obligations: SHALL query the Lab Order Repository for Tasks addressed to its laboratory; SHALL update the claimed Task status following the FHIR workflow state machine (requested → accepted/rejected → in-progress → completed)."

Instance: lab-result-provider
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Result Provider"
Description: "System that produces laboratory results and pushes them to the Lab Result Repository."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-provider"
* name = "LabResultProvider"
* title = "Lab Result Provider"
* status = #draft
* type = #system
* description = "System that assembles the signed-off laboratory result as a ZWLabReportBundle document (ZWLabReportComposition, ZWLabDiagnosticReport, ZWLabResultObservation) and pushes it to the Lab Result Repository (FHIR `POST /Bundle` — result push). In the Zimbabwe national architecture this role is played by the Senaite LIMS."
* documentation = "Obligations: SHALL submit result documents conforming to the ZWLabReportBundle profile; SHALL include the legal attester sign-off (ZW.LAB.A.DE80/DE82) before submission; SHALL reference the originating ZWLabServiceRequest from the DiagnosticReport."

Instance: lab-result-repository
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Result Repository"
Description: "System that stores laboratory result reports and makes them available for retrieval."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-repository"
* name = "LabResultRepository"
* title = "Lab Result Repository"
* status = #draft
* type = #system
* description = "System that accepts ZWLabReportBundle documents from Lab Result Providers, stores them intact, and exposes results to Lab Result Consumers via FHIR search (DiagnosticReport, Bundle). In the Zimbabwe national architecture this role is played by the Shared Health Record (HAPI FHIR), fronted by OpenHIM."
* documentation = "Obligations: SHALL persist submitted report documents whole (as Bundle resources); SHALL reject payloads that do not conform to the ZWLabReportBundle profile; SHALL support search of DiagnosticReport by patient and based-on ServiceRequest."

Instance: lab-result-consumer
InstanceOf: ActorDefinition
Usage: #definition
Title: "Lab Result Consumer"
Description: "System that retrieves laboratory results from the Lab Result Repository for display and clinical use."
* url = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-consumer"
* name = "LabResultConsumer"
* title = "Lab Result Consumer"
* status = #draft
* type = #system
* description = "System that queries the Lab Result Repository for results for its patients (FHIR search on DiagnosticReport / report Bundles — result pull) and presents them to clinical users. In the Zimbabwe national architecture this role is played by the Impilo EHR."
* documentation = "Obligations: SHALL retrieve results by patient identifier; SHOULD correlate retrieved DiagnosticReports back to the originating ServiceRequest/Task placed by the Lab Order Placer."
