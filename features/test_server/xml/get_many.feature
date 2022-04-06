Feature: Fetching many users.
  Tests from this feature focus on fetching many users at once.

  Background:
    Given I generate a random word having from "5" to "15" of "english" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "polish" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate a random sentence having from "5" to "10" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"

  Scenario: Get users
  As application user
  I would like to create new account
  and then I would like to create another account
  and then I would like to fetch those accounts.

    #---------------------------------------------------------------------------------------------------
    # Create new user using generated data from Background section above
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=xml" with body and headers:
    """
    {
        "body": {
            "firstName": "a",
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
    And the response should have header "Content-Type" of value "application/xml; charset=UTF-8"
    And the response body should have format "XML"
    And time between last request and response should be less than or equal to "2s"

    #---------------------------------------------------------------------------------------------------
    # We generate second user's data
    Given I generate a random word having from "5" to "15" of "polish" characters and save it as "RANDOM_LAST_NAME2"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE2"
    Given I generate a random sentence having from "5" to "10" of "english" words and save it as "RANDOM_DESCRIPTION2"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE2"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request with pre-generated data to create second user
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=xml" with body and headers:
    """
    {
        "body": {
            "firstName": "b",
            "lastName": "{{.RANDOM_LAST_NAME2}}",
            "age": {{.RANDOM_AGE2}},
            "description": "{{.RANDOM_DESCRIPTION2}}",
            "friendSince": "{{.MEET_DATE2.Format `2006-01-02T15:04:05Z`}}"
        },
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "application/xml; charset=UTF-8"
    And the response body should have format "XML"
    And time between last request and response should be less than or equal to "2s"

    #---------------------------------------------------------------------------------------------------
    # We send HTTP(s) request to fetch all users.
    When I send "GET" request to "{{.MY_APP_URL}}/users?format=xml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    And the response should have header "Content-Type" of value "application/xml; charset=UTF-8"
    And the response body should have format "XML"