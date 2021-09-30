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
	var isDebug bool
	err := godotenv.Load()
	checkErr(err)

	debugString := os.Getenv("GODOG_DEBUG")
	if strings.ToLower(debugString) == "true" {
		isDebug = true
	}

	scenario := &defs.Scenario{State: gdutils.NewDefaultState(isDebug)}

	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		scenario.State.ResetState(isDebug)

		return ctx, nil
	})

	//random data generation
	ctx.Step(`^I generate a random string of length "([^"]*)" without unicode characters and save it as "([^"]*)"$`, scenario.IGenerateARandomStringOfLengthWithoutUnicodeCharactersAndSaveItAs)
	ctx.Step(`^I generate a random string of length "([^"]*)" with unicode characters and save it as "([^"]*)"$`, scenario.IGenerateARandomStringOfLengthWithUnicodeCharactersAndSaveItAs)
	ctx.Step(`^I generate a random float in the range "([^"]*)" to "([^"]*)" and save it as "([^"]*)"$`, scenario.IGenerateARandomFloatInTheRangeToAndSaveItAs)
	ctx.Step(`^I generate a random int in the range "([^"]*)" to "([^"]*)" and save it as "([^"]*)"$`, scenario.IGenerateARandomIntInTheRangeToAndSaveItAs)

	//sending HTTP requests
	ctx.Step(`^I send "(GET|POST|PUT|PATCH|DELETE|HEAD)" request to "([^"]*)" with body and headers:$`, scenario.ISendRequestToWithBodyAndHeaders)

	//assertions
	ctx.Step(`^the response should have header "([^"]*)"$`, scenario.TheResponseShouldHaveHeader)
	ctx.Step(`^the response should have header "([^"]*)" of value "([^"]*)"$`, scenario.TheResponseShouldHaveHeaderOfValue)
	ctx.Step(`^the response status code should be (\d+)$`, scenario.TheResponseStatusCodeShouldBe)
	ctx.Step(`^the JSON response should have key "([^"]*)"$`, scenario.TheJSONResponseShouldHaveNodes)
	ctx.Step(`^the JSON node "([^"]*)" should be "([^"]*)" of value "([^"]*)"$`, scenario.TheJSONNodeShouldBeOfValue)
	ctx.Step(`^the JSON node "([^"]*)" should be slice of length "([^"]*)"$`, scenario.TheJSONNodeShouldBeSliceOfLength)
	ctx.Step(`^the JSON node "([^"]*)" should be "(nil|string|int|float|bool|map|slice)"$`, scenario.TheJSONNodeShouldBe)
	ctx.Step(`^the JSON node "([^"]*)" should not be "(nil|string|int|float|bool|map|slice)"$`, scenario.TheJSONNodeShouldNotBe)
	ctx.Step(`^the JSON response should have nodes "([^"]*)"$`, scenario.TheJSONResponseShouldHaveNodes)
	ctx.Step(`^the response body should have type "(JSON)"$`, scenario.TheResponseBodyShouldHaveType)

	//preserving values
	ctx.Step(`^I save from the last response JSON node "([^"]*)" as "([^"]*)"$`, scenario.ISaveFromTheLastResponseJSONNodeAs)

	//debugging
	ctx.Step(`^I print last response body$`, scenario.IPrintLastResponseBody)
	ctx.Step(`^I start debug mode$`, scenario.IStartDebugMode)
	ctx.Step(`^I stop debug mode$`, scenario.IStopDebugMode)

	//block scenario execution for some time. Available method values should compatible with time.ParseDuration method
	ctx.Step(`^I wait "([^"]*)"`, scenario.IWait)
}

// checkErr checks error and log if found.
func checkErr(err error) {
	if err != nil {
		log.Fatal(err.Error())
	}
}
