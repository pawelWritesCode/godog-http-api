Feature: Adding new user
  User's CRUD API binary and it's documentation can be found in assets/test_server/ directory.
  It is simple web server with endpoints:
  - POST    /users            - creates new user
  - GET     /users            - retrieve all users
  - GET     /users/{user_id}  - retrieve user by user_id
  - PUT     /users/{user_id}  - replace user by user_id
  - DELETE  /users/{user_id}  - delete user by user_id

  Background:
  This section runs before every Scenario.
  Its main purpose is to generate:
  - first name,
  - last name,
  - age.
  and save it under provided key in scenario cache.

    Given I save "application/json" as "CONTENT_TYPE_JSON"
    Given I generate a random word having from "5" to "10" of "russian" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"

  Scenario: Create user v1
  As application user
  I would like to store random user's data

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data (in Background section) to create new user.
    # Accessing saved data from scenario cache is done through template syntax from text/template package.
    # Docstring may be in YAML or JSON format and should have "body" and "headers" keys.
    When I send "POST" request to "{{.MY_APP_URL}}/users" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        },
        "headers": {
            "Content-Type": "{{.CONTENT_TYPE_JSON}}"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Length"
    And the response should have header "Content-Type" of value "{{.CONTENT_TYPE_JSON}}; charset=UTF-8"
    And the response body should have format "JSON"
    And time between last request and response should be less than or equal to "2s"

    # uncommenting next line will print last HTTP(s) response body to console
#    Given I print last response body

    # This waiting is unnecessary, just added for demonstration
    And I wait "2ms"

    #---------------------------------------------------------------------------------------------------
    # We validate response body with json schema from assets/test_server/doc/schema/user/get_user.json
    # environment variable GODOG_JSON_SCHEMA_DIR from .env file should contain relative path to schemas dir,
    # then step argument may be: relative or full OS path
    And the response body should be valid according to JSON schema "user/get_user.json"
    # or URL pointing at JSON schema
    And the response body should be valid according to JSON schema "https://raw.githubusercontent.com/pawelWritesCode/godog-example-setup/main/assets/test_server/doc/schema/user/get_user.json"
    # or raw schema definition passed in Docstring
    And the response body should be valid according to JSON schema:
    """
    {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "title": "create user",
      "description": "Valid response from create user endpoint",
      "type": "object"
    }
    """

    #---------------------------------------------------------------------------------------------------
    # Here, we check assertions against response body
    #
    # node expression should be pattern valid to one of following libraries:
    # https://github.com/pawelWritesCode/qjson
	# https://github.com/oliveagle/jsonpath
	#
    # - data[0].firstName or $.data[0].firstName  - {"data": [{"firstName": "abc", "lastName": "cdf", age:30}, {...}]}
    # - root[0].size                              - [{"name": "Lublin", "size": 10000}, {"name": "Warsaw", "size": 20000}]
    # - firstName or $.firstName                  - {"firstName": "abc", "lastName": "cdf", age:30},
    #
    # data type should be one of: string|int|float|bool
    #
    # node value may be fixed or obtained from cache using syntax from go text/template package
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "$.lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"

  Scenario: Create new user v2.
  As application user
  I would like to store random user's data

    #---------------------------------------------------------------------------------------------------
    # At first we prepare new HTTP(s) request and save it scenario cache under key "CREATE_USER"
    Given I prepare new "POST" request to "{{.MY_APP_URL}}/users" and save it as "CREATE_USER"

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
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}}
        }
    """
    #---------------------------------------------------------------------------------------------------
    # Finally, we send prepared request "CREATE_USER".
    # Uncommenting lines next to step "I send request "CREATE_USER" will turn on debug mode for a while.

    #Given I start debug mode
    When I send request "CREATE_USER"
    #Given I stop debug mode

    #---------------------------------------------------------------------------------------------------
    # From now on, we make some assertions against response from "CREATE_USER" request
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/json; charset=UTF-8"
    And the response body should have format "JSON"
    And time between last request and response should be less than or equal to "2s"
    And the response body should be valid according to JSON schema "user/get_user.json"
