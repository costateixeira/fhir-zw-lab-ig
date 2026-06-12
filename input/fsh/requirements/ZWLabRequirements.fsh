// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Workflow Requirements
// One Requirements resource per workflow transaction, linking the actor pair
// involved to the profiles and FHIR interactions they must support.
// Requirements is an R5 resource permitted in R4 IGs (SUSHI >= 3.19).
// ─────────────────────────────────────────────────────────────────────────────

Instance: zw-lab-order-push
InstanceOf: Requirements
Usage: #definition
Title: "Order Push Requirements"
Description: "Requirements for submitting a laboratory order from the Lab Order Placer to the Lab Order Repository (transaction ①, push)."
* url = "http://mohcc.gov.zw/fhir/lab/Requirements/zw-lab-order-push"
* name = "ZWLabOrderPushRequirements"
* title = "Order Push Requirements"
* status = #draft
* description = "The Lab Order Placer submits a new laboratory order to the Lab Order Repository as a FHIR transaction."
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-placer"
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-repository"
* statement[+].key = "order-push-01"
* statement[=].label = "Order bundle conformance"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Order Placer SHALL submit orders as a transaction Bundle conforming to the [ZWLabOrderBundle](StructureDefinition-zw-lab-order-bundle.html) profile, carrying a ZWLabTask, ZWLabServiceRequest, ZWLabPatient and any ZWSpecimen resources."
* statement[+].key = "order-push-02"
* statement[=].label = "Transaction processing"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Order Repository SHALL process the submission as a FHIR transaction (`POST [base]`) and return a `transaction-response` Bundle with success status for every entry."
* statement[+].key = "order-push-03"
* statement[=].label = "Validation of submissions"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Order Repository SHALL reject submissions that do not conform to the ZWLabOrderBundle profile with an HTTP 4xx response carrying an OperationOutcome."

Instance: zw-lab-order-pull
InstanceOf: Requirements
Usage: #definition
Title: "Order Pull Requirements"
Description: "Requirements for retrieval of laboratory orders by the Lab Order Fulfiller from the Lab Order Repository (transaction ②, pull)."
* url = "http://mohcc.gov.zw/fhir/lab/Requirements/zw-lab-order-pull"
* name = "ZWLabOrderPullRequirements"
* title = "Order Pull Requirements"
* status = #draft
* description = "The Lab Order Fulfiller retrieves orders directed to its laboratory from the Lab Order Repository and claims them."
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-fulfiller"
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-order-repository"
* statement[+].key = "order-pull-01"
* statement[=].label = "Order search"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Order Repository SHALL support searching Task by `status` and ServiceRequest by `subject`, returning `searchset` Bundles whose entries conform to [ZWLabTask](StructureDefinition-zw-lab-task.html) and [ZWLabServiceRequest](StructureDefinition-zw-lab-service-request.html)."
* statement[+].key = "order-pull-02"
* statement[=].label = "Order claiming"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Order Fulfiller SHALL claim an order by updating the Task status following the FHIR workflow state machine (`requested` → `accepted`/`rejected` → `in-progress` → `completed`), and the Lab Order Repository SHALL support Task update."

Instance: zw-lab-result-push
InstanceOf: Requirements
Usage: #definition
Title: "Result Push Requirements"
Description: "Requirements for submitting a signed-off laboratory result report from the Lab Result Provider to the Lab Result Repository (result push)."
* url = "http://mohcc.gov.zw/fhir/lab/Requirements/zw-lab-result-push"
* name = "ZWLabResultPushRequirements"
* title = "Result Push Requirements"
* status = #draft
* description = "The Lab Result Provider pushes the signed-off laboratory result report document to the Lab Result Repository."
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-provider"
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-repository"
* statement[+].key = "result-push-01"
* statement[=].label = "Report document conformance"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Result Provider SHALL submit results as a document Bundle conforming to the [ZWLabReportBundle](StructureDefinition-zw-lab-report-bundle.html) profile, including a legally attested ZWLabReportComposition (ZW.LAB.A.DE80/DE82)."
* statement[+].key = "result-push-02"
* statement[=].label = "Document storage"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Result Repository SHALL store the submitted report document whole (`POST [base]/Bundle`) so the signed-off snapshot remains retrievable as submitted."
* statement[+].key = "result-push-03"
* statement[=].label = "Order linkage"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The contained ZWLabDiagnosticReport SHALL reference the originating ZWLabServiceRequest via `basedOn`."

Instance: zw-lab-result-pull
InstanceOf: Requirements
Usage: #definition
Title: "Result Pull Requirements"
Description: "Requirements for retrieval of laboratory results by the Lab Result Consumer from the Lab Result Repository (result pull)."
* url = "http://mohcc.gov.zw/fhir/lab/Requirements/zw-lab-result-pull"
* name = "ZWLabResultPullRequirements"
* title = "Result Pull Requirements"
* status = #draft
* description = "The Lab Result Consumer retrieves laboratory results for its patients from the Lab Result Repository."
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-consumer"
* actor[+] = "http://mohcc.gov.zw/fhir/lab/ActorDefinition/lab-result-repository"
* statement[+].key = "result-pull-01"
* statement[=].label = "Result search"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Result Repository SHALL support searching DiagnosticReport by `subject`/`patient` and by `based-on`, returning `searchset` Bundles whose entries conform to [ZWLabDiagnosticReport](StructureDefinition-zw-lab-diagnostic-report.html)."
* statement[+].key = "result-pull-02"
* statement[=].label = "Report document retrieval"
* statement[=].conformance[+] = #SHALL
* statement[=].requirement = "The Lab Result Repository SHALL allow retrieval of stored report documents (Bundle read/search by `identifier`) as submitted by the Lab Result Provider."
* statement[+].key = "result-pull-03"
* statement[=].label = "Order correlation"
* statement[=].conformance[+] = #SHOULD
* statement[=].requirement = "The Lab Result Consumer SHOULD correlate retrieved results back to the originating order it placed (ServiceRequest/Task) for display against the request."
