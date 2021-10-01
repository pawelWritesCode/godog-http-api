Feature: Test users CRUD

  Scenario: Create user
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And I save from the last response JSON node "id" as "USER_ID"

  Scenario: Get user

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And I save from the last response JSON node "id" as "USER_ID"

    When I send "GET" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"

  Scenario: Get users

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME1"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME1"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE1"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME1}}",
            "lastName": "{{.RANDOM_LAST_NAME1}}",
            "age": {{.RANDOM_AGE1}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And I save from the last response JSON node "id" as "USER_ID"

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME2"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME2"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE2"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME2}}",
            "lastName": "{{.RANDOM_LAST_NAME2}}",
            "age": {{.RANDOM_AGE2}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And I save from the last response JSON node "id" as "USER_ID"

    When I send "GET" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the JSON node "root" should be "slice"
    And the JSON node "root" should not be "nil"

  Scenario: Remove user

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response body should have type "JSON"
    And the response status code should be 201
    And I save from the last response JSON node "id" as "USER_ID"

    When I send "GET" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"

    When I send "DELETE" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    And the response status code should be 204

    When I send "GET" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response body should have type "JSON"
    And the response status code should be 404

  Scenario: Replace user

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range "18" to "48" and save it as "RANDOM_AGE"
    When I send "POST" request to "http://127.0.0.1:1234/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And I save from the last response JSON node "id" as "USER_ID"

    When I send "GET" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"

    Given I generate a random string of length "10" without unicode characters and save it as "NEW_USER_RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "NEW_USER_RANDOM_LAST_NAME"
    Given I generate a random int in the range "18" to "48" and save it as "NEW_USER_RANDOM_AGE"
    When I send "PUT" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.NEW_USER_RANDOM_FIRST_NAME}}",
            "lastName": "{{.NEW_USER_RANDOM_LAST_NAME}}",
            "age": {{.NEW_USER_RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"

    When I send "GET" request to "http://127.0.0.1:1234/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"
    And the JSON node "firstName" should be "string" of value "{{.NEW_USER_RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.NEW_USER_RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.NEW_USER_RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"