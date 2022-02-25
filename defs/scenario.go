package defs

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/cucumber/godog"
	"github.com/pawelWritesCode/gdutils"
	"github.com/pawelWritesCode/gdutils/pkg/dataformat"
	"github.com/pawelWritesCode/gdutils/pkg/stringutils"
	"github.com/pawelWritesCode/gdutils/pkg/timeutils"
)

// Scenario represents Scenario unit in context of godog framework.
type Scenario struct {
	// State is responsible for data flow inside one scenario.
	State *gdutils.State
}

// IGenerateARandomRunesOfLengthWithCharactersAndSaveItAs creates random runes generator func using provided charset.
// Returned func creates runes from provided range and preserve it under given cacheKey in scenario cache.
func (s *Scenario) IGenerateARandomRunesOfLengthWithCharactersAndSaveItAs(from, to int, charset string, cacheKey string) error {
	var generateWordFunc func(from, to int, cacheKey string) error

	switch strings.ToLower(charset) {
	case "ascii":
		generateWordFunc = s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(stringutils.CharsetASCII)
	case "unicode":
		generateWordFunc = s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(stringutils.CharsetUnicode)
	case "polish":
		generateWordFunc = s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(stringutils.CharsetPolish)
	case "english":
		generateWordFunc = s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(stringutils.CharsetEnglish)
	case "russian":
		generateWordFunc = s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(stringutils.CharsetRussian)
	default:
		return fmt.Errorf("unknown charset '%s', available: ascii, unicode, polish, english, russian", charset)
	}

	return generateWordFunc(from, to, cacheKey)
}

// IGenerateARandomNumberInTheRangeFromToAndSaveItAs generates random number from provided range
// and preserve it in scenario cache under provided cacheKey.
func (s *Scenario) IGenerateARandomNumberInTheRangeFromToAndSaveItAs(numberType string, from, to int, cacheKey string) error {
	switch strings.ToLower(numberType) {
	case "float":
		return s.State.IGenerateARandomFloatInTheRangeToAndSaveItAs(from, to, cacheKey)
	case "int":
		return s.State.IGenerateARandomIntInTheRangeToAndSaveItAs(from, to, cacheKey)
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
			generateSentenceFunc = s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(stringutils.CharsetASCII, minWordLength, maxWordLength)
		case "unicode":
			generateSentenceFunc = s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(stringutils.CharsetUnicode, minWordLength, maxWordLength)
		case "polish":
			generateSentenceFunc = s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(stringutils.CharsetPolish, minWordLength, maxWordLength)
		case "english":
			generateSentenceFunc = s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(stringutils.CharsetEnglish, minWordLength, maxWordLength)
		case "russian":
			generateSentenceFunc = s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(stringutils.CharsetRussian, minWordLength, maxWordLength)
		default:
			return fmt.Errorf("unknown charset '%s', available: ascii, unicode, polish, english, russian", charset)
		}

		return generateSentenceFunc(from, to, cacheKey)
	}
}

// IGenerateCurrentTimeAndTravelByAndSaveItAs creates current time object, move timeDuration in time and
// save it in cache under given cacheKey.
func (s *Scenario) IGenerateCurrentTimeAndTravelByAndSaveItAs(timeDirection, timeDuration, cacheKey string) error {
	duration, err := time.ParseDuration(timeDuration)
	if err != nil {
		return err
	}

	return s.State.IGenerateCurrentTimeAndTravelByAndSaveItAs(timeutils.TimeDirection(timeDirection), duration, cacheKey)
}

/*
	ISendRequestToWithBodyAndHeaders sends HTTP(s) requests with provided body and headers.

	Argument "method" indices HTTP request method for example: "POST", "GET" etc.
 	Argument "urlTemplate" should be full valid URL. May include template values.
	Argument "bodyTemplate" should contain data (may include template values) in format acceptable by Deserializer
	with keys "body" and "headers". Internally method will marshal request body to JSON format and add it to request.

	If you want to send request body in arbitrary data format, use step-by-step flow containing following methods:
		IPrepareNewRequestToAndSaveItAs            - creates request object and save it to cache
		ISetFollowingHeadersForPreparedRequest     - sets header for saved request
		ISetFollowingBodyForPreparedRequest        - sets body for saved request
		ISendRequest 							   - sends previously saved request
	Because method ISetFollowingBodyForPreparedRequest pass any bytes to HTTP(s) request body without any mutation.
*/
func (s *Scenario) ISendRequestToWithBodyAndHeaders(method, urlTemplate string, reqBody *godog.DocString) error {
	return s.State.ISendRequestToWithBodyAndHeaders(method, urlTemplate, reqBody.Content)
}

