![godog-example-setup](https://github.com/pawelWritesCode/godog-http-api/actions/workflows/go.yml/badge.svg)

# Godog framework developed to test HTTP(s) API.

## Overview:

This repository contains skeleton that allow to write End-2-End tests for HTTP(s) API with use of framework [godog](https://github.com/cucumber/godog)
that implements 🥒[cucumber/gherkin](https://cucumber.io/docs/gherkin/) syntax using testing library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Why ?
This project **cuts initial time** & allows bootstrap e2e test framework with **plenty of
utility methods** in just few steps. Just grab it and write tests right away!

Benefits:
* [35+ well-documented, coupled in logical groups steps](https://github.com/pawelWritesCode/godog-http-api/wiki/Steps) useful for testing HTTP(s) API,
* support for using templated values as in [text/template](https://pkg.go.dev/text/template) package,
* support for querying nodes with different path engines ([oliveagle](https://github.com/oliveagle/jsonpath), [qjson](https://github.com/pawelWritesCode/qjson) - JSON, [go-yaml](https://github.com/goccy/go-yaml) - YAML, [antchfx](https://github.com/antchfx/xmlquery) - XML),
* support for sending _multipart/form-data_ forms with file in it,
* developed with debugging in mind,
* customisable through ability to [replace](https://github.com/pawelWritesCode/godog-http-api/blob/main/main_test.go#L53) utility services with your own implementations,
* supports [custom steps development](https://github.com/pawelWritesCode/godog-http-api/wiki/Steps-development).

## Example

#### [👆 Click here to see more tests using JSON/YAML/XML](https://github.com/pawelWritesCode/godog-http-api/blob/main/features/test_server)

```cucumber
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
```

## Documentation

See project ![hand pointing right](assets/gifs/hand-pointing-right.gif)  [wiki](https://github.com/pawelWritesCode/godog-http-api/wiki)  ![hand pointing left](assets/gifs/hand-pointing-left.gif)

* [Overview](https://github.com/pawelWritesCode/godog-http-api/wiki/Overview) - general information about project,
* [Project structure](https://github.com/pawelWritesCode/godog-http-api/wiki/Project-structure) - describes repository folder structure,
* [Setup](https://github.com/pawelWritesCode/godog-http-api/wiki/Set-up) - guide how to bootstrap repository on your machine,
* [Steps](https://github.com/pawelWritesCode/godog-http-api/wiki/Steps) - describes each available step and how to use it in tests,
* [Steps debugging](https://github.com/pawelWritesCode/godog-http-api/wiki/Steps-debugging) - how to debug tests,
* [Steps development](https://github.com/pawelWritesCode/godog-http-api/wiki/Steps-development) - how to create custom steps using utility services,
* [Usage](https://github.com/pawelWritesCode/godog-http-api/wiki/Usage) - how to run tests.