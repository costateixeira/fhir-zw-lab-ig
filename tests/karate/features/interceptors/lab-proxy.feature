@ignore
Feature: Lab-system conformance proxy - order fulfiller + result provider (pass-through)

  Point a real lab system (LIMS) at this proxy ONCE and leave it there. Every
  request is forwarded to the real server, so the system works normally — and
  every push is also validated against the ZW profiles on the way through.
  The verdict comes back in the X-ZW-Validation response header and a ZWPROXY
  log line; patient identifiers seen in pushes are recorded for the session
  auditor. Scenarios are matched top-down, first match wins.

  Background:
    * configure cors = true
    * def System = Java.type('java.lang.System')
    * def target = System.getProperty('target', 'http://173.212.195.88/fhir')
    * def profiles =
      """
      {
        Bundle: 'http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-report-bundle',
        DiagnosticReport: 'http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-diagnostic-report'
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

  # ── Lab submits the signed report document ──
  Scenario: methodIs('post') && pathMatches('/Bundle')
    * def body = request
    * eval recordPatients(body)
    Given url target
    And path 'Bundle', '$validate'
    And param profile = profiles.Bundle
    And request body
    When method post
    * def verdict = errorCount(response)
    * karate.log('ZWPROXY|push|report document|' + verdict + ' errors')
    Given url target
    And path 'Bundle'
    And request body
    When method post
    * def responseHeaders = { 'Access-Control-Expose-Headers': 'X-ZW-Validation', 'X-ZW-Validation': '#(verdict + " errors vs " + profiles.Bundle)' }

  # ── Lab submits a DiagnosticReport ──
  Scenario: methodIs('post') && pathMatches('/DiagnosticReport')
    * def body = request
    Given url target
    And path 'DiagnosticReport', '$validate'
    And param profile = profiles.DiagnosticReport
    And request body
    When method post
    * def verdict = errorCount(response)
    * karate.log('ZWPROXY|push|DiagnosticReport|' + verdict + ' errors')
    Given url target
    And path 'DiagnosticReport'
    And request body
    When method post
    * def responseHeaders = { 'Access-Control-Expose-Headers': 'X-ZW-Validation', 'X-ZW-Validation': '#(verdict + " errors vs " + profiles.DiagnosticReport)' }

  # ── Lab pulls orders: must be patient-scoped, then forwarded ──
  Scenario: methodIs('get') && pathMatches('/ServiceRequest') && (requestParams.subject != null || requestParams.patient != null || requestParams['patient.identifier'] != null)
    * karate.log('ZWPROXY|pull|ServiceRequest|ok')
    Given url target
    And path 'ServiceRequest'
    And params requestParams
    When method get

  Scenario: methodIs('get') && pathMatches('/ServiceRequest')
    * karate.log('ZWPROXY|pull|ServiceRequest|REJECTED unscoped')
    * def responseStatus = 400
    * def response = { resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'required', diagnostics: 'order query must be scoped to a patient (subject or patient parameter)' }] }

  # ── any other GET (Task work lists etc.): forward transparently ──
  Scenario: methodIs('get')
    * karate.log('ZWPROXY|pull|' + requestUri + '|forwarded')
    Given url target + '/' + requestUri
    And params requestParams
    When method get

  # ── any other PUT (e.g. Task claims): forward transparently ──
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
