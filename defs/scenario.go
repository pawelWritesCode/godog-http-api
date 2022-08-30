package defs

import (
	"errors"
	"fmt"
	"math/rand"
	"strings"
	"time"

	"github.com/cucumber/godog"
	"github.com/pawelWritesCode/gdutils"
	"github.com/pawelWritesCode/gdutils/pkg/format"
	"github.com/pawelWritesCode/gdutils/pkg/stringutils"
	"github.com/pawelWritesCode/gdutils/pkg/timeutils"
	"github.com/pawelWritesCode/gdutils/pkg/types"
)

// Scenario is entity that contains utility services and holds methods used behind godog steps.
type Scenario struct {
	// APIContext holds utility services and methods for working with HTTP(s) API.
	APIContext *gdutils.APIContext
}

// IGenerateARandomRunesOfLengthWithCharactersAndSaveItAs creates random runes generator func using provided charset.
// Returned func creates runes from provided range and preserve it under given cacheKey in scenario cache.
func (s *Scenario) IGenerateARandomRunesOfLengthWithCharactersAndSaveItAs(from, to int, charset string, cacheKey string) error {
	var generateWordFunc func(from, to int, cacheKey string) error

	switch strings.ToLower(charset) {
	case "ascii":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetASCII)
	case "unicode":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetUnicode)
	case "polish":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetPolish)
	case "english":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetEnglish)
	case "russian":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetRussian)
	case "japanese":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetJapanese)
	case "emoji":
		generateWordFunc = s.APIContext.GeneratorRandomRunes(stringutils.CharsetEmoji)
	default:
		return fmt.Errorf("unknown charset '%s', available: ascii, unicode, polish, english, russian, japanese, emoji", charset)
	}

	return generateWordFunc(from, to, cacheKey)
}

// IGenerateARandomNumberInTheRangeFromToAndSaveItAs generates random number from provided range
// and preserve it in scenario cache under provided cacheKey.
func (s *Scenario) IGenerateARandomNumberInTheRangeFromToAndSaveItAs(numberType string, from, to float64, cacheKey string) error {
	switch strings.ToLower(numberType) {
	case "float":
		return s.APIContext.GenerateFloat64(from, to, cacheKey)
	case "int":
		return s.APIContext.GenerateRandomInt(int(from), int(to), cacheKey)
	default:
		return fmt.Errorf("unknown type %s, available: int, float", numberType)
	}
}

// IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs creates generator func for creating random sentences.
// Each sentence has length from - to as provided in params and is saved in scenario cache under provided cacheKey.
func (s *Scenario) IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(minWordLength, maxWordLength int) func(from, to int, charset string, cacheKey string) error {
	return func(from, to int, charset string, cacheKey string) error {
		var generateSentenceFunc func(from, to int, cacheKey string) error
		switch strings.ToLower(charset) {
		case "ascii":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetASCII, minWordLength, maxWordLength)
		case "unicode":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetUnicode, minWordLength, maxWordLength)
		case "polish":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetPolish, minWordLength, maxWordLength)
		case "english":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetEnglish, minWordLength, maxWordLength)
		case "russian":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetRussian, minWordLength, maxWordLength)
		case "japanese":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetJapanese, minWordLength, maxWordLength)
		case "emoji":
			generateSentenceFunc = s.APIContext.GeneratorRandomSentence(stringutils.CharsetEmoji, minWordLength, maxWordLength)
		default:
			return fmt.Errorf("unknown charset '%s', available: ascii, unicode, polish, english, russian, japanese, emoji", charset)
		}

		return generateSentenceFunc(from, to, cacheKey)
	}
}

// IGenerateRandomBoolValueAndSaveItAs generates random boolean value and save it in cache under given key
func (s *Scenario) IGenerateRandomBoolValueAndSaveItAs(cacheKey string) error {
	s.APIContext.Cache.Save(cacheKey, rand.Intn(2) == 0)

	return nil
}

// IGenerateCurrentTimeAndTravelByAndSaveItAs creates current time object, move timeDuration in time and
// save it in cache under given cacheKey.
func (s *Scenario) IGenerateCurrentTimeAndTravelByAndSaveItAs(timeDirection, timeDuration, cacheKey string) error {
	duration, err := time.ParseDuration(timeDuration)
	if err != nil {
		return err
	}

	return s.APIContext.GenerateTimeAndTravel(timeutils.TimeDirection(timeDirection), duration, cacheKey)
}

