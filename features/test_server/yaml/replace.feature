Feature: Replacing single user account.
  Tests from this feature focus on replacing existing user account with another.

  Background:
    Given I generate a random word having from "5" to "15" of "ASCII" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate a random sentence having from "5" to "10" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"

  Scenario: Successfully update user account
  As application user
  I would like to create new account
  and then I would like to update this account
  and then I would like to obtain this account to prove successful update.

    #---------------------------------------------------------------------------------------------------
    # Create new user using generated data from Background section above
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=yaml" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": "{{.RANDOM_DESCRIPTION}}",
            "friendSince": "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/x-yaml"
    And the response body should have format "YAML"
    And time between last request and response should be less than or equal to "2s"
    And I save from the last response "YAML" node "$.id" as "USER_ID"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain previously created user
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/x-yaml"
    And the response body should have format "YAML"
    And the "YAML" node "$.firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the "YAML" node "$.lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the "YAML" node "$.age" should be "int" of value "{{.RANDOM_AGE}}"
    And the "YAML" node "$.id" should be "int" of value "{{.USER_ID}}"
    And the "YAML" node "$.description" should be "string" of value "{{.RANDOM_DESCRIPTION}}"
    And the "YAML" node "$.friendSince" should be "string" of value "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"

    #---------------------------------------------------------------------------------------------------
    # Here, we generate new user data.
    Given I generate a random word having from "5" to "15" of "ASCII" characters and save it as "NEW_USER_RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "NEW_USER_RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "NEW_USER_RANDOM_AGE"
    Given I generate a random sentence having from "1" to "17" of "english" words and save it as "NEW_USER_RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "340h" in time and save it as "NEW_USER_MEET_DATE"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to replace user
    When I send "PUT" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.NEW_USER_RANDOM_FIRST_NAME}}",
            "lastName": "{{.NEW_USER_RANDOM_LAST_NAME}}",
            "age": {{.NEW_USER_RANDOM_AGE}},
            "description": "{{.NEW_USER_RANDOM_DESCRIPTION}}",
            "friendSince": "{{.NEW_USER_MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And time between last request and response should be less than or equal to "2s"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain replaced user
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/x-yaml"
    And the response body should have format "YAML"
    And the "YAML" node "$.firstName" should be "string" of value "{{.NEW_USER_RANDOM_FIRST_NAME}}"
    And the "YAML" node "$.lastName" should be "string" of value "{{.NEW_USER_RANDOM_LAST_NAME}}"
    And the "YAML" node "$.age" should be "int" of value "{{.NEW_USER_RANDOM_AGE}}"
    And the "YAML" node "$.id" should be "int" of value "{{.USER_ID}}"
    And the "YAML" node "$.description" should be "string" of value "{{.NEW_USER_RANDOM_DESCRIPTION}}"
    And the "YAML" node "$.friendSince" should be "string" of value "{{.NEW_USER_MEET_DATE.Format `2006-01-02T15:04:05Z`}}"

  Scenario: Unsuccessful attempt to replace user account with invalid data
    As application user
    I should not be able to update existing account with invalid data

    #---------------------------------------------------------------------------------------------------
    # Create new user using generated data from Background section above
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=yaml" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": "{{.RANDOM_DESCRIPTION}}",
            "friendSince": "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/x-yaml"
    And the response body should have format "YAML"
    And time between last request and response should be less than or equal to "2s"
    And I save from the last response "YAML" node "$.id" as "USER_ID"

    #---------------------------------------------------------------------------------------------------
    # Here, we generate new user data.
    Given I generate a random "int" in the range from "18" to "48" and save it as "NEW_USER_RANDOM_AGE"
    Given I generate current time and travel "backward" "340h" in time and save it as "NEW_USER_MEET_DATE"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to replace user
    When I send "PUT" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {
            "firstName": "a",
            "lastName": "b",
            "age": {{.NEW_USER_RANDOM_AGE}},
            "description": 2,
            "friendSince": "{{.NEW_USER_MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 400
    And the response body should have format "YAML"
    And the "YAML" response should have node "$.error"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to obtain previously created user and prove nothing has changed
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/x-yaml"
    And the response body should have format "YAML"
    And the "YAML" node "$.firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the "YAML" node "$.lastName" should be "string" of value "{{.RANDOM_LAST_NAME}}"
    And the "YAML" node "$.age" should be "int" of value "{{.RANDOM_AGE}}"
    And the "YAML" node "$.id" should be "int" of value "{{.USER_ID}}"
    And the "YAML" node "$.description" should be "string" of value "{{.RANDOM_DESCRIPTION}}"
    And the "YAML" node "$.friendSince" should be "string" of value "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"

  Scenario: Unsuccessful attempt to replace not existing user
  As application user
  I would like to be not able to modify not existing account

    Given I save "111122223333" as "NOT_EXISTING_USER_ID"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to replace not existing user account
    When I send "PUT" request to "{{.MY_APP_URL}}/users/{{.NOT_EXISTING_USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {
            "firstName": "{{.RANDOM_FIRST_NAME}}",
            "lastName": "{{.RANDOM_LAST_NAME}}",
            "age": {{.RANDOM_AGE}},
            "description": "{{.RANDOM_DESCRIPTION}}",
            "friendSince": "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 400
    And the response body should have format "YAML"
    And the "YAML" response should have node "$.error"
