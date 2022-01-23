Feature: Test for User's CRUD.
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

    Given I generate a random string in the range from "5" to "15" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string in the range from "5" to "15" with unicode characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random int in the range from "18" to "48" and save it as "RANDOM_AGE"

  Scenario: Create user v1
  As application user
  I would like to store random user's data

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data
    # Notice, we use pre-generated values(from Background section above)
    # using go templates syntax from text/template package.
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

    #---------------------------------------------------------------------------------------------------
    # We validate response body with json schema from assets/test_server/doc/schema/user/get_user.json
    # Environment variable GODOG_JSON_SCHEMA_DIR from .env file should contain path to schemas dir
    # That is why we only need to pass relative path to json schema
    And the response body should be valid according to JSON schema "user/get_user.json"
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"

  Scenario: Create new user v1.
  As application user
  I would like to store random user's data

    #---------------------------------------------------------------------------------------------------
    # At first we prepare new HTTP(s) request and save it scenario cache under key "CREATE_USER"
    Given I prepare new "POST" request to "{{.MY_APP_URL}}/users" and save it as "CREATE_USER"

    #---------------------------------------------------------------------------------------------------
    # Secondly, we set Content-Type header for "CREATE_USER" request
    Given I set following headers for prepared request "CREATE_USER":
    """
    {
        "Content-Type": "application/json"
    }
    """

    #---------------------------------------------------------------------------------------------------
    # Lastly, we define request body for "CREATE_USER" request
    # Notice, we use pre-generated values(from Background section above)
    # using go templates syntax from text/template package.
    Given I set following body for prepared request "CREATE_USER":
    """
        {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        }
    """
    #---------------------------------------------------------------------------------------------------
    # Finally, we send prepared request "CREATE_USER"
    When I send request "CREATE_USER"

    #---------------------------------------------------------------------------------------------------
    # From now on, we make some assertions against response from "CREATE_USER" request
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have type "JSON"

    #---------------------------------------------------------------------------------------------------
    # We validate response body with json schema from assets/test_server/doc/schema/user/get_user.json
    # Environment variable GODOG_JSON_SCHEMA_DIR from .env file should contain path to schemas dir
    # That is why we only need to pass relative path to json schema
    And the response body should be valid according to JSON schema "user/get_user.json"
