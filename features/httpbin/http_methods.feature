# https://httpbin.org/#/HTTP_Methods
Feature: Set of tests related with HTTP(s) methods.

  Background:
    Given I save "https://httpbin.org" as "HTTP_BIN_URL"

  Scenario: Test DELETE method.
    As API user,
    I would like to test ability to send DELETE method.

    When I send "DELETE" request to "{{.HTTP_BIN_URL}}/delete" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200

  Scenario: Test GET method.
  As API user,
  I would like to test ability to send GET method.

    When I send "GET" request to "{{.HTTP_BIN_URL}}/get" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200

  Scenario: Test PATCH method.
  As API user,
  I would like to test ability to send PATCH method.

    When I send "PATCH" request to "{{.HTTP_BIN_URL}}/patch" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200

  Scenario: Test POST method.
  As API user,
  I would like to test ability to send POST method.

    When I send "POST" request to "{{.HTTP_BIN_URL}}/post" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200

  Scenario: Test PUT method.
  As API user,
  I would like to test ability to send PUT method.

    When I send "PUT" request to "{{.HTTP_BIN_URL}}/put" with body and headers:
    """
    {
        "body": {
            "a": "b"
        },
        "headers": {}
    }
    """
    Then the response status code should be 200