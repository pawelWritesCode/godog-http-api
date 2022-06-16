Feature: Fetching single user.
  Tests from this feature focus on fetching given user.

  Background:
    Given I generate a random word having from "5" to "15" of "english" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "polish" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate a random sentence having from "5" to "10" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"

  Scenario: Successfully get single user
  As application user
  I would like to create new account
  and then fetch it.

    #---------------------------------------------------------------------------------------------------
    # Create new user using generated data from Background section above.
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
    # We send HTTP(s) request to obtain previously created user.
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
    And time between last request and response should be less than or equal to "2s"
    And the "YAML" node "$.firstName" should be "string" of value "{{.RANDOM_FIRST_NAME}}"
    And the "YAML" node "$.lastName" should be "scalar" of value "{{.RANDOM_LAST_NAME}}"
    And the "YAML" node "$.age" should be "int" of value "{{.RANDOM_AGE}}"
    And the "YAML" node "$.id" should be "scalar" of value "{{.USER_ID}}"
    And the "YAML" node "$.description" should be "scalar" of value "{{.RANDOM_DESCRIPTION}}"
    And the "YAML" node "$.friendSince" should be "scalar" of value "{{.MEET_DATE.Format `2006-01-02T15:04:05Z`}}"

  Scenario: Unsuccessful attempt to fetch not existing user
    As application user
    I should not be able to fetch not existing account

    Given I save "111122223333" as "NOT_EXISTING_USER_ID"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with invalid userId path param
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.NOT_EXISTING_USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 404
    And the response body should have format "YAML"
    And the "YAML" response should have node "$.error"