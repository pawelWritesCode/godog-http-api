![godog-example-setup](https://github.com/pawelWritesCode/godog-example-setup/actions/workflows/go.yml/badge.svg)

# Example godog setup with gdutils

## Overview:

This repository contains skeleton that allow to write behaviour driven tests with use of framework [godog](https://github.com/cucumber/godog)
that implements [gherkin/cucumber](https://cucumber.io/docs/gherkin/) syntax with step library [gdutils](https://github.com/pawelWritesCode/gdutils).

## Project structure:
```
.
├── LICENSE
├── Makefile                        - source of useful commands (make env, make download-dependencies, make clean)
├── README.MD
├── assets                          - temporary folder with project assets
│   ├── gifs                  
│   └── test_server                 - binaries with simple CRUD API server, required ONLY for testing purposes
├── defs                            - 🥒 package with implementation of godog methods(steps)
│   └── scenario.go                 - 🥒 here add your custom methods(steps) definitions if required
├── features                        - 🥒 place for your tests (files with extensions .feature)
│   └── users_crud.feature          - 🥒 simple test feature, required ONLY for testing purposes
├── go.mod
├── go.sum
└── main_test.go                    - 🥒 setup for godog framework

```

## Usage:

#### Prerequisites

* globally visible `godog v0.12` CLI (`godog --version`)
* `.env` file

### First time:

![Usage example](assets/gifs/usage_1.gif)

At first **download go packages & godog CLI**. You can do it by typing in console

```shell
make download-dependencies
```

Afterwards, `godog` CLI (represented as binary file) will be downloaded to `$GOPATH/bin` directory. This path should be added to
your `$PATH` env variable! To checks whether CLI is globally available, type:

```shell
godog --version
```

Note, that project directory should not be inside **GOPATH** !

Next, create `.env` file
```shell
make env
```

Finally, remove unnecessary files and directories ✂ (**run it just once**).

**Warning**: This command removes `.git/`, `.github/`, `bin/`, `assets`, `.gitignore` and example test suite from `features/` dir. If you want 
to keep any of these (for example if you want to use `features/users_crud.feature` as example for your test suites),
then **do not run this command!**
```shell
make clean
```

### Regular:

![Usage example](assets/gifs/usage_2.gif)

Following commands run from local terminal in main project directory:

##### Running **all tests** directly by `godog` CLI

```
godog
```

##### Running **all tests** from console using **go** binary:

```
go test
```

##### Run **single test** directly by `godog` CLI

```
godog features/users_crud.feature
```

##### Run tests with parallelization (many at once)

```
godog --concurrency=X --format=progress
```
where X is level of concurrency (int)