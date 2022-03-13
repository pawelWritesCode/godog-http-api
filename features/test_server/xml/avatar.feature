Feature: Send avatar file using multipart/form-data in HTTP(s) request.
  Server allows to send avatar for user account.
  Endpoint: POST /users/:userId/avatar

  Background:
    Given I save "application/xml" as "CONTENT_TYPE_XML"
    Given I generate a random word having from "5" to "10" of "russian" characters and save it as "RANDOM_FIRST_NAME"
    Given I generate a random word having from "5" to "15" of "UNICODE" characters and save it as "RANDOM_LAST_NAME"
    Given I generate a random "int" in the range from "18" to "48" and save it as "RANDOM_AGE"
    Given I generate a random sentence having from "2" to "4" of "english" words and save it as "RANDOM_DESCRIPTION"
    Given I generate current time and travel "backward" "240h" in time and save it as "MEET_DATE"
    Given I generate a random word having from "3" to "7" of "english" characters and save it as "RANDOM_AVATAR_NAME"

  Scenario: Successfully send avatar
    As Application user
    I would like to create new account
    which will have avatar attached to it.

    #-------------------------------------------------------------------------------------------------------------------
    # Create new user using data generated in background section above.
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=xml" with body and headers:
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
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "{{.CONTENT_TYPE_XML}}; charset=UTF-8"
    And the response body should have format "XML"
    And I save from the last response "XML" node "//id" as "USER_ID"

    Given I prepare new "POST" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}/avatar?format=xml" and save it as "AVATAR_REQUEST"
    #-------------------------------------------------------------------------------------------------------------------
    # Here, we create form which will be send through HTTP(s) request.
    # Method automatically set Content-Type: multipart/form-data header with proper boundary. If you want to change
    # Content-Type header to application/x-www-form-urlencoded, afterwards use step for setting headers to overwrite it
    # To attach any file, use following syntax: file://path/to/file
    Given I set following form for prepared request "AVATAR_REQUEST":
    """
    {
        "name": "{{.RANDOM_AVATAR_NAME}}.gif",
        "avatar": "file://{{.CWD}}/assets/gifs/hand-pointing-left.gif"
    }
    """
    When I send request "AVATAR_REQUEST"
    Then the response status code should be 200

    #-------------------------------------------------------------------------------------------------------------------
    # Fetching user, to check whether avatar field appeared and has proper value.
    When I send "GET" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}?format=xml" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 200
    # file is uploaded in OS temporary folder: $TMPDIR/{{.USER_ID}}_{{.RANDOM_AVATAR_NAME}}.gif
    And the "XML" node "//avatar" should be "string" of value "{{.RANDOM_AVATAR_NAME}}.gif"

  Scenario: Unsuccessful attempt to add avatar for user account
    As application user
    I would like to create new account and not be able to add avatar using invalid data

    #-------------------------------------------------------------------------------------------------------------------
    # Create new user using data generated in background section above.
    When I send "POST" request to "{{.MY_APP_URL}}/users?format=xml" with body and headers:
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
            "Content-Type": "application/json"
        }
    }
    """
    Then the response status code should be 201
    And the response should have header "Content-Type" of value "{{.CONTENT_TYPE_XML}}; charset=UTF-8"
    And the response body should have format "XML"
    And I save from the last response "XML" node "//id" as "USER_ID"

    Given I prepare new "POST" request to "{{.MY_APP_URL}}/users/{{.USER_ID}}/avatar?format=xml" and save it as "AVATAR_REQUEST"

    #-------------------------------------------------------------------------------------------------------------------
    # This form has invalid name property
    Given I set following form for prepared request "AVATAR_REQUEST":
    """
    {
        "name": "",
        "avatar": "file://{{.CWD}}/assets/gifs/hand-pointing-left.gif"
    }
    """
    When I send request "AVATAR_REQUEST"
    Then the response status code should be 400
    And the "XML" response should have node "//Error"