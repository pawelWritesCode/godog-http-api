Feature: Replacing single user.
  User's CRUD API binary and it's documentation can be found in assets/test_server/ directory.
  It is simple web server with endpoints:
  - POST    /users            - creates new user
  - GET     /users            - retrieve all users
  - GET     /users/{user_id}  - retrieve user by user_id
  - PUT     /users/{user_id}  - replace user by user_id
  - DELETE  /users/{user_id}  - delete user by user_id

  Background:
  This section runs before every Scenario.
  Its main purpose is to generate random:
  - first name,
  - last name,
  - age.
  and save it under provided key in scenario cache.

    Given I generate a random word having from "5" to "15" ASCII characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" UNICODE characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range from "18" to "48" and save it as "RANDOM_AGE"

  Scenario: Replace user
  As application user
  I would like to store random user's data
  and then I would like to update those data
  and then I would like to obtain those data to prove successful replacement

    When I send "POST" request to "{{.MY_APP_URL}}/users" with body and headers:
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
    And the response body should be valid according to JSON schema "user/get_user.json"
    And I save from the last response JSON node "id" as "USER_ID"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain previously created user
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
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
    And the response body should be valid according to JSON schema "user/get_user.json"
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"

    Given I generate a random word having from "5" to "15" ASCII characters and save it as "NEW_USER_RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" UNICODE characters and save it as "NEW_USER_RANDOM_LAST_NAME"
    Given I generate a random int in the range from "18" to "48" and save it as "NEW_USER_RANDOM_AGE"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to replace user's data
    When I send "PUT" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
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

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain replaced user
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
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
    And the response body should be valid according to JSON schema "user/get_user.json"
    And the JSON node "firstName" should be "string" of value "{{.NEW_USER_RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.NEW_USER_RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.NEW_USER_RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"