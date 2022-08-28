# https://httpbin.org/#/Response_formats
Feature: Set of tests related with different data formats

  Background:
    Given I save "https://httpbin.org" as "HTTP_BIN_URL"

  Scenario: Gzipped json
    When I send "GET" request to "{{.HTTP_BIN_URL}}/gzip" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "gzipped" should be "boolean" of value "true"

    #TODO: nie działa wykrywanie plain text
  Scenario: utf8
    When I send "GET" request to "{{.HTTP_BIN_URL}}/encoding/utf8" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
#    And the response body should have format "plain text"

  Scenario: json
    When I send "GET" request to "{{.HTTP_BIN_URL}}/json" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"

  # TODO: nie działa wykrywanie XML
  Scenario: xml
    When I send "GET" request to "{{.HTTP_BIN_URL}}/xml" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "XML"