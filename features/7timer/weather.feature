# http://www.7timer.info/doc.php?lang=en#api
Feature: Tests for 7timer
  Timer! is a series of web-based meteorological forecast products, mainly derived from the NOAA/NCEP-based numeric weather model, the Global Forecast System (GFS).
  7Timer! was firstly established in July 2005 as an exploration product under supported of the
  National Astronomical Observatories of China and had been largely renovated in 2008 and 2011.
  Currently it is supported by the Shanghai Astronomical Observatory of Chinese Academy of Sciences.

  Background:
    # alias for API domain
    Given I save "http://www.7timer.info/bin/api.pl" as "BASE_URL"

    # time objects for following 7 days
    Given I generate current time and travel "forward" "0h" in time and save it as "TODAY_0"
    Given I generate current time and travel "forward" "24h" in time and save it as "TODAY_1"
    Given I generate current time and travel "forward" "48h" in time and save it as "TODAY_2"
    Given I generate current time and travel "forward" "72h" in time and save it as "TODAY_3"
    Given I generate current time and travel "forward" "96h" in time and save it as "TODAY_4"
    Given I generate current time and travel "forward" "120h" in time and save it as "TODAY_5"
    Given I generate current time and travel "forward" "144h" in time and save it as "TODAY_6"

  Scenario: Unsuccessful attempt to fetch weather because of missing required query params
  As API user
  I would like to prove that weather info can't be fetched
  If there are missing required query params

    # Note, that scenario should never be written like this.
    #
    # 7timer API as response on bad requests returns code 200 (Status OK), but request itself
    # is not successful. Also response format may be interpreted as YAML or plain text, However
    # everywhere we ask for JSON output.
    #
    # Here, I documented bug as feature (but I should not do it).

    # missing lon & lat query param
    When I send "GET" request to "{{.BASE_URL}}?product=civillight&output=json" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    # bad request should have code 400, but this API returns 200
    Then the response status code should be 200
    # response body format may be interpreted as YAML
    And the response body should have format "YAML"
    And the "YAML" node "$.ERR" should contain sub string "no geographic location specified"

    # missing product param
    When I send "GET" request to "{{.BASE_URL}}?lon=51.254&lat=22.552&output=json" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    # bad request should have code 400, but this API returns 200
    Then the response status code should be 200
    # response body format may be interpreted as YAML
    And the response body should have format "YAML"
    And the "YAML" node "$.ERR" should contain sub string "no product specified"

  Scenario: Successfully fetch weather for Lublin in JSON format
  As API user 
  I would like to fetch weather info for Lublin, Poland 
  in JSON format for next 7 days.
    
    When I send "GET" request to "{{.BASE_URL}}?lon=51.254&lat=22.552&product=civillight&output=json" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "dataseries" should be slice of length "7"
    And the response body should be valid according to schema:
    """
    {
        "title": "weather forecast for next 7 days in JSON format with formatting: civillight",
        "type": "object",
        "properties": {
            "product": {
                "type": "string",
                "enum": ["civillight"]
            },
            "init": {
                "type": "string"
            },
            "dataseries": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "date": {
                            "type": "integer"
                        },
                        "weather": {
                            "type": "string"
                        },
                        "wind10m_max": {
                            "type": "integer"
                        },
                        "temp2m": {
                            "type": "object",
                            "items": {
                                "max": {
                                    "type": "integer"
                                },
                                "min": {
                                    "type": "integer"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    """

  Scenario: Successfully fetch weather for random localisation in JSON format
  As API user 
  I would like to fetch weather info for randomly picked localisation in JSON format
  in JSON format for next 7 days

    # generating random lon and lat
    Given I generate a random "int" in the range from "0" to "89" and save it as "RND_LON_FULL"
    Given I generate a random "int" in the range from "0" to "6" and save it as "RND_LON_PARTIAL"
    Given I generate a random "int" in the range from "0" to "89" and save it as "RND_LAT_FULL"
    Given I generate a random "int" in the range from "0" to "6" and save it as "RND_LAT_PARTIAL"

    When I send "GET" request to "{{.BASE_URL}}?lon={{.RND_LON_FULL}}.{{.RND_LON_PARTIAL}}00&lat={{.RND_LAT_FULL}}.{{.RND_LAT_PARTIAL}}00&product=civillight&output=json" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "dataseries" should be slice of length "7"
    And the "JSON" node "product" should be "string" of value "civillight"

    # we prove that data is sorted
    And the "JSON" node "dataseries.0.date" should be "number" of value "{{.TODAY_0.Format `20060102`}}"
    And the "JSON" node "dataseries.1.date" should be "number" of value "{{.TODAY_1.Format `20060102`}}"
    And the "JSON" node "dataseries.2.date" should be "number" of value "{{.TODAY_2.Format `20060102`}}"
    And the "JSON" node "dataseries.3.date" should be "number" of value "{{.TODAY_3.Format `20060102`}}"
    And the "JSON" node "dataseries.4.date" should be "number" of value "{{.TODAY_4.Format `20060102`}}"
    And the "JSON" node "dataseries.5.date" should be "number" of value "{{.TODAY_5.Format `20060102`}}"
    And the "JSON" node "dataseries.6.date" should be "number" of value "{{.TODAY_6.Format `20060102`}}"

    And the "JSON" response should have nodes "dataseries.0.temp2m.max, dataseries.0.temp2m.min"
    And the "JSON" node "dataseries.0.wind10m_max" should be "number"
    And the "JSON" node "dataseries.0.wind10m_max" should be "number" and contain one of values "1,2,3,4,5,6,7,8,-9999"
    And the "JSON" node "dataseries.0.weather" should be "string" and contain one of values "clear, pcloudy, mcloudy, cloudy, humid, lightrain, oshower, ishower, lightsnow, rain, rainsnow, ts, tsrain"
    And the response body should be valid according to schema:
    """
    {
        "title": "weather forecast for next 7 days in JSON format with formatting: civillight",
        "type": "object",
        "properties": {
            "product": {
                "type": "string",
                "enum": ["civillight"]
            },
            "init": {
                "type": "string"
            },
            "dataseries": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "date": {
                            "type": "integer"
                        },
                        "weather": {
                            "type": "string"
                        },
                        "wind10m_max": {
                            "type": "integer"
                        },
                        "temp2m": {
                            "type": "object",
                            "items": {
                                "max": {
                                    "type": "integer"
                                },
                                "min": {
                                    "type": "integer"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    """

  Scenario: Successfully fetch weather for random localisation in XML format
  As API user
  I would like to fetch weather info for randomly picked localisation in XML format
  in JSON format for next 7 days

    # generating random lon and lat
    Given I generate a random "int" in the range from "0" to "89" and save it as "RND_LON_FULL"
    Given I generate a random "int" in the range from "0" to "6" and save it as "RND_LON_PARTIAL"
    Given I generate a random "int" in the range from "0" to "89" and save it as "RND_LAT_FULL"
    Given I generate a random "int" in the range from "0" to "6" and save it as "RND_LAT_PARTIAL"

    Given I save "clear, pcloudy, mcloudy, cloudy, humid, lightrain, oshower, ishower, lightsnow, rain, rainsnow, ts, tsrain" as "WEATHER_TYPES"

    When I send "GET" request to "{{.BASE_URL}}?lon={{.RND_LON_FULL}}.{{.RND_LON_PARTIAL}}00&lat={{.RND_LAT_FULL}}.{{.RND_LAT_PARTIAL}}00&product=civillight&output=xml" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "XML"

    # we prove that data is sorted
    And the "XML" node "//data[@timepoint='{{.TODAY_0.Format `20060102`}}']//weather" should be "string" and contain one of values "clear, pcloudy, mcloudy, cloudy, humid, lightrain, oshower, ishower, lightsnow, rain, rainsnow, ts, tsrain"
    And the "XML" node "//data[@timepoint='{{.TODAY_1.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"
    And the "XML" node "//data[@timepoint='{{.TODAY_2.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"
    And the "XML" node "//data[@timepoint='{{.TODAY_3.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"
    And the "XML" node "//data[@timepoint='{{.TODAY_4.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"
    And the "XML" node "//data[@timepoint='{{.TODAY_5.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"
    And the "XML" node "//data[@timepoint='{{.TODAY_6.Format `20060102`}}']//weather" should be "string" and contain one of values "{{.WEATHER_TYPES}}"

    And the "XML" response should have nodes "//product, //product//dataseries"
    And the "XML" node "//data[@timepoint='{{.TODAY_0.Format `20060102`}}']//temp2m_max" should be "integer"
    And the "XML" node "//data[@timepoint='{{.TODAY_0.Format `20060102`}}']//temp2m_min" should be "integer"
    And the "XML" node "//data[@timepoint='{{.TODAY_0.Format `20060102`}}']//wind10m_maxspeed" should be "integer" and contain one of values "1,2,3,4,5,6,7,8,-9999"