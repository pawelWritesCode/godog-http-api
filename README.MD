![godog-example-setup](https://github.com/pawelWritesCode/godog-example-setup/actions/workflows/go.yml/badge.svg)

# Example godog setup with gdutils

## Overview:

This repository contains skeleton that allow to write End-2-End tests with use of framework [godog](https://github.com/cucumber/godog)
that implements 🥒[gherkin/cucumber](https://cucumber.io/docs/gherkin/) syntax using step library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Why ?
**No more** need for long and time-consuming framework setup. This project **cuts initial time** & allows setting up e2e test framework with **plenty of
utility methods** (for testing HTTP(s) API) in just few steps.

## Documentation & installation(setup)

See project **⭆** [wiki](https://github.com/pawelWritesCode/godog-example-setup/wiki) **⭅**

## Example

#### [Test suite](https://github.com/pawelWritesCode/godog-example-setup/blob/main/features/users_crud.feature)

```cucumber
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
```

#### Set-up (step-by-step guide -> [wiki](https://github.com/pawelWritesCode/godog-example-setup/wiki))

![Usage example](assets/gifs/usage_0.gif)