/*
		ISendRequestToWithFormatBodyAndHeaders sends HTTP(s) requests with provided body and headers.

		Argument "method" indices HTTP request method for example: "POST", "GET" etc.
	 	Argument "urlTemplate" should be full valid URL. May include template values.
		Argument "bodyTemplate" should contain data (may include template values)
		in JSON or YAML format with keys "body" and "headers".
*/
func (s *Scenario) ISendRequestToWithBodyAndHeaders(method, urlTemplate string, reqBody *godog.DocString) error {
	return s.APIContext.RequestSendWithBodyAndHeaders(method, urlTemplate, reqBody.Content)
}

// IPrepareNewRequestToAndSaveItAs prepares new request and saves it in cache under cacheKey.
func (s *Scenario) IPrepareNewRequestToAndSaveItAs(method, urlTemplate, cacheKey string) error {
	return s.APIContext.RequestPrepare(method, urlTemplate, cacheKey)
}

// ISetFollowingHeadersForPreparedRequest sets provided headers for previously prepared request.
// incoming data should be in format acceptable by injected s.APIContext.Deserializer
func (s *Scenario) ISetFollowingHeadersForPreparedRequest(cacheKey string, headersTemplate *godog.DocString) error {
	return s.APIContext.RequestSetHeaders(cacheKey, headersTemplate.Content)
}

// ISetFollowingCookiesForPreparedRequest sets cookies for previously prepared request
// cookies template should be YAML or JSON deserializable on []http.Cookie
func (s *Scenario) ISetFollowingCookiesForPreparedRequest(cacheKey string, cookies *godog.DocString) error {
	return s.APIContext.RequestSetCookies(cacheKey, cookies.Content)
}

/*
ISetFollowingFormForPreparedRequest sets form for previously prepared request.
Internally method sets proper Content-Type: multipart/form-data header.
formTemplate should be YAML or JSON deserializable on map[string]string.
*/
func (s *Scenario) ISetFollowingFormForPreparedRequest(cacheKey string, formTemplate *godog.DocString) error {
	return s.APIContext.RequestSetForm(cacheKey, formTemplate.Content)
}

// ISetFollowingBodyForPreparedRequest sets body for previously prepared request.
// bodyTemplate may be in any format and accepts template values.
func (s *Scenario) ISetFollowingBodyForPreparedRequest(cacheKey string, bodyTemplate *godog.DocString) error {
	return s.APIContext.RequestSetBody(cacheKey, bodyTemplate.Content)
}

// ISendRequest sends previously prepared HTTP(s) request.
func (s *Scenario) ISendRequest(cacheKey string) error {
	return s.APIContext.RequestSend(cacheKey)
}

// TheResponseShouldOrShouldNotHaveHeader checks whether last HTTP response has/hasn't given header.
func (s *Scenario) TheResponseShouldOrShouldNotHaveHeader(not, name string) error {
	if len(not) > 0 {
		return s.APIContext.AssertResponseHeaderNotExists(name)
	}

	return s.APIContext.AssertResponseHeaderExists(name)
}

// TheResponseShouldHaveHeaderOfValue checks whether last HTTP response has given header with provided value.
func (s *Scenario) TheResponseShouldHaveHeaderOfValue(name, value string) error {
	return s.APIContext.AssertResponseHeaderValueIs(name, value)
}

// TheResponseStatusCodeShouldOrShouldNotBe checks last response status code.
func (s *Scenario) TheResponseStatusCodeShouldOrShouldNotBe(not string, code int) error {
	if len(not) > 0 {
		return s.APIContext.AssertStatusCodeIsNot(code)
	}

	return s.APIContext.AssertStatusCodeIs(code)
}

// TheResponseShouldOrShouldNotHaveNode checks whether last response body contains or doesn't contain given node.
// expr should be valid according to injected PathFinder for given data format
func (s *Scenario) TheResponseShouldOrShouldNotHaveNode(dataFormat, not, exprTemplate string) error {
	if len(not) > 0 {
		return s.APIContext.AssertNodeNotExists(format.DataFormat(dataFormat), exprTemplate)
	}

	return s.APIContext.AssertNodeExists(format.DataFormat(dataFormat), exprTemplate)
}

// TheNodeShouldBeOfValue compares node value from expression to expected by user dataValue of given by user dataType
// Available data types are listed in switch section in each case directive.
// expr should be valid according to injected PathFinder for provided dataFormat.
func (s *Scenario) TheNodeShouldBeOfValue(dataFormat, exprTemplate, dataType, dataValue string) error {
	return s.APIContext.AssertNodeIsTypeAndValue(format.DataFormat(dataFormat), exprTemplate, types.DataType(dataType), dataValue)
}

