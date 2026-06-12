@lab-order-placer
Feature: Lab Order Placer — pushes laboratory orders to the Lab Order Repository

  Transaction ① (order push). The Karate suite plays the Lab Order Placer
  (Impilo EHR in the national architecture); the server under test plays the
  Lab Order Repository. Payload profile: ZWLabOrderBundle.

  Background:
    * url shrUrl

  @validation
  Scenario: A conformant order bundle passes profile validation
    * def built = call read('common/build-order.feature')
    Given path 'Bundle', '$validate'
    And param profile = profiles.orderBundle
    And request built.orderBundle
    When method post
    Then status 200
    And match response.resourceType == 'OperationOutcome'
    And match response.issue[*].severity !contains 'fatal'
    And match response.issue[*].severity !contains 'error'

  Scenario: A valid order is accepted as a FHIR transaction
    * def built = call read('common/build-order.feature')
    Given request built.orderBundle
    When method post
    Then status 200
    And match response.resourceType == 'Bundle'
    And match response.type == 'transaction-response'
    And match each response.entry[*].response.status == '#regex 2\\d\\d.*'

  @validation
  Scenario: A non-conformant order bundle is flagged by profile validation
    # ServiceRequest without a test code, Patient without the EHR identifier
    * def order = read('../data/order-bundle-invalid.json')
    Given path 'Bundle', '$validate'
    And param profile = profiles.orderBundle
    And request order
    When method post
    Then assert responseStatus == 200 || responseStatus == 422
    And match response.resourceType == 'OperationOutcome'
    And match response.issue[*].severity contains 'error'

  @pending-validation
  Scenario: A non-conformant order is rejected by the repository (write validation)
    # order-push-03 — needs validation-on-write on the server (live on the ZW
    # sandbox; the permissive local default accepts everything, hence the tag).
    * def order = read('../data/order-bundle-invalid.json')
    Given request order
    When method post
    Then assert responseStatus >= 400 && responseStatus < 500
    And match response.resourceType == 'OperationOutcome'
    And match response.issue[*].severity contains 'error'

  @workshop
  Scenario: TODO (workshop) — resubmitting the same order does not create duplicates
    # Hint: add identifiers to Task/ServiceRequest and use conditional create
    # (entry.request.ifNoneExist) like the Patient entry does.
