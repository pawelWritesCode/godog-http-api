Feature: Adding new user
  User's CRUD API binary and it's documentation can be found in assets/test_server/ dir. It is web server with endpoints
  - POST    /users                  - creates new user
  - GET     /users                  - retrieve all users
  - GET     /users/{user_id}        - retrieve user by user_id
  - PUT     /users/{user_id}        - replace user by user_id
  - DELETE  /users/{user_id}        - delete user by user_id
  - POST    /users/{user_id}/avatar - add avatar for user of user_id

  Background:
  This section runs before every Scenario. Its main purpose is to generate random user data
  and save it under provided key in scenario cache.

    Given I generate a random word having from "5" to "10" of "ASCII" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "3" to "7" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random sentence having from "3" to "4" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"
    Given I save "application/json" as "CONTENT_TYPE_JSON"

  Scenario: Successfully create user v1
  As application user
  I would like to create new account

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request using pre-generated data to create new user.
    # Accessing saved data from scenario cache is done through template syntax from text/template package.
    # Docstring may be in YAML or JSON format and should have "body" and "headers" keys.
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=json" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "doe-{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": "{{.RANDOM_DESCRIPTION}}",
            "friendSince": "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "{{.CONTENT_TYPE_JSON}}"
        }
    }
    """
    Then the response status code should not be 200
    But the response status code should be 201
    And the response should not have header "Set-Cookie"
    But the response should have header "Content-Length"
    And the response should have header "Content-Type" of value "{{.CONTENT_TYPE_JSON}}; charset=UTF-8"
    And the response body should not have format "plain text"
    But the response body should have format "JSON"
    And time between last request and response should be less than or equal to "2s"

    # uncommenting next line will print last HTTP(s) response body to console
#    Given I print last response body

    # This waiting is unnecessary, just added for demonstration
    And I wait "2ms"

    #---------------------------------------------------------------------------------------------------
    # We validate response body with schema from assets/test_server/doc/schema/user/user.json
    # step argument may be: relative (see .env variable GODOG_JSON_SCHEMA_DIR)
    And the response body should be valid according to schema "user/user.json"
    # or full OS path
    And the response body should be valid according to schema "{{.CWD}}/assets/test_server/doc/schema/user/user.json"
    # or URL pointing at schema
    And the response body should be valid according to schema "https://raw.githubusercontent.com/pawelWritesCode/godog-http-api/main/assets/test_server/doc/schema/user/user.json"
    # or raw schema definition passed in Docstring
    And the response body should be valid according to schema:
    """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "create user",
        "description": "Valid response from create user endpoint",
        "type": "object"
    }
    """
    # also nodes may be validated against schema
    And the "JSON" node "firstName" should be valid according to schema:
    """
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "first name",
        "type": "string"
    }
    """
    # here is used qjson "json-path" syntax to find JSON node
    And the "JSON" node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    # here is used oliveagle "json-path" syntax to find JSON node
    And the "JSON" node "$.lastName" should be "string" of value "doe-{{.RANDOM_LAST_NAME}}"
    # here is used regExp acceptable by standard go package "regExp"
    And the "JSON" node "lastName" should not match regExp "smith-.*"
    But the "JSON" node "lastName" should match regExp "doe-.*"
    And the "JSON" node "age" should not be "string"
    But the "JSON" node "$.age" should be "int"
    And the "JSON" node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the "JSON" node "description" should be "string" of value "{{.RANDOM_DESCRIPTION}}"
    # here date is formatted according to one of available formats from standard go package "time"
    And the "JSON" node "friendSince" should be "string" of value "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"

  Scenario: Successfully create user v2.
  As application user
  I would like to create new account

    #---------------------------------------------------------------------------------------------------
    # At first we prepare new HTTP(s) request and save it scenario cache under key "CREATE_USER"
    Given I prepare new "POST" request to "{{.MY_APP_URL}}/users?format=json" and save it as "CREATE_USER"

    #---------------------------------------------------------------------------------------------------
    # Secondly, we set Content-Type header for "CREATE_USER" request.
    # Docstring may be in YAML or JSON format.
    Given I set following headers for prepared request "CREATE_USER":
    """
    ---
    Content-Type: application/json
    """

    #---------------------------------------------------------------------------------------------------
    # Next, we set csrf_token cookie for "CREATE_USER" request.
    # Docstring may be in YAML or JSON format
    Given I set following cookies for prepared request "CREATE_USER":
    """
    [
        {
            "name": "csrf_token",
            "value": "this_cookie_is_unnecessary_just_added_for_demonstration"
        }
    ]
    """

    #---------------------------------------------------------------------------------------------------
    # Lastly, we define request body for "CREATE_USER" request
    # Notice, we use pre-generated values(from Background section above)
    # using go templates syntax from text/template package.
    Given I set following body for prepared request "CREATE_USER":
    """
        {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "doe-{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": "{{.RANDOM_DESCRIPTION}}",
            "friendSince": "{{.MEET_DATE.Format "2006-01-02T15:04:05Z"}}"
        }
    """
    #---------------------------------------------------------------------------------------------------
    # Finally, we send prepared request "CREATE_USER".
    # Uncommenting lines next to step "I send request "CREATE_USER" will turn on debug mode for a while.

#    Given I start debug mode
    When I send request "CREATE_USER"
#    Given I stop debug mode

    #---------------------------------------------------------------------------------------------------
    # From now on, we make some assertions against response from "CREATE_USER" request
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have format "JSON"
    And time between last request and response should be less than or equal to "2s"
    And the response body should be valid according to schema "user/user.json"

  Scenario: Unsuccessful attempt to create new user due to invalid request body
    As application user
    I should not be able to create new account using invalid data

    #---------------------------------------------------------------------------------------------------
    # Request body's field description have type int instead of string
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=json" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "doe-{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": 2,
            "friendSince": "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "{{.CONTENT_TYPE_JSON}}"
        }
    }
    """
    Then the response status code should not be 201
    But the response status code should be 400
    And the response body should have format "JSON"
    And the response body should be valid according to schema "general_error.json"