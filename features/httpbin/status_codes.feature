# https://httpbin.org/#/Status_codes
Feature: Set of tests related with status codes

  Background:
    Given I save "https://httpbin.org" as "HTTP_BIN_URL"

  Scenario: Test 2xx status code
    When I send "DELETE" request to "{{.HTTP_BIN_URL}}/status/200" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200

    When I send "POST" request to "{{.HTTP_BIN_URL}}/status/201" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 201

    When I send "GET" request to "{{.HTTP_BIN_URL}}/status/202" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 202

    When I send "PUT" request to "{{.HTTP_BIN_URL}}/status/203" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 203

    When I send "PATCH" request to "{{.HTTP_BIN_URL}}/status/206" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 206

  Scenario: Test 3xx status code
    When I send "DELETE" request to "{{.HTTP_BIN_URL}}/status/300" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 300

    When I send "GET" request to "{{.HTTP_BIN_URL}}/status/329" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 329

    When I send "PUT" request to "{{.HTTP_BIN_URL}}/status/305" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 305

    When I send "PATCH" request to "{{.HTTP_BIN_URL}}/status/306" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 306

  Scenario: Test 4xx status code
    When I send "DELETE" request to "{{.HTTP_BIN_URL}}/status/400" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 400

    When I send "POST" request to "{{.HTTP_BIN_URL}}/status/401" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 401

    When I send "GET" request to "{{.HTTP_BIN_URL}}/status/402" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 402

    When I send "PUT" request to "{{.HTTP_BIN_URL}}/status/403" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 403

    When I send "PATCH" request to "{{.HTTP_BIN_URL}}/status/406" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 406

  Scenario: Test 5xx status code
    When I send "DELETE" request to "{{.HTTP_BIN_URL}}/status/500" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 500

    When I send "POST" request to "{{.HTTP_BIN_URL}}/status/501" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 501

    When I send "GET" request to "{{.HTTP_BIN_URL}}/status/502" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 502

    When I send "PUT" request to "{{.HTTP_BIN_URL}}/status/503" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 503

    When I send "PATCH" request to "{{.HTTP_BIN_URL}}/status/506" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 506