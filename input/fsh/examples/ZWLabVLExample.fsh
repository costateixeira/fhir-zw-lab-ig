// ─────────────────────────────────────────────────────────────────────────────
// End-to-end example: Viral Load Plasma order and result
// Scenario: Impilo EHR (facility) orders a Viral Load Plasma test for an
//           HIV-positive patient. The order is routed via OpenHIM to the
//           National Virology Laboratory. The LIMS returns the result.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Receiving Laboratory ────────────────────────────────────────────────────

Instance: example-national-virology-lab
InstanceOf: ZWLaboratory
Title: "Example — National Virology Laboratory"
Description: "Example Organization instance for the National Virology Laboratory (ZWLPAR001)."
Usage: #example
* identifier[nationalLabCode].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-laboratories"
* identifier[nationalLabCode].value = "ZWLPAR001"
* type[+].coding[+].system = "http://terminology.hl7.org/CodeSystem/organization-type"
* type[=].coding[=].code = #other
* type[=].coding[=].display = "Other"
* type[=].text = "Laboratory"
* name = "National Virology Laboratory"


// ─── Ordering Facility ───────────────────────────────────────────────────────

Instance: example-order-facility
InstanceOf: ZWFacility
Title: "Example — Ordering Health Facility"
Description: "Example Location instance for a primary health facility placing the order."
Usage: #example
* name = "Harare City Health Clinic"
* status = #active


// ─── Patient ─────────────────────────────────────────────────────────────────

Instance: example-zw-lab-patient
InstanceOf: ZWLabPatient
Title: "Example — ZW Lab Patient"
Description: "Example Patient for the Viral Load end-to-end scenario."
Usage: #example
* extension[dateOfBirthEstimated].valueBoolean = false
* identifier[ehrPatientId].system = "http://mohcc.gov.zw/fhir/lab/identifier/ehr-patient-id"
* identifier[ehrPatientId].value = "EHR-ZW-00123"
* identifier[artNumber].system = "http://mohcc.gov.zw/fhir/lab/identifier/art-number"
* identifier[artNumber].value = "HRE/2019/005678"
* name[+].given[+] = "Rutendo"
* name[=].family = "Moyo"
* birthDate = "1988-04-15"
* gender = #female
* maritalStatus.coding[+].system = "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus"
* maritalStatus.coding[=].code = #M
* maritalStatus.coding[=].display = "Married"


// ─── Specimen ────────────────────────────────────────────────────────────────

Instance: example-zw-specimen-plasma
InstanceOf: ZWSpecimen
Title: "Example — Blood Plasma Specimen"
Description: "Example blood plasma specimen for the Viral Load Plasma order."
Usage: #example
* identifier[clientSampleId].system = "http://mohcc.gov.zw/fhir/lab/identifier/client-sample-id"
* identifier[clientSampleId].value = "ZW-SPEC-2024-00456"
* type.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-sample-types"
* type.coding[=].code = #LST006
* type.coding[=].display = "Blood Plasma"
* subject = Reference(example-zw-lab-patient)
* collection.collectedDateTime = "2024-03-15T08:30:00+02:00"
* status = #available


// ─── ServiceRequest ──────────────────────────────────────────────────────────

Instance: example-zw-service-request-vl
InstanceOf: ZWLabServiceRequest
Title: "Example — Viral Load Plasma Service Request"
Description: "Example ServiceRequest for a Viral Load Plasma test (baseline monitoring)."
Usage: #example
* status = #active
* intent = #order
* code.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-lab-tests"
* code.coding[=].code = #LTT0013
* code.coding[=].display = "Viral Load Plasma"
* reasonCode[+].coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-reason-for-test"
* reasonCode[=].coding[=].code = #routine
* reasonCode[=].coding[=].display = "Routine"
* subject = Reference(example-zw-lab-patient)
* specimen[+] = Reference(example-zw-specimen-plasma)
* locationReference[+] = Reference(example-order-facility)
* authoredOn = "2024-03-15T08:00:00+02:00"


// ─── Task (order push from Impilo → OpenHIM/SHR → LIMS) ─────────────────────