// TheNodeShouldBeOfValues compares node value from expression to expected by user one of values of given by user dataType
// Available data types are listed in switch section in each case directive.
// expr should be valid according to injected PathFinder for provided dataFormat.
func (s *Scenario) TheNodeShouldBeOfValues(dataFormat, exprTemplate, dataType, valuesTemplates string) error {
	return s.APIContext.AssertNodeIsTypeAndHasOneOfValues(format.DataFormat(dataFormat), exprTemplate, types.DataType(dataType), valuesTemplates)
}

// TheNodeShouldOrShouldNotContainSubString checks whether value of last HTTP response node, obtained using exprTemplate
// is string type and contains/doesn't contain given substring
func (s *Scenario) TheNodeShouldOrShouldNotContainSubString(dataFormat, exprTemplate, not, subTemplate string) error {
	if len(not) > 0 {
		return s.APIContext.AssertNodeNotContainsSubString(format.DataFormat(dataFormat), exprTemplate, subTemplate)
	}

	return s.APIContext.AssertNodeContainsSubString(format.DataFormat(dataFormat), exprTemplate, subTemplate)
}

// TheNodeShouldOrShouldNotBeSliceOfLength checks whether given key is slice and has/hasn't given length
// expr should be valid according to injected PathFinder for provided dataFormat
func (s *Scenario) TheNodeShouldOrShouldNotBeSliceOfLength(dataFormat, exprTemplate, not string, length int) error {
	if len(not) > 0 {
		return s.APIContext.AssertNodeSliceLengthIsNot(format.DataFormat(dataFormat), exprTemplate, length)
	}

	return s.APIContext.AssertNodeSliceLengthIs(format.DataFormat(dataFormat), exprTemplate, length)
}

// TheNodeShouldOrShouldNotBe checks whether node from last response body is/is not of provided type
// goType may be one of: nil, string, int, float, bool, map, slice
// expr should be valid according to injected PathResolver
func (s *Scenario) TheNodeShouldOrShouldNotBe(dataFormat, exprTemplate, not, goType string) error {
	if len(not) > 0 {
		return s.APIContext.AssertNodeIsNotType(format.DataFormat(dataFormat), exprTemplate, types.DataType(goType))
	}

	return s.APIContext.AssertNodeIsType(format.DataFormat(dataFormat), exprTemplate, types.DataType(goType))
}

// TheResponseShouldHaveNodes checks whether last request body has keys defined in string separated by comma
// nodeExpr should be valid according to injected PathFinder expressions separated by comma (,)
func (s *Scenario) TheResponseShouldHaveNodes(dataFormat, nodesExpr string) error {
	return s.APIContext.AssertNodesExist(format.DataFormat(dataFormat), nodesExpr)
}

// TheNodeShouldOrShouldNotMatchRegExp checks whether last response body node matches or doesn't match provided regExp.
func (s *Scenario) TheNodeShouldOrShouldNotMatchRegExp(dataFormat, exprTemplate, not, regExpTemplate string) error {
	if len(not) > 0 {
		return s.APIContext.AssertNodeNotMatchesRegExp(format.DataFormat(dataFormat), exprTemplate, regExpTemplate)
	}

	return s.APIContext.AssertNodeMatchesRegExp(format.DataFormat(dataFormat), exprTemplate, regExpTemplate)
}

// TheResponseBodyShouldOrShouldNotHaveFormat checks whether last response body has given data format.
// Available data formats are listed in format package.
func (s *Scenario) TheResponseBodyShouldOrShouldNotHaveFormat(not, dataFormat string) error {
	if len(not) > 0 {
		return s.APIContext.AssertResponseFormatIsNot(format.DataFormat(dataFormat))
	}

	return s.APIContext.AssertResponseFormatIs(format.DataFormat(dataFormat))
}

/*
IValidateLastResponseBodyWithSchema validates last response body against JSON schema under provided reference.
reference may be:
  - full OS path to JSON schema
  - relative path from JSON schema's dir which was passed in main_test to initialize *Scenario struct instance,
  - URL
*/
func (s *Scenario) IValidateLastResponseBodyWithSchema(referenceTemplate string) error {
	return s.APIContext.AssertResponseMatchesSchemaByReference(referenceTemplate)
}

// IValidateLastResponseBodyWithFollowingSchema validates last response body against JSON schema provided by user.
func (s *Scenario) IValidateLastResponseBodyWithFollowingSchema(schemaBytes *godog.DocString) error {
	return s.APIContext.AssertResponseMatchesSchemaByString(schemaBytes.Content)
}

