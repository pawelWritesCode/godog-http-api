Feature: Removing user
  Test from this feature focus on removing user account from app.

  Background:
    Given I generate a random word having from "5" to "15" of "ASCII" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate a random sentence having from "5" to "10" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"

  Scenario: Successfully remove user
  As application user
  I would like to create new account
  and then I would like to remove it.

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
    And time between last request and response should be less than or equal to "2s"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to delete user of id hold under cache key "USER_ID"
    When I send "DELETE" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
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
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response body should have format "YAML"
    And the response status code should be 404

  Scenario: Unsuccessful attempt to remove not existing user
    As application user
    I should not be able to remove not existing account

    Given I save "111122223333" as "NOT_EXISTING_USER_ID"

    #---------------------------------------------------------------------------------------------------
    # Unsuccessful attempt to delete user because of invalid path param userId
    When I send "DELETE" request to "{{.MY_APP_URL}}/users/{{.NOT_EXISTING_USER_ID}}?format=yaml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    And the response status code should be 400
    Then the response body should have format "YAML"
    And the "YAML" response should have node "$.error"
    And the "YAML" node "$.error" should match regExp "could not find in database user of id .*"