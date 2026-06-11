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
