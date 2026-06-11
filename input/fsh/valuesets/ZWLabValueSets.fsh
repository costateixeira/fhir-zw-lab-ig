// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Value Sets
// ─────────────────────────────────────────────────────────────────────────────

ValueSet: VSZWLabTests
Id: zw-lab-tests
Title: "ZW Laboratory Tests"
Description: "Value set of laboratory tests requestable in Zimbabwe (ZW.LAB.A.DE17)."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/lab-tests"
* ^status = #active
* include codes from system CSZWLabTests
x

ValueSet: VSZWSampleTypes
Id: zw-sample-types
Title: "ZW Specimen Types"
Description: "Value set of specimen/sample types used in Zimbabwe (ZW.LAB.A.DE53)."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/sample-types"
* ^status = #active
* include codes from system CSZWSampleTypes


ValueSet: VSZWReasonForTest
Id: zw-reason-for-test
Title: "ZW Reason for Test"
Description: "Value set of reasons for laboratory test requests in Zimbabwe (ZW.LAB.A.DE30)."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/reason-for-test"
* ^status = #active
* include codes from system CSZWReasonForTest


ValueSet: VSZWRejectionReasons
Id: zw-rejection-reasons
Title: "ZW Specimen Rejection Reasons"
Description: "Value set of specimen rejection reasons (ZW.LAB.A.DE88)."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/rejection-reasons"
* ^status = #active
* include codes from system CSZWRejectionReasons


ValueSet: VSZWReportReviewState
Id: zw-report-review-state
Title: "ZW Report Review State"
Description: "Value set of LIMS workflow states for a laboratory report (ZW.LAB.A.DE73)."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/report-review-state"
* ^status = #active
* include codes from system CSZWReportReviewState


ValueSet: VSZWLaboratories
Id: zw-laboratories
Title: "ZW National Laboratory List"
Description: "Value set of national laboratory identifiers in Zimbabwe."
* ^url = "http://mohcc.gov.zw/fhir/lab/ValueSet/laboratories"
* ^status = #active
* include codes from system CSZWLaboratories
