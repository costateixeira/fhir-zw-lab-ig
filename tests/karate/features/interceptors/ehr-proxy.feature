@ignore
Feature: EHR conformance proxy - order placer + results consumer (pass-through)

  Point a real EHR at this proxy ONCE and leave it there. Every request is
  forwarded to the real server, so the system works normally — and every
  push is also validated against the ZW profiles on the way through. The
  verdict comes back in the X-ZW-Validation response header and a ZWPROXY
  log line; patient identifiers seen in pushes are recorded for the
  session auditor. Scenarios are matched top-down, first match wins.

  Background:
    * configure cors = true
    * def System = Java.type('java.lang.System')
    * def target = System.getProperty('target', 'http://173.212.195.88/fhir')
    * def profiles =
      """
      {
        Bundle: 'http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-order-bundle',
        ServiceRequest: 'http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-service-request'
      }
      """
    * def errorCount = function(oo){ return karate.jsonPath(oo, "$.issue[?(@.severity=='error' || @.severity=='fatal')]").length }
    * def seenPatients = {}
    * def recordPatients =
      """
      function(body) {
        var entries = (body && body.resourceType == 'Bundle') ? (body.entry || []) : [{ resource: body }];
        for (var i = 0; i < entries.length; i++) {
          var r = entries[i].resource;
          if (r && r.resourceType == 'Patient' && r.identifier) {
            for (var j = 0; j < r.identifier.length; j++) {
              var ident = r.identifier[j];
              if (ident.system && ident.value) seenPatients[ident.system + '|' + ident.value] = true;
            }
          }
        }
        karate.write(Object.keys(seenPatients).join('\n'), 'session-patients.txt');
      }
      """

  # ── EHR pushes the order transaction Bundle to the root ──
  Scenario: methodIs('post') && pathMatches('/') && request.resourceType == 'Bundle'
    * def body = request
    * eval recordPatients(body)
    # 1) score it
    Given url target
    And path 'Bundle', '$validate'
    And param profile = profiles.Bundle
    And request body
    When method post
    * def verdict = errorCount(response)
    * karate.log('ZWPROXY|push|order bundle|' + verdict + ' errors')
    # 2) pass it through — the client gets the real server response
    Given url target
    And request body
    When method post
    * def responseHeaders = { 'X-ZW-Validation': '#(verdict + " errors vs " + profiles.Bundle)' }

  # ── EHR places a single ServiceRequest ──
  Scenario: methodIs('post') && pathMatches('/ServiceRequest')
    * def body = request
    Given url target
    And path 'ServiceRequest', '$validate'
    And param profile = profiles.ServiceRequest
    And request body
    When method post
    * def verdict = errorCount(response)
    * karate.log('ZWPROXY|push|ServiceRequest|' + verdict + ' errors')
    Given url target
    And path 'ServiceRequest'
    And request body
    When method post
    * def responseHeaders = { 'X-ZW-Validation': '#(verdict + " errors vs " + profiles.ServiceRequest)' }

  # ── EHR consumes results: must be patient-scoped, then forwarded ──
  Scenario: methodIs('get') && pathMatches('/DiagnosticReport') && (requestParams.subject != null || requestParams.patient != null || requestParams['patient.identifier'] != null)
    * karate.log('ZWPROXY|pull|DiagnosticReport|ok')
    Given url target
    And path 'DiagnosticReport'
    And params requestParams
    When method get

  Scenario: methodIs('get') && pathMatches('/DiagnosticReport')
    * karate.log('ZWPROXY|pull|DiagnosticReport|REJECTED unscoped')
    * def responseStatus = 400
    * def response = { resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'required', diagnostics: 'result query must be scoped to a patient (subject or patient parameter)' }] }

  # ── any other GET: forward transparently ──
  Scenario: methodIs('get')
    * karate.log('ZWPROXY|pull|' + requestUri + '|forwarded')
    Given url target + '/' + requestUri
    And params requestParams
    When method get

  # ── any other PUT (e.g. Patient/Location upserts): forward transparently ──
  Scenario: methodIs('put')
    * def body = request
    * eval recordPatients(body)
    * karate.log('ZWPROXY|push|PUT ' + requestUri + '|forwarded')
    Given url target + '/' + requestUri
    And request body
    When method put

  # ── any other POST: forward transparently ──
  Scenario: methodIs('post')
    * def body = request
    * eval recordPatients(body)
    * karate.log('ZWPROXY|push|POST ' + requestUri + '|forwarded')
    Given url target + '/' + requestUri
    And request body
    When method post

  Scenario:
    * karate.proceed(target)
