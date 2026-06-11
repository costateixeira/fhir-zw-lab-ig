// ─────────────────────────────────────────────────────────────────────────────
// ZW Lab Code Systems
// Source: Lab workflow integration.xlsx (Tests, Sample Types, Labs sheets)
//         Zimbabwe_lab_data_dictionary_2_0.xlsx — ZW.LAB.A sheet
// ─────────────────────────────────────────────────────────────────────────────

CodeSystem: CSZWLabTests
Id: zw-lab-tests
Title: "ZW Laboratory Tests"
Description: "National code list for laboratory tests ordered in Zimbabwe (ZW.LAB.A.DE17)."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #LTT001  "Bacteriology - Smear"        "Bacteriological smear microscopy."
* #LTT002  "Microscopy"                  "General microscopy examination."
* #LTT003  "Biochemical Tests"           "Biochemistry / chemistry panel."
* #LTT004  "COVID-19"                    "SARS-CoV-2 detection test."
* #LTT005  "Culture (Bacteriology)"      "Bacterial culture and sensitivity."
* #LTT006  "GeneXpert"                   "Xpert MTB/RIF or similar cartridge-based assay."
* #LTT007  "LPA"                         "Line Probe Assay for drug-resistance testing."
* #LTT008  "Routine Histological Examination" "Routine histopathology."
* #LTT009  "TB Culture"                  "Mycobacterial culture."
* #LTT0012 "Viral Load DBS"              "HIV viral load from dried blood spot sample."
* #LTT0013 "Viral Load Plasma"           "HIV viral load from plasma sample."


CodeSystem: CSZWSampleTypes
Id: zw-sample-types
Title: "ZW Specimen Types"
Description: "National code list for specimen/sample types collected in Zimbabwe (ZW.LAB.A.DE53)."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #LST001  "Fluid"                               "Body fluid (unspecified)."
* #LST002  "Aspirate"                            "Aspirated specimen."
* #LST003  "Oropharyngeal Swab"                  "Swab from the oropharynx."
* #LST004  "Buffy Coat"                          "Buffy coat fraction of blood."
* #LST005  "Buccal Swab"                         "Swab from the buccal mucosa."
* #LST006  "Blood Plasma"                        "Plasma fraction of blood."
* #LST007  "Dried Blood Spot"                    "Dried blood spot (DBS) card."
* #LST008  "Semen"                               "Seminal fluid."
* #LST009  "Throat Swab"                         "Swab from the throat."
* #LST0010 "Saliva"                              "Saliva specimen."
* #LST0011 "Nasopharyngeal Swab"                 "Nasopharyngeal swab."
* #LST0012 "Biopsy"                              "Tissue biopsy specimen."
* #LST0013 "Nasopharyngeal/Oropharyngeal Swab"   "Combined NP/OP swab."
* #LST0014 "Blood Serum"                         "Serum fraction of blood."
* #LST0015 "Urine"                               "Urine specimen."
* #LST0016 "Whole Blood"                         "Whole blood specimen."
* #LST0017 "Sputum"                              "Expectorated sputum."
* #LST0018 "Red Blood Cells"                     "Packed red blood cells."


CodeSystem: CSZWReasonForTest
Id: zw-reason-for-test
Title: "ZW Reason for Test"
Description: "Coded reasons for laboratory test requests in Zimbabwe (ZW.LAB.A.DE30)."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #routine                        "Routine"                                    "Routine monitoring."
* #target-clinical-failure        "Target Clinical Failure"                    "Suspected clinical treatment failure."
* #targeted-immunological-failure "Targeted Immunological Failure"             "Suspected immunological treatment failure."
* #repeat-after-adherence         "Repeat After Enhanced Adherence Counselling" "Repeat test after adherence counselling."
* #baseline-viral-load            "Baseline Viral Load"                        "Baseline measurement at ART initiation."
* #confirmation-of-treatment      "Confirmation of Treatment"                  "Confirmation of treatment response."
* #failure-repeat-vl-3m           "Failure — Repeat VL at 3 Months"           "Suspected failure; repeat at 3 months."
* #single-drug-substitution       "Single Drug Substitution"                   "Following a single drug substitution."
* #pregnant-mother                "Pregnant Mother"                            "Pregnant woman monitoring."
* #lactating-mother               "Lactating Mother"                           "Lactating/breastfeeding mother monitoring."
* #eid-initial-birth              "EID: Initial at Birth"                      "Early infant diagnosis at birth."
* #eid-initial-6-8wks             "EID: Initial at 6–8 Weeks"                 "Early infant diagnosis at 6–8 weeks."
* #eid-initial-gt2m               "EID: Initial at >2 Months"                 "Early infant diagnosis at >2 months."
* #eid-repeat-6wks                "EID: Repeat at 6 Weeks"                    "EID repeat test at 6 weeks."
* #eid-repeat-9m                  "EID: Repeat at 9 Months"                   "EID repeat test at 9 months."
* #eid-positive-rdt-gt18m         "EID: Following Positive RDT at >18 Months" "EID after positive rapid test at >18 months."
* #eid-confirmatory               "EID: Confirmatory (After First EID Positive)" "Confirmatory EID after first positive result."
* #postnatal-routine-1st          "Routine 1st Post-natal Tests"              "First routine post-natal testing."
* #symptomatic-child              "Symptomatic Child"                          "Testing of a symptomatic infant/child."
* #post-weaning                   "Post Weaning Test"                          "Test following cessation of breastfeeding."
* #other                          "Other"                                      "Other reason."


