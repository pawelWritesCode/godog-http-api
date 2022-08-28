# https://httpbin.org/#/Request_inspection
# https://httpbin.org/#/Response_inspection
Feature: Set of tests related with HTTP(s) headers

  Background:
    Given I save "https://httpbin.org" as "HTTP_BIN_URL"

  Scenario: Prove headers are send successfully v1
    API works as following: When any header is send on /headers, response has status code 200 and
    contains headers as server received it in response body.

    When I send "GET" request to "{{.HTTP_BIN_URL}}/headers" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "X-Custom-Header":"X-Custom-Value",
            "Content-Type": "application/json+ld"
        }
    }
    """
    Then the response status code should be 200
    And the response should not have header "X-Custom-Header"
    But the response should have header "Content-Type"
    And the response should have header "Content-Type" of value "application/json"
    And the "JSON" node "$.headers.X-Custom-Header" should be "string" of value "X-Custom-Value"
    And the "JSON" node "$.headers.Content-Type" should be "string" of value "application/json+ld"

  Scenario: Prove headers are send successfully v2
    Given I prepare new "GET" request to "{{.HTTP_BIN_URL}}/headers" and save it as "REQUEST_GET_HEADERS"
    Given I set following headers for prepared request "REQUEST_GET_HEADERS":
    """
    {
        "X-Custom-Header":"X-Custom-Value",
        "Content-Type": "application/json+ld"
    }
    """
    When I send request "REQUEST_GET_HEADERS"
    Then the response status code should be 200
    And the response should not have header "X-Custom-Header"
    But the response should have header "Content-Type"
    And the response should have header "Content-Type" of value "application/json"
    And the "JSON" node "$.headers.X-Custom-Header" should be "string" of value "X-Custom-Value"
    And the "JSON" node "$.headers.Content-Type" should be "string" of value "application/json+ld"

  Scenario: Prove I can check incoming headers
  API works as following: When GET request is send to /response-headers with query params, response has headers
  the same as query params.

    When I send "GET" request to "{{.HTTP_BIN_URL}}/response-headers?content-type=application/json%2Bld" with body and headers:
    """
    {
        "body": {},
        "headers": {"X-Custom-Header":"X-Custom-Value"}
    }
    """
    Then the response status code should be 200
    And the response should not have header "X-Custom-Header"
    But the response should have header "Content-Type"
    And the response should have header "Content-Type" of value "application/json+ld"

  Scenario: Fetch default user-agent header
    As API user,
    I would like to prove, that User-Agent header, send with all requests has proper value.

    When I send "GET" request to "{{.HTTP_BIN_URL}}/user-agent" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the "JSON" node "$.user-agent" should be "string" of value "gdutils"