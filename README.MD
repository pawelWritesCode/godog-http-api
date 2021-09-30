# Example godog setup with gdutils

## Overview:

This repository contains skeleton that allow to write behaviour driven tests with use of framework [godog](https://github.com/cucumber/godog)
that implements [gherkin](https://cucumber.io/docs/gherkin/) syntax with step library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Directory structure:

Directory `features/` contains **tests** (_files with extension `.feature`_) aggregated into logic subdirectories.

File `main_test.go` holds set-up for godog framework

Package `defs` holds definitions of steps (methods) used in every test.

## Usage:

#### Prerequisites

* globally visible `godog v0.12` CLI (`godog --version`)
* `.env` file with env variable `GODOG_DEBUG` set to `true` or `false`

### First time:

Tests may be run locally from OS host console(terminal). At first
**download go packages & godog CLI**. You can do it by typing in console

```
go mod download
go install github.com/cucumber/godog/cmd/godog@v0.12.0
```

Afterwards, `godog` CLI (represented as binary file) will be downloaded to `$GOPATH/bin` directory. This path should be added to
your `$PATH` env variable! To checks whether CLI is globally available, type:

```
godog --version
```

Note, that project directory should not be inside **GOPATH** !

### Regular:

##### Running **all tests** directly by `godog` CLI

In main project directory run from local console(terminal) command:

```
godog
```

or

```
go test
```

##### Run **single test** directly by `godog` CLI

In main project directory run from local console(terminal) command:

```
godog features/test.feature
```

##### Run tests with parallelization (many at once)

In main project directory run from local console(terminal) command:

```
godog --concurrency=X --format=progress
```
where X is level of concurrency (int)