CodeSystem: CSZWRejectionReasons
Id: zw-rejection-reasons
Title: "ZW Specimen Rejection Reasons"
Description: "Reasons a specimen was rejected by the laboratory (ZW.LAB.A.DE88)."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #no-identification       "Specimen Lacked Proper Identification"   "Sample container not labelled."
* #form-mismatch           "Mismatching Form and Specimen"           "Request form does not match the specimen."
* #insufficient-quantity   "Insufficient Specimen Quantity"          "Sample volume too small."
* #no-request-form         "Request Form Not Submitted"              "No accompanying request form."
* #no-specimen             "Specimen Not Submitted"                  "Request form received without specimen."
* #contamination           "Cross Contamination"                     "Specimen contaminated."
* #humidity-indicator      "Sample Collected on Humidity Indicator"  "DBS collected on humidity indicator card."
* #clotted                 "Clotted Blood"                           "Blood specimen is clotted."
* #too-old                 "Specimen Too Old"                        "Specimen transit time exceeded."
* #haemolysed              "Haemolysed"                              "Haemolysis detected."
* #other                   "Other"                                   "Other rejection reason."


CodeSystem: CSZWReportReviewState
Id: zw-report-review-state
Title: "ZW Report Review State"
Description: "LIMS workflow/review state for a laboratory report (ZW.LAB.A.DE73)."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #pending        "Pending"          "Result entry in progress; not yet submitted."
* #received       "Received"         "Specimen received by the laboratory."
* #to-be-verified "To Be Verified"   "Result awaiting verification."
* #verified       "Verified"         "Result verified by authorised person."
* #published      "Published"        "Report published and available to the requester."


CodeSystem: CSZWTaskInputType
Id: zw-task-input-type
Title: "ZW Lab Task Input Type"
Description: "Type codes for Task.input slices on the ZWLabTask order profile."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #pregnant       "Pregnant"       "Patient is pregnant at time of ordering."
* #breastfeeding  "Breastfeeding"  "Patient is breastfeeding at time of ordering."
* #art-start-date "ART Start Date" "Date the patient started ART."
* #regimen        "Regimen"        "Current ART regimen."


CodeSystem: CSZWTaskOutputType
Id: zw-task-output-type
Title: "ZW Lab Task Output Type"
Description: "Type codes for Task.output slices on the ZWLabTask order profile."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #diagnostic-report "Diagnostic Report" "Reference to the DiagnosticReport produced by the LIMS."


CodeSystem: CSZWLaboratories
Id: zw-laboratories
Title: "ZW National Laboratory List"
Description: "National identifiers for public-health laboratories in Zimbabwe."
* ^status = #active
* ^experimental = false
* ^content = #complete
* ^caseSensitive = true
* #ZWLHRE002  "National Microbiology Reference Laboratory (NMRL)"
* #ZW000A0C   "BRIDH Laboratory"
* #ZW04030A   "Kadoma Laboratory"
* #ZW03050A   "Marondera Provincial Laboratory"
* #ZW02010A   "Bindura Provincial Laboratory"
* #ZWL000AOD  "AiBst Laboratory"
* #ZWL000001  "BRTI Laboratory"
* #ZWLPAR001  "National Virology Laboratory"
* #ZW01050A   "Mutare Provincial Laboratory"
* #ZW08050A   "Masvingo Provincial Laboratory"
* #ZW07030A   "Gweru Provincial Laboratory"
* #ZW06030A   "Gwanda Provincial Laboratory"
* #ZW05040B   "St Lukes Laboratory"
* #ZW04050A   "Chinhoyi Provincial Hospital Laboratory"
* #ZW05030A   "Victoria Falls Laboratory"
