![godog-example-setup](https://github.com/pawelWritesCode/godog-example-setup/actions/workflows/go.yml/badge.svg)

# Example godog setup with gdutils

## Overview:

This repository contains skeleton that allow to write End-2-End tests with use of framework [godog](https://github.com/cucumber/godog)
that implements 🥒[gherkin/cucumber](https://cucumber.io/docs/gherkin/) syntax using step library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Why ?
**No more** need for long and time-consuming framework setup. This project **cuts initial time** & allows setting up e2e test framework with **plenty of
utility methods** (for testing HTTP(s) API) in just few steps.

Benefits:
* **short time** from **[set-up](https://github.com/pawelWritesCode/godog-example-setup/wiki/Set-up#clone-repository) to writing** actual BDD tests (see demonstration gif below ⬇)
* [25+ well-documented methods](https://github.com/pawelWritesCode/godog-example-setup/blob/main/main_test.go#L94) useful for testing HTTP(s) API
* methods are coupled in logical groups (data generation, assertions, sending HTTP(s) request, debugging, ...)

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
  Its main purpose is to generate random:
  - first name,
  - last name,
  - age.
  and save it under provided key in scenario cache.

    # RANDOM_FIRST_NAME will be composed of only ASCII runes for example it may be: abc3@-
    Given I generate a random word having from "5" to "15" of "ASCII" characters and save it as "RANDOM_FIRST_NAME"
    # RANDOM_LAST_NAME will be composed of ASCII + UNICODE runes for example it may be: 💄x1ś⚥
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
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
    # environment variable GODOG_JSON_SCHEMA_DIR from .env file should contain relative path to schemas dir,
    # then step argument may be: relative/full OS path
    And the response body should be valid according to JSON schema "user/get_user.json"
    # or URL with JSON schema
    And the response body should be valid according to JSON schema "https://raw.githubusercontent.com/pawelWritesCode/godog-example-setup/main/assets/test_server/doc/schema/user/get_user.json"
    # or raw schema definition
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
    # node argument should be pattern valid to one of following libraries:
    # https://github.com/pawelWritesCode/qjson
	# https://github.com/oliveagle/jsonpath
	#
    # - data.user[0].firstName or $.data.user[0].firstName    - {"data": [{"firstName": "abc", "lastName": "cdf", age:30}, {...}]}
    # - root[0].city[1].size                                  - [{"name": "Lublin", "size": 10000}, {"name": "Warsaw", "size": 20000}]
    # - firstName or $.firstName                              - {"firstName": "abc", "lastName": "cdf", age:30},
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