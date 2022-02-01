package defs

import (
	"github.com/cucumber/godog"
	"github.com/pawelWritesCode/gdutils"
)

// Scenario represents Scenario unit in context of godog framework.
type Scenario struct {
	// State is responsible for data flow inside one scenario.
	State *gdutils.State
}

// IGenerateARandomRunesOfLengthWithUnicodeCharactersAndSaveItAs creates random runes generator func using provided charset.
// return func creates runes from provided range and preserve it under given cacheKey
func (s *Scenario) IGenerateARandomRunesOfLengthWithUnicodeCharactersAndSaveItAs(charset string) func(from, to int, cacheKey string) error {
	return s.State.IGenerateARandomRunesInTheRangeToAndSaveItAs(charset)
}

// IGenerateARandomFloatInTheRangeToAndSaveItAs generates random float from provided range and preserve it under given name in cache.
func (s *Scenario) IGenerateARandomFloatInTheRangeToAndSaveItAs(from, to int, cacheKey string) error {
	return s.State.IGenerateARandomFloatInTheRangeToAndSaveItAs(from, to, cacheKey)
}

// IGenerateARandomIntInTheRangeToAndSaveItAs generates random integer from provided range and preserve it under given name in cache.
func (s *Scenario) IGenerateARandomIntInTheRangeToAndSaveItAs(from, to int, cacheKey string) error {
	return s.State.IGenerateARandomIntInTheRangeToAndSaveItAs(from, to, cacheKey)
}

// IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs creates random sentence generator func
func (s *Scenario) IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(charset string, minWordLength, maxWordLength int) func(from, to int, cacheKey string) error {
	return s.State.IGenerateARandomSentenceInTheRangeFromToWordsAndSaveItAs(charset, minWordLength, maxWordLength)
}

/*
	ISendRequestToWithBodyAndHeaders sends HTTP(s) request with provided body and headers.
	Argument method indices HTTP(s) request method for example: "POST", "GET" etc.
	Argument urlTemplate should be full url path. May include template values.
	Argument bodyTemplate should be slice of bytes marshallable on bodyHeaders struct. May include template values
*/
func (s *Scenario) ISendRequestToWithBodyAndHeaders(method, urlTemplate string, reqBody *godog.DocString) error {
	return s.State.ISendRequestToWithBodyAndHeaders(method, urlTemplate, reqBody)
}

// IPrepareNewRequestToAndSaveItAs prepares new request and saves it in cache under cacheKey.
func (s Scenario) IPrepareNewRequestToAndSaveItAs(method, urlTemplate, cacheKey string) error {
	return s.State.IPrepareNewRequestToAndSaveItAs(method, urlTemplate, cacheKey)
}

// ISetFollowingHeadersForPreparedRequest sets provided headers for previously prepared request.
func (s Scenario) ISetFollowingHeadersForPreparedRequest(cacheKey string, headersTemplate *godog.DocString) error {
	return s.State.ISetFollowingHeadersForPreparedRequest(cacheKey, headersTemplate)
}

// ISetFollowingBodyForPreparedRequest sets body for previously prepared request.
// bodyTemplate may be in any format and accepts template values.
func (s Scenario) ISetFollowingBodyForPreparedRequest(cacheKey string, bodyTemplate *godog.DocString) error {
	return s.State.ISetFollowingBodyForPreparedRequest(cacheKey, bodyTemplate)
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

// TheResponseBodyShouldHaveType checks whether last response body has given data type
// available data types are listed as package constants
func (s *Scenario) TheResponseBodyShouldHaveType(dataType string) error {
	return s.State.TheResponseBodyShouldHaveType(dataType)
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
	return s.State.IWait(timeInterval)
}

// IStartDebugMode starts debugging mode
func (s *Scenario) IStartDebugMode() error {
	return s.State.IStartDebugMode()
}

// IStopDebugMode stops debugging mode
func (s *Scenario) IStopDebugMode() error {
	return s.State.IStopDebugMode()
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
	return s.State.IValidateLastResponseBodyWithSchemaString(schemaBytes)
}
