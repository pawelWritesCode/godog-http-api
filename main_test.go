package godog_example_setup

import (
	"context"
	"log"
	"os"
	"path"
	"strings"
	"testing"
	"time"

	"github.com/cucumber/godog"
	"github.com/cucumber/godog/colors"
	"github.com/joho/godotenv"
	"github.com/pawelWritesCode/gdutils"
	"github.com/spf13/pflag"

	"github.com/pawelWritesCode/godog-example-setup/defs"
)

const (
	//envDebug describes environment variable responsible for debug mode - (true/false).
	envDebug = "GODOG_DEBUG"

	// envMyAppURL describes URL to "My app" - should be valid URL.
	envMyAppURL = "GODOG_MY_APP_URL"

	// envJsonSchemaDir path to JSON schemas dir - relative path from this file's directory.
	envJsonSchemaDir = "GODOG_JSON_SCHEMA_DIR"
)

// opt defines options for godog CLI while running tests from "go test" command.
var opt = godog.Options{Output: colors.Colored(os.Stdout), Format: "progress", Randomize: time.Now().UTC().UnixNano()}

func init() {
	godog.BindCommandLineFlags("godog.", &opt)
	checkErr(godotenv.Load()) // loading environment variables from .env file
}

func TestMain(m *testing.M) {
	pflag.Parse()
	opt.Paths = pflag.Args()
	status := godog.TestSuite{Name: "godogs", ScenarioInitializer: InitializeScenario, Options: &opt}.Run()

	os.Exit(status)
}

