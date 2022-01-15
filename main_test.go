package godog_example_setup

import (
	"context"
	"log"
	"os"
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
	//envDebug describes environment variable responsible for debug mode - (true/false)
	envDebug = "GODOG_DEBUG"

	// envMyAppURL describes URL to "My app" - should be valid URL
	envMyAppURL = "GODOG_MY_APP_URL"

	// envJsonSchemaDir path to JSON schemas dir - relative path from project root
	envJsonSchemaDir = "GODOG_JSON_SCHEMA_DIR"
)

var opt = godog.Options{
	Output:    colors.Colored(os.Stdout),
	Format:    "progress", // can define default values
	Randomize: time.Now().UTC().UnixNano(),
}

func init() {
	godog.BindCommandLineFlags("godog.", &opt)
}

func TestMain(m *testing.M) {
	pflag.Parse()
	opt.Paths = pflag.Args()

	status := godog.TestSuite{
		Name:                "godogs",
		ScenarioInitializer: InitializeScenario,
		Options:             &opt,
	}.Run()

	os.Exit(status)
}

func InitializeScenario(ctx *godog.ScenarioContext) {
	checkErr(godotenv.Load()) // loading environment variables from .env file
	isDebug := strings.ToLower(os.Getenv(envDebug)) == "true"

	scenario := &defs.Scenario{State: gdutils.NewDefaultState(isDebug, os.Getenv(envJsonSchemaDir))}

	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		scenario.State.ResetState(isDebug)

		//Here you can define more scenario-scoped values using scenario.State.Cache.Save() method
		scenario.State.Cache.Save("MY_APP_URL", os.Getenv(envMyAppURL))

		return ctx, nil
	})

	/*
	   |--------------------------------------------------------------------------
	   | Random data generation
	   |--------------------------------------------------------------------------
	   |
	   | This section contains utility methods for random data generation.
	   | Those methods contains creation of
	   | - fixed length strings with/without unicode characters
	   | - int/float from provided range.
	   |
	   | Every method saves its output in state's cache under provided key
	*/
	ctx.Step(`^I generate a random string of length "([^"]*)" without unicode characters and save it as "([^"]*)"$`, scenario.IGenerateARandomStringOfLengthWithoutUnicodeCharactersAndSaveItAs)
	ctx.Step(`^I generate a random string of length "([^"]*)" with unicode characters and save it as "([^"]*)"$`, scenario.IGenerateARandomStringOfLengthWithUnicodeCharactersAndSaveItAs)
	ctx.Step(`^I generate a random float in the range from "([^"]*)" to "([^"]*)" and save it as "([^"]*)"$`, scenario.IGenerateARandomFloatInTheRangeToAndSaveItAs)
	ctx.Step(`^I generate a random int in the range from "([^"]*)" to "([^"]*)" and save it as "([^"]*)"$`, scenario.IGenerateARandomIntInTheRangeToAndSaveItAs)

	/*
	   |--------------------------------------------------------------------------
	   | Sending HTTP(s) requests
	   |--------------------------------------------------------------------------
	   |
	   | This section contains methods for preparing and sending HTTP(s) requests.
	*/
	ctx.Step(`^I send "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" with body and headers:$`, scenario.ISendRequestToWithBodyAndHeaders)
	ctx.Step(`^I prepare new "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" and save it as "([^"]*)"$`, scenario.IPrepareNewRequestToAndSaveItAs)
	ctx.Step(`^I set following headers for prepared request "([^"]*)":$`, scenario.ISetFollowingHeadersForPreparedRequest)
	ctx.Step(`^I set following body for prepared request "([^"]*)":$`, scenario.ISetFollowingBodyForPreparedRequest)
	ctx.Step(`^I send request "([^"]*)"$`, scenario.ISendRequest)

	/*
	   |--------------------------------------------------------------------------
	   | Assertions
	   |--------------------------------------------------------------------------
	   |
	   | This section contains assertions against last HTTP(s) request.
	   | Those include assertions against:
	   | - response body JSON nodes,
	   | - HTTP(s) headers,
	   | - status code.
	*/
	ctx.Step(`^the response should have header "([^"]*)"$`, scenario.TheResponseShouldHaveHeader)
	ctx.Step(`^the response should have header "([^"]*)" of value "([^"]*)"$`, scenario.TheResponseShouldHaveHeaderOfValue)
	ctx.Step(`^the response status code should be (\d+)$`, scenario.TheResponseStatusCodeShouldBe)
	ctx.Step(`^the JSON response should have key "([^"]*)"$`, scenario.TheJSONResponseShouldHaveNodes)
	ctx.Step(`^the JSON node "([^"]*)" should be "(string|int|float|bool)" of value "([^"]*)"$`, scenario.TheJSONNodeShouldBeOfValue)
	ctx.Step(`^the JSON node "([^"]*)" should be slice of length "([^"]*)"$`, scenario.TheJSONNodeShouldBeSliceOfLength)
	ctx.Step(`^the JSON node "([^"]*)" should be "(nil|string|int|float|bool|map|slice)"$`, scenario.TheJSONNodeShouldBe)
	ctx.Step(`^the JSON node "([^"]*)" should not be "(nil|string|int|float|bool|map|slice)"$`, scenario.TheJSONNodeShouldNotBe)
	ctx.Step(`^the JSON response should have nodes "([^"]*)"$`, scenario.TheJSONResponseShouldHaveNodes)
	ctx.Step(`^the response body should have type "(JSON)"$`, scenario.TheResponseBodyShouldHaveType)
	ctx.Step(`^the response body should be valid according to JSON schema "([^"]*)"$`, scenario.IValidateLastResponseBodyWithSchema)

	/*
	   |--------------------------------------------------------------------------
	   | Preserving data
	   |--------------------------------------------------------------------------
	   |
	   | This section contains method for preserving data
	*/
	ctx.Step(`^I save from the last response JSON node "([^"]*)" as "([^"]*)"$`, scenario.ISaveFromTheLastResponseJSONNodeAs)

	/*
	   |--------------------------------------------------------------------------
	   | Debugging
	   |--------------------------------------------------------------------------
	   |
	   | This section contains methods that are useful during test creation
	*/
	ctx.Step(`^I print last response body$`, scenario.IPrintLastResponseBody)
	ctx.Step(`^I start debug mode$`, scenario.IStartDebugMode)
	ctx.Step(`^I stop debug mode$`, scenario.IStopDebugMode)

	/*
	   |--------------------------------------------------------------------------
	   | Flow control
	   |--------------------------------------------------------------------------
	   |
	   | This section contains methods for control scenario flow
	*/
	ctx.Step(`^I wait "([^"]*)"`, scenario.IWait)
}

// checkErr checks error and log if found.
func checkErr(err error) {
	if err != nil {
		log.Fatal(err.Error())
	}
}