/*
TimeBetweenLastHTTPRequestResponseShouldBeLessThanOrEqualTo asserts that last HTTP request-response time
is <= than expected timeInterval.
timeInterval should be string acceptable by time.ParseDuration func
*/
func (s *Scenario) TimeBetweenLastHTTPRequestResponseShouldBeLessThanOrEqualTo(timeInterval string) error {
	duration, err := time.ParseDuration(timeInterval)
	if err != nil {
		return err
	}

	return s.APIContext.AssertTimeBetweenRequestAndResponseIs(duration)
}

// TheResponseShouldOrShouldNotHaveCookie checks whether last HTTP(s) response has cookie of given name.
func (s *Scenario) TheResponseShouldOrShouldNotHaveCookie(not, name string) error {
	if len(not) > 0 {
		return s.APIContext.AssertResponseCookieNotExists(name)
	}

	return s.APIContext.AssertResponseCookieExists(name)
}

// TheResponseShouldHaveCookieOfValue checks whether last HTTP(s) response has cookie of given name and value.
func (s *Scenario) TheResponseShouldHaveCookieOfValue(name, valueTemplate string) error {
	return s.APIContext.AssertResponseCookieValueIs(name, valueTemplate)
}

// TheResponseCookieShouldOrShouldNotMatchRegExp checks whether last HTTP(s) response has cookie of given name and value
// matches/doesn't match provided regExp.
func (s *Scenario) TheResponseCookieShouldOrShouldNotMatchRegExp(name, not, regExpTemplate string) error {
	if len(not) > 0 {
		return s.APIContext.AssertResponseCookieValueNotMatchesRegExp(name, regExpTemplate)
	}

	return s.APIContext.AssertResponseCookieValueMatchesRegExp(name, regExpTemplate)
}

// IValidateNodeWithSchemaReference validates last response body node against schema as provided in reference
func (s *Scenario) IValidateNodeWithSchemaReference(dataFormat, exprTemplate, referenceTemplate string) error {
	return s.APIContext.AssertNodeMatchesSchemaByReference(format.DataFormat(dataFormat), exprTemplate, referenceTemplate)
}

// IValidateNodeWithSchemaString validates last response body JSON node against schema
func (s *Scenario) IValidateNodeWithSchemaString(dataFormat, exprTemplate string, schemaTemplate *godog.DocString) error {
	return s.APIContext.AssertNodeMatchesSchemaByString(format.DataFormat(dataFormat), exprTemplate, schemaTemplate.Content)
}

// ISaveAs saves into cache arbitrary passed value
func (s *Scenario) ISaveAs(valueTemplate, cacheKey string) error {
	return s.APIContext.Save(valueTemplate, cacheKey)
}

// ISaveFollowingAs saves into cache arbitrary passed data. Data may be multiline.
func (s *Scenario) ISaveFollowingAs(cacheKey string, data *godog.DocString) error {
	return s.ISaveAs(data.Content, cacheKey)
}

// ISaveFromTheLastResponseNodeAs saves from last response json node under given cache key.
func (s *Scenario) ISaveFromTheLastResponseNodeAs(dataFormat, exprTemplate, cacheKey string) error {
	return s.APIContext.SaveNode(format.DataFormat(dataFormat), exprTemplate, cacheKey)
}

// ISaveFromTheLastResponseHeaderAs saves from last response header value under given cache key
func (s *Scenario) ISaveFromTheLastResponseHeaderAs(headerName, cacheKey string) error {
	return s.APIContext.SaveHeader(headerName, cacheKey)
}

// IPrintLastResponseBody prints response body from last scenario request
func (s *Scenario) IPrintLastResponseBody() error {
	return s.APIContext.DebugPrintResponseBody()
}

// IPrintCacheData prints all current scenario cache data.
func (s *Scenario) IPrintCacheData() error {
	fmt.Printf("%#v", s.APIContext.Cache.All())

	return nil
}

/*
IWait waits for provided time interval amount of time
timeInterval should be string valid for time.ParseDuration func,
for example: 3s, 1h, 30ms
*/
func (s *Scenario) IWait(timeInterval string) error {
	duration, err := time.ParseDuration(timeInterval)
	if err != nil {
		return err
	}

	return s.APIContext.Wait(duration)
}

// IStartDebugMode starts debugging mode
func (s *Scenario) IStartDebugMode() error {
	return s.APIContext.DebugStart()
}

// IStopDebugMode stops debugging mode
func (s *Scenario) IStopDebugMode() error {
	return s.APIContext.DebugStop()
}

// IStopScenarioExecution stops scenario execution
func (s *Scenario) IStopScenarioExecution() error {
	return errors.New("scenario stopped")
}