func InitializeScenario(ctx *godog.ScenarioContext) {
	isDebug := strings.ToLower(os.Getenv(envDebug)) == "true"
	wd, err := os.Getwd()
	checkErr(err)

	/*
		scenario is entity that contains utility services and holds methods used behind godog steps.

		If you would like to replace any of default state's utility services with your own, read:
		https://github.com/pawelWritesCode/godog-http-api/wiki/Steps-development#utilityServices
	*/
	scenario := defs.Scenario{APIContext: gdutils.NewDefaultAPIContext(isDebug, path.Join(wd, os.Getenv(envJsonSchemaDir)))}

	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		scenario.APIContext.ResetState(isDebug)

		// Here you can define more scenario-scoped values using scenario.APIContext.Cache.Save() method
		scenario.APIContext.Cache.Save("MY_APP_URL", os.Getenv(envMyAppURL))
		scenario.APIContext.Cache.Save("CWD", wd) // current working directory - full OS path to this file

		return ctx, nil
	})

	// Following declarations maps sentences to methods (define steps). To learn more on each step see
	// https://github.com/pawelWritesCode/godog-http-api/wiki/Steps

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Random data generation - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#dataGeneration
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains utility methods for random data generation. Those methods contain creation of
	   | - random length runes of ASCII/UNICODE/polish/english/russian/japanese/emoji characters,
	   | - random length sentence of ASCII/UNICODE/polish/english/russian/japanese/emoji words,
	   | - int/float from provided range,
	   | - random bool value,
	   | - time object moved forward/backward in time.
	   |
	   | Every method saves its output in scenario's cache under provided key for future use through text/template syntax.
	*/
	ctx.Step(`^I generate a random word having from "(\d+)" to "(\d+)" of "(ASCII|UNICODE|polish|english|russian|japanese|emoji)" characters and save it as "([^"]*)"$`, scenario.IGenerateARandomRunesOfLengthWithCharactersAndSaveItAs)
	ctx.Step(`^I generate a random sentence having from "(\d+)" to "(\d+)" of "(ASCII|UNICODE|polish|english|russian|japanese|emoji)" words and save it as "([^"]*)"$`, scenario.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(3, 10))
	ctx.Step(`^I generate a random "(int|float)" in the range from "([^"]*)" to "([^"]*)" and save it as "([^"]*)"$`, scenario.IGenerateARandomNumberInTheRangeFromToAndSaveItAs)
	ctx.Step(`^I generate a random bool value and save it as "([^"]*)"$`, scenario.IGenerateRandomBoolValueAndSaveItAs)
	ctx.Step(`^I generate current time and travel "(backward|forward)" "([^"]*)" in time and save it as "([^"]*)"$`, scenario.IGenerateCurrentTimeAndTravelByAndSaveItAs)

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Sending HTTP(s) requests - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#httpRequest
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains methods for preparing and sending HTTP(s) requests.
	   | You can use one of two ways to send HTTP(s) request:
	   |
	   | First, composed but less customisable:
	   | Simply use step `I send "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" with body and headers:`
	   | As last argument pass docstring in JSON or YAML format with keys "body" and "headers".
	   |
	   | Second, more customisable:
	   | 	step `^I prepare new "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to ...`      - to prepare HTTP(s) request
	   |	step `^I set following headers for prepared request "([^"]*)":$`             - setting headers (YAML|JSON)
	   |	step `^I set following cookies for prepared request "([^"]*)":$`             - setting cookies (YAML|JSON)
	   |	step `^I set following form for prepared request "([^"]*)":$`                - setting form (YAML|JSON)
	   |	step `^I set following body for prepared request "([^"]*)":$`                - setting req body (any format)
	   |	step `^I send request "([^"]*)"$`                                            - to send prepared request
	*/
	ctx.Step(`^I prepare new "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" and save it as "([^"]*)"$`, scenario.IPrepareNewRequestToAndSaveItAs)
	ctx.Step(`^I set following headers for prepared request "([^"]*)":$`, scenario.ISetFollowingHeadersForPreparedRequest)
	ctx.Step(`^I set following cookies for prepared request "([^"]*)":$`, scenario.ISetFollowingCookiesForPreparedRequest)
	ctx.Step(`^I set following form for prepared request "([^"]*)":$`, scenario.ISetFollowingFormForPreparedRequest)
	ctx.Step(`^I set following body for prepared request "([^"]*)":$`, scenario.ISetFollowingBodyForPreparedRequest)
	ctx.Step(`^I send request "([^"]*)"$`, scenario.ISendRequest)

	ctx.Step(`^I send "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" with body and headers:$`, scenario.ISendRequestToWithBodyAndHeaders)

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Assertions - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#assertions
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains assertions against last HTTP(s) responses, especially:
	   | - response body nodes,
	   | - HTTP(s) headers,
	   | - HTTP(s) cookies,
	   | - HTTP(s) status code,
	   | - time between request - response.
	   |
	   | Every argument following immediately after word "node" or "nodes"
	   | should have syntax acceptable by one of path libraries and may contain template values:
	   | https://github.com/tidwall/gjson or https://github.com/oliveagle/jsonpath or https://github.com/antchfx/jsonquery (JSON)
	   | https://github.com/goccy/go-yaml (YAML)
	   | https://github.com/antchfx/xmlquery (XML)
	   | https://github.com/antchfx/htmlquery (HTML)
	   |
	   | Method "the response should have nodes" accepts list of nodes,
	   | separated with comma ",". For example: "data.0.user, $.data.1.user, data".
	   |
	   | Argument in method starting with 'time between ...' should be string valid for
	   | golang standard library time.ParseDuration func, for example: 3s, 1h, 30ms
	   |
	   | Most of the methods accepts template values in their arguments.
	*/
	ctx.Step(`^the response should (not )?have header "([^"]*)"$`, scenario.TheResponseShouldOrShouldNotHaveHeader)
	ctx.Step(`^the response should have header "([^"]*)" of value "([^"]*)"$`, scenario.TheResponseShouldHaveHeaderOfValue)

	ctx.Step(`^the response should (not )?have cookie "([^"]*)"$`, scenario.TheResponseShouldOrShouldNotHaveCookie)
	ctx.Step(`^the response should have cookie "([^"]*)" of value "([^"]*)"$`, scenario.TheResponseShouldHaveCookieOfValue)
	ctx.Step(`^the response cookie  "([^"]*)" should (not )?match regExp "([^"]*)"$`, scenario.TheResponseCookieShouldOrShouldNotMatchRegExp)

	ctx.Step(`^the response status code should (not )?be (\d+)$`, scenario.TheResponseStatusCodeShouldOrShouldNotBe)

	ctx.Step(`^the "(JSON|YAML|XML|HTML)" response should have nodes "([^"]*)"$`, scenario.TheResponseShouldHaveNodes)
	ctx.Step(`^the "(JSON|YAML|XML|HTML)" response should (not )?have node "([^"]*)"$`, scenario.TheResponseShouldOrShouldNotHaveNode)

	ctx.Step(`^the "(JSON|YAML|XML|HTML)" node "([^"]*)" should be "(bool|boolean|float|int|integer|number|scalar|string)" of value "([^"]*)"$`, scenario.TheNodeShouldBeOfValue)
	ctx.Step(`^the "(JSON|YAML|XML|HTML)" node "([^"]*)" should be "(bool|boolean|float|int|integer|number|scalar|string)" and contain one of values "([^"]*)"$`, scenario.TheNodeShouldBeOfValues)
	ctx.Step(`^the "(JSON|YAML|XML|HTML)" node "([^"]*)" should (not )?contain sub string "([^"]*)"$`, scenario.TheNodeShouldOrShouldNotContainSubString)
	ctx.Step(`^the "(JSON|YAML|XML)" node "([^"]*)" should (not )?be slice of length "(\d+)"$`, scenario.TheNodeShouldOrShouldNotBeSliceOfLength)
	ctx.Step(`^the "(JSON|YAML|XML)" node "([^"]*)" should (not )?be "(array|bool|boolean|float|int|integer|map|mapping|nil|null|number|object|sequence|scalar|slice|string)"$`, scenario.TheNodeShouldOrShouldNotBe)
	ctx.Step(`^the "(JSON|YAML|XML|HTML)" node "([^"]*)" should (not )?match regExp "([^"]*)"$`, scenario.TheNodeShouldOrShouldNotMatchRegExp)
	ctx.Step(`^the "(JSON)" node "([^"]*)" should be valid according to schema "([^"]*)"$`, scenario.IValidateNodeWithSchemaReference)
	ctx.Step(`^the "(JSON)" node "([^"]*)" should be valid according to schema:$`, scenario.IValidateNodeWithSchemaString)

	ctx.Step(`^the response body should be valid according to schema "([^"]*)"$`, scenario.IValidateLastResponseBodyWithSchema)
	ctx.Step(`^the response body should be valid according to schema:$`, scenario.IValidateLastResponseBodyWithFollowingSchema)
	ctx.Step(`^the response body should (not )?have format "(JSON|YAML|XML|HTML|plain text)"$`, scenario.TheResponseBodyShouldOrShouldNotHaveFormat)

	ctx.Step(`^time between last request and response should be less than or equal to "([^"]*)"$`, scenario.TimeBetweenLastHTTPRequestResponseShouldBeLessThanOrEqualTo)

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Preserving data - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#preservingData
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains method for preserving data in scenario cache
	   |
	   | Argument following immediately after word "node"
	   | should have syntax acceptable by one of path libraries and may contain template values:
	   | https://github.com/tidwall/gjson or https://github.com/oliveagle/jsonpath or https://github.com/antchfx/jsonquery (JSON)
	   | https://github.com/goccy/go-yaml (YAML)
	   | https://github.com/antchfx/xmlquery (XML)
	   | https://github.com/antchfx/htmlquery (HTML)
	*/
	ctx.Step(`^I save "([^"]*)" as "([^"]*)"$`, scenario.ISaveAs)
	ctx.Step(`^I save as "([^"]*)":$`, scenario.ISaveFollowingAs)
	ctx.Step(`^I save from the last response "(JSON|YAML|XML|HTML)" node "([^"]*)" as "([^"]*)"$`, scenario.ISaveFromTheLastResponseNodeAs)
	ctx.Step(`^I save from the last response header "([^"]*)" as "([^"]*)"$`, scenario.ISaveFromTheLastResponseHeaderAs)

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Debugging - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#debugging
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains methods that are useful for debugging during test creation phase.
	*/
	ctx.Step(`^I print last response body$`, scenario.IPrintLastResponseBody)
	ctx.Step(`^I print cache data$`, scenario.IPrintCacheData)
	ctx.Step(`^I start debug mode$`, scenario.IStartDebugMode)
	ctx.Step(`^I stop debug mode$`, scenario.IStopDebugMode)

	/*
	   |----------------------------------------------------------------------------------------------------------------
	   | Flow control - https://github.com/pawelWritesCode/godog-http-api/wiki/Steps#flowControl
	   |----------------------------------------------------------------------------------------------------------------
	   |
	   | This section contains methods for control scenario flow.
	   |
	   | Argument in method 'I wait ([^"]*)"' should be string valid for
	   | golang standard library time.ParseDuration func, for example: 3s, 1h, 30ms
	*/
	ctx.Step(`^I wait "([^"]*)"`, scenario.IWait)
	ctx.Step(`^I stop scenario execution$`, scenario.IStopScenarioExecution)
}

// checkErr checks error and log if found.
func checkErr(err error) {
	if err != nil {
		log.Fatal(err.Error())
	}
}