Instance: example-zw-lab-task-order
InstanceOf: ZWLabTask
Title: "Example — Lab Order Task"
Description: "Task sent by Impilo EHR to the LIMS via OpenHIM representing the lab order (step 1 of the HIE transaction flow)."
Usage: #example
* status = #requested
* intent = #order
* for = Reference(example-zw-lab-patient)
* basedOn[+] = Reference(example-zw-service-request-vl)
* location = Reference(example-order-facility)
* restriction.recipient[+] = Reference(example-national-virology-lab)
* input[pregnant].type.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[pregnant].type.coding[=].code = #pregnant
* input[pregnant].valueBoolean = false
* input[breastfeeding].type.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[breastfeeding].type.coding[=].code = #breastfeeding
* input[breastfeeding].valueBoolean = false
* input[artStartDate].type.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[artStartDate].type.coding[=].code = #art-start-date
* input[artStartDate].valueDate = "2019-07-01"
* input[regimen].type.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-task-input-type"
* input[regimen].type.coding[=].code = #regimen
* input[regimen].valueString = "TDF/3TC/DTG"
* authoredOn = "2024-03-15T08:00:00+02:00"


// ─── Order Transaction Bundle (order push from Impilo → OpenHIM/SHR) ─────────

Instance: example-zw-lab-order-bundle
InstanceOf: ZWLabOrderBundle
Title: "Example — Viral Load Order Transaction Bundle"
Description: "Transaction Bundle submitted by the Lab Order Placer (Impilo EHR) to the Lab Order Repository (SHR): order Task, ServiceRequest, Patient and Specimen (step 1 of the HIE transaction flow)."
Usage: #example
* type = #transaction
* entry[task].fullUrl = "urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0001"
* entry[task].resource = example-zw-lab-task-order
* entry[task].request.method = #POST
* entry[task].request.url = "Task"
* entry[serviceRequest].fullUrl = "urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0002"
* entry[serviceRequest].resource = example-zw-service-request-vl
* entry[serviceRequest].request.method = #POST
* entry[serviceRequest].request.url = "ServiceRequest"
* entry[patient].fullUrl = "urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0003"
* entry[patient].resource = example-zw-lab-patient
* entry[patient].request.method = #POST
* entry[patient].request.url = "Patient"
* entry[patient].request.ifNoneExist = "identifier=http://mohcc.gov.zw/fhir/lab/identifier/ehr-patient-id|EHR-ZW-00123"
* entry[specimen][+].fullUrl = "urn:uuid:5a3952e2-1c1a-4a6b-9c5d-0b6e9a3e0004"
* entry[specimen][=].resource = example-zw-specimen-plasma
* entry[specimen][=].request.method = #POST
* entry[specimen][=].request.url = "Specimen"


// ─── Observation (result from LIMS) ──────────────────────────────────────────

Instance: example-zw-vl-observation
InstanceOf: ZWLabResultObservation
Title: "Example — Viral Load Result Observation"
Description: "Example HIV Viral Load Plasma result (copies/mL) returned by the LIMS."
Usage: #example
* status = #final
* category[+].coding[+].system = "http://terminology.hl7.org/CodeSystem/observation-category"
* category[=].coding[=].code = #laboratory
* code.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-lab-tests"
* code.coding[=].code = #LTT0013
* code.coding[=].display = "Viral Load Plasma"
* code.coding[+].system = "http://loinc.org"
* code.coding[=].code = #20447-9
* code.coding[=].display = "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by NAA with probe detection"
* subject = Reference(example-zw-lab-patient)
* basedOn[+] = Reference(example-zw-service-request-vl)
* specimen = Reference(example-zw-specimen-plasma)
* valueQuantity.value = 48
* valueQuantity.unit = "copies/mL"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #/mL
* method.text = "RT-PCR"
* effectiveDateTime = "2024-03-18T14:00:00+02:00"


// ─── DiagnosticReport (result report push from LIMS → OpenHIM/SHR) ───────────

