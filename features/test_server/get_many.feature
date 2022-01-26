Feature: Fetching many users.
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

    Given I generate a random ASCII word in the range from "5" to "15" and save it as "RANDOM_FIRST_NAME"
    Given I generate a random UNICODE word in the range from "5" to "15" and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range from "18" to "48" and save it as "RANDOM_AGE"

  Scenario: Get users
  As application user
  I would like to store random user's data
  and then I would like to store another random user's data
  and then obtain those users

    #---------------------------------------------------------------------------------------------------
    # Create new user
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

    #---------------------------------------------------------------------------------------------------
    # We generate new user's data
    Given I generate a random ASCII word in the range from "5" to "15" and save it as "RANDOM_FIRST_NAME2"
    Given I generate a random UNICODE word in the range from "5" to "15" and save it as "RANDOM_LAST_NAME2"
    Given I generate a random int in the range from "18" to "48" and save it as "RANDOM_AGE2"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create second user
    When I send "POST" request to "{{.MY_APP_URL}}/users" with body and headers:
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
    And the response body should be valid according to JSON schema "user/get_user.json"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to fetch all users.
    When I send "GET" request to "{{.MY_APP_URL}}/users" with body and headers:
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
    # here we only check only node type, not its exact value
    And the JSON node "root" should be "slice"
    And the JSON node "root" should not be "nil"
