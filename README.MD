![godog-example-setup](https://github.com/pawelWritesCode/godog-example-setup/actions/workflows/go.yml/badge.svg)

# Example godog framework setup with step library gdutils

## Overview:

This repository contains skeleton that allow to write End-2-End tests with use of framework [godog](https://github.com/cucumber/godog)
that implements 🥒[gherkin/cucumber](https://cucumber.io/docs/gherkin/) syntax using step library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Why ?
**No more** need for long and time-consuming framework setup. This project **cuts initial time** & allows setting up e2e test framework with **plenty of
utility methods** (for testing HTTP(s) API) in just few steps.

Benefits:
* **short time** from **[set-up](https://github.com/pawelWritesCode/godog-example-setup/wiki/Set-up#clone-repository) to writing** actual E2E tests (see gif below ⬇),
* [25+ well-documented, coupled in logical groups methods](https://github.com/pawelWritesCode/godog-example-setup/wiki/Steps) useful for testing HTTP(s) API,
* support for using templated values as in [text/template](https://pkg.go.dev/text/template) package,
* support for querying JSON tree with two json-path engines ([oliveagle](https://github.com/oliveagle/jsonpath), [qjson](https://github.com/pawelWritesCode/qjson)),
* very customisable (ability to [inject](https://github.com/pawelWritesCode/godog-example-setup/blob/main/main_test.go#L58) your own implementation of services),
* friendly for custom steps development because of [exported internal services](https://github.com/pawelWritesCode/gdutils/blob/master/state.go#L18).

## Example

#### [Test suite](https://github.com/pawelWritesCode/godog-example-setup/blob/main/features/)

```cucumber
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
```

## Documentation & installation(setup)

See project **⭆** [wiki](https://github.com/pawelWritesCode/godog-example-setup/wiki) **⭅**

![Usage example](assets/gifs/usage_0.gif)