Instance: example-zw-vl-diagnostic-report
InstanceOf: ZWLabDiagnosticReport
Title: "Example — Viral Load Diagnostic Report"
Description: "DiagnosticReport for the Viral Load Plasma result, pushed by the LIMS to the Shared Health Record (step 5 of the HIE transaction flow)."
Usage: #example
* extension[reportReviewState].valueCodeableConcept.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-report-review-state"
* extension[reportReviewState].valueCodeableConcept.coding[=].code = #verified
* extension[reportReviewState].valueCodeableConcept.coding[=].display = "Verified"
* status = #final
* category[+].coding[+].system = "http://terminology.hl7.org/CodeSystem/v2-0074"
* category[=].coding[=].code = #MB
* category[=].coding[=].display = "Microbiology"
* code.coding[+].system = "http://mohcc.gov.zw/fhir/lab/CodeSystem/zw-lab-tests"
* code.coding[=].code = #LTT0013
* code.coding[=].display = "Viral Load Plasma"
* subject = Reference(example-zw-lab-patient)
* basedOn[+] = Reference(example-zw-service-request-vl)
* specimen[+] = Reference(example-zw-specimen-plasma)
* effectiveDateTime = "2024-03-18T14:00:00+02:00"
* issued = "2024-03-18T16:30:00+02:00"
* performer[+] = Reference(example-national-virology-lab)
* resultsInterpreter[+] = Reference(example-national-virology-lab)
* result[+] = Reference(example-zw-vl-observation)


// ─── Composition (signed-off report document header) ────────────────────────

Instance: example-zw-vl-composition
InstanceOf: ZWLabReportComposition
Title: "Example — Viral Load Report Composition"
Description: "Composition for the signed-off Viral Load report document. The legal attester records the laboratory sign-off."
Usage: #inline
* status = #final
* type = $LNC#11502-2 "Laboratory report"
* subject = Reference(example-zw-lab-patient)
* date = "2024-03-18T16:30:00+02:00"
* author[+] = Reference(example-national-virology-lab)
* title = "Laboratory Result Report — Viral Load Plasma"
* custodian = Reference(example-national-virology-lab)
* attester[legalAttester].mode = #legal
* attester[legalAttester].time = "2024-03-18T16:30:00+02:00"
* attester[legalAttester].party = Reference(example-national-virology-lab)
* section[labResults].title = "Laboratory Results"
* section[labResults].code = $LNC#30954-2 "Relevant diagnostic tests/laboratory data note"
* section[labResults].entry[+] = Reference(example-zw-vl-diagnostic-report)


// ─── Document Bundle (signed-off snapshot pushed to the SHR) ─────────────────

Instance: example-zw-vl-report-bundle
InstanceOf: ZWLabReportBundle
Title: "Example — Viral Load Report Document Bundle"
Description: "Signed-off snapshot document of the Viral Load Plasma result, assembled by the LIMS for exchange via OpenHIM/SHR."
Usage: #example
* identifier.system = "http://mohcc.gov.zw/fhir/lab/identifier/report-document"
* identifier.value = "ZW-LABDOC-2024-00456"
* type = #document
* timestamp = "2024-03-18T16:35:00+02:00"
* entry[composition].fullUrl = "http://mohcc.gov.zw/fhir/lab/Composition/example-zw-vl-composition"
* entry[composition].resource = example-zw-vl-composition
* entry[diagnosticReport][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/DiagnosticReport/example-zw-vl-diagnostic-report"
* entry[diagnosticReport][=].resource = example-zw-vl-diagnostic-report
* entry[patient].fullUrl = "http://mohcc.gov.zw/fhir/lab/Patient/example-zw-lab-patient"
* entry[patient].resource = example-zw-lab-patient
* entry[observation][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/Observation/example-zw-vl-observation"
* entry[observation][=].resource = example-zw-vl-observation
* entry[specimen][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/Specimen/example-zw-specimen-plasma"
* entry[specimen][=].resource = example-zw-specimen-plasma
* entry[serviceRequest][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/ServiceRequest/example-zw-service-request-vl"
* entry[serviceRequest][=].resource = example-zw-service-request-vl
* entry[organization][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/Organization/example-national-virology-lab"
* entry[organization][=].resource = example-national-virology-lab
* entry[location][+].fullUrl = "http://mohcc.gov.zw/fhir/lab/Location/example-order-facility"
* entry[location][=].resource = example-order-facility