// IPrepareNewRequestToAndSaveItAs prepares new request and saves it in cache under cacheKey.
func (s Scenario) IPrepareNewRequestToAndSaveItAs(method, urlTemplate, cacheKey string) error {
	return s.State.IPrepareNewRequestToAndSaveItAs(method, urlTemplate, cacheKey)
}

// ISetFollowingHeadersForPreparedRequest sets provided headers for previously prepared request.
// incoming data should be in format acceptable by injected s.State.Deserializer
func (s Scenario) ISetFollowingHeadersForPreparedRequest(cacheKey string, headersTemplate *godog.DocString) error {
	return s.State.ISetFollowingHeadersForPreparedRequest(cacheKey, headersTemplate.Content)
}

// ISetFollowingCookiesForPreparedRequest sets cookies for previously prepared request
// cookies template should be YAML or JSON deserializable on []http.Cookie
func (s Scenario) ISetFollowingCookiesForPreparedRequest(cacheKey string, cookies *godog.DocString) error {
	return s.State.ISetFollowingCookiesForPreparedRequest(cacheKey, cookies.Content)
}

// ISetFollowingBodyForPreparedRequest sets body for previously prepared request.
// bodyTemplate may be in any format and accepts template values.
func (s Scenario) ISetFollowingBodyForPreparedRequest(cacheKey string, bodyTemplate *godog.DocString) error {
	return s.State.ISetFollowingBodyForPreparedRequest(cacheKey, bodyTemplate.Content)
}

// ISendRequest sends previously prepared HTTP(s) request.
func (s Scenario) ISendRequest(cacheKey string) error {
	return s.State.ISendRequest(cacheKey)
}

// TheResponseShouldHaveHeader checks whether last HTTP response has given header.
func (s *Scenario) TheResponseShouldHaveHeader(name string) error {
	return s.State.TheResponseShouldHaveHeader(name)
}

// TheResponseShouldHaveHeaderOfValue checks whether last HTTP response has given header with provided value.
func (s *Scenario) TheResponseShouldHaveHeaderOfValue(name, value string) error {
	return s.State.TheResponseShouldHaveHeaderOfValue(name, value)
}

// TheResponseStatusCodeShouldBe checks last response status code.
func (s *Scenario) TheResponseStatusCodeShouldBe(code int) error {
	return s.State.TheResponseStatusCodeShouldBe(code)
}

// TheJSONResponseShouldHaveNode checks whether last response body contains given JSON node.
func (s *Scenario) TheJSONResponseShouldHaveNode(expr string) error {
	return s.State.TheJSONResponseShouldHaveNode(expr)
}

/*
	TheJSONNodeShouldBeOfValue finds JSON node from provided expression and compares it to,
	expected by user value of given by user type,
	available data types are listed in switch section in each case directive.
*/
func (s *Scenario) TheJSONNodeShouldBeOfValue(expr, dataType, dataValue string) error {
	return s.State.TheJSONNodeShouldBeOfValue(expr, dataType, dataValue)
}

// TheJSONNodeShouldBeSliceOfLength finds JSON node from provided expression and
// checks whether given JSON node is slice and has given length.
func (s *Scenario) TheJSONNodeShouldBeSliceOfLength(expr string, length int) error {
	return s.State.TheJSONNodeShouldBeSliceOfLength(expr, length)
}

/*
	TheJSONNodeShouldBe checks whether JSON node from last response body is of provided type.
	goType may be one of: nil, string, int, float, bool, map, slice.
	node should be expression acceptable by qjson package against JSON node from last response body.
*/
func (s *Scenario) TheJSONNodeShouldBe(expr, goType string) error {
	return s.State.TheJSONNodeShouldBe(expr, goType)
}

