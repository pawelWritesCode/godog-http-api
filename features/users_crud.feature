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

    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME"
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

  Scenario: Get single user
  As application user
  I would like to store random user's data
  and then obtain this data

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create new user
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

    #---------------------------------------------------------------------------------------------------
    # Here, we check assertions against response body
    #
    # node argument should be pattern valid to qjson library, for example:
    # - data.user[0].firstName    - {"data": [{"firstName": "abc", "lastName": "cdf", age:30}, {...}]}
    # - root[0].city[1].size      - [{"name": "Lublin", "size": 10000}, {"name": "Warsaw", "size": 20000}]
    # - firstName                 - {"firstName": "abc", "lastName": "cdf", age:30},
    #
    # data type should be one of: string|int|float|bool
    #
    # node value may be fixed or obtained from cache using syntax from go text/template package
    And the JSON node "firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the JSON node "lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the JSON node "age" should be "int" of value "{{.RANDOM_AGE}}"
    And the JSON node "id" should be "int" of value "{{.USER_ID}}"

  Scenario: Get users
  As application user
  I would like to store random user's data
  and then I would like to store another random user's data
  and then obtain those users

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create new user
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
    And the response body should be valid according to JSON schema "user/get_user.json"

    #---------------------------------------------------------------------------------------------------
    # We generate new user's data
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_FIRST_NAME2"
    Given I generate a random string of length "10" without unicode characters and save it as "RANDOM_LAST_NAME2"
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
    And the JSON node "root" should be "slice"
    And the JSON node "root" should not be "nil"

  Scenario: Remove user
  As application user
  I would like to store random user's data
  and then I would like to remove user's data

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create new user
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
    And the response status code should be 201
    Then the response body should have type "JSON"
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

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to delete user of id hold under cache key "USER_ID"
    When I send "DELETE" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    And the response status code should be 204

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to prove there is no more user of id "USER_ID"
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}" with body and headers:
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
  As application user
  I would like to store random user's data
  and then I would like to update those data
  and then I would like to obtain those data to prove successful replacement

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create new user
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

    Given I generate a random string of length "10" without unicode characters and save it as "NEW_USER_RANDOM_FIRST_NAME"
    Given I generate a random string of length "10" without unicode characters and save it as "NEW_USER_RANDOM_LAST_NAME"
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