/*
	TheJSONNodeShouldNotBe checks whether JSON node from last response body is not of provided type.
	goType may be one of: nil, string, int, float, bool, map, slice.
	node should be expression acceptable by qjson package against JSON node from last response body.
*/
func (s *Scenario) TheJSONNodeShouldNotBe(expr, goType string) error {
	return s.State.TheJSONNodeShouldNotBe(expr, goType)
}

// TheJSONResponseShouldHaveNodes checks whether last request body has keys defined in string separated by comma
// nodeExpr should be valid according to qjson library expressions separated by comma (,)
func (s *Scenario) TheJSONResponseShouldHaveNodes(nodesExpr string) error {
	return s.State.TheJSONResponseShouldHaveNodes(nodesExpr)
}

// TheResponseBodyShouldHaveFormat checks whether last response body has given data type
// available data types are listed in dataformat package
func (s *Scenario) TheResponseBodyShouldHaveFormat(dataType string) error {
	return s.State.TheResponseBodyShouldHaveFormat(dataformat.DataFormat(dataType))
}

/*
	IValidateLastResponseBodyWithSchema validates last response body against JSON schema under provided reference.
	reference may be:
		- full OS path to JSON schema
		- relative path from JSON schema's dir which was passed in main_test to initialize *Scenario struct instance,
		- URL
*/
func (s *Scenario) IValidateLastResponseBodyWithSchema(reference string) error {
	return s.State.IValidateLastResponseBodyWithSchemaReference(reference)
}

// IValidateLastResponseBodyWithFollowingSchema validates last response body against JSON schema provided by user.
func (s *Scenario) IValidateLastResponseBodyWithFollowingSchema(schemaBytes *godog.DocString) error {
	return s.State.IValidateLastResponseBodyWithSchemaString(schemaBytes.Content)
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

	return s.State.TimeBetweenLastHTTPRequestResponseShouldBeLessThanOrEqualTo(duration)
}

// TheResponseShouldHaveCookie checks whether last HTTP(s) response has cookie of given name.
func (s *Scenario) TheResponseShouldHaveCookie(name string) error {
	return s.State.TheResponseShouldHaveCookie(name)
}

// TheResponseShouldHaveCookieOfValue checks whether last HTTP(s) response has cookie of given name and value.
func (s *Scenario) TheResponseShouldHaveCookieOfValue(name, valueTemplate string) error {
	return s.State.TheResponseShouldHaveCookieOfValue(name, valueTemplate)
}

// IValidateJSONNodeWithSchemaReference validates last response body JSON node against jsonSchema as provided in reference
func (s *Scenario) IValidateJSONNodeWithSchemaReference(expr, reference string) error {
	return s.State.IValidateJSONNodeWithSchemaReference(expr, reference)
}

// IValidateJSONNodeWithSchemaString validates last response body JSON node against jsonSchema
func (s *Scenario) IValidateJSONNodeWithSchemaString(expr string, jsonSchema *godog.DocString) error {
	return s.State.IValidateJSONNodeWithSchemaString(expr, jsonSchema.Content)
}

// ISaveAs saves into cache arbitrary passed value
func (s *Scenario) ISaveAs(value, cacheKey string) error {
	return s.State.ISaveAs(value, cacheKey)
}

// ISaveFromTheLastResponseJSONNodeAs saves from last response json node under given cache key.
func (s *Scenario) ISaveFromTheLastResponseJSONNodeAs(expr, cacheKey string) error {
	return s.State.ISaveFromTheLastResponseJSONNodeAs(expr, cacheKey)
}

// IPrintLastResponseBody prints response body from last scenario request
func (s *Scenario) IPrintLastResponseBody() error {
	return s.State.IPrintLastResponseBody()
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

	return s.State.IWait(duration)
}

// IStartDebugMode starts debugging mode
func (s *Scenario) IStartDebugMode() error {
	return s.State.IStartDebugMode()
}

// IStopDebugMode stops debugging mode
func (s *Scenario) IStopDebugMode() error {
	return s.State.IStopDebugMode()
}

// IStopScenarioExecution stops scenario execution
func (s *Scenario) IStopScenarioExecution() error {
	return errors.New("scenario stopped")
}
