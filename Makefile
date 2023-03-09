.PHONY: tests-using-compose tests-using-host tests-using-docker down

# Following are environment variables required for default test framework setup
GODOG_DEBUG=false
GODOG_MY_APP_URL=http://localhost:1234
GODOG_JSON_SCHEMA_DIR=./assets/test_server/doc/schema

# git_dir is path to default git folder with repository
git_dir=./.git

# github_actions_dir is path to github actions directory with workflow
github_actions_dir=./.github

# features_dir is path to directory with features
features_dir=./features

# gitignore_path is path to .gitignore file
gitignore_path=./.gitignore

# assets_dir is path to directory with temporary assets
assets_dir=./assets

# image_tag represents default tag name for docker image
image_tag=godog-http-api

all: env download-dependencies build

# env creates .env file and populates it with default values
env:
	touch .env
	echo "GODOG_DEBUG=${GODOG_DEBUG}\n\
	GODOG_MY_APP_URL=${GODOG_MY_APP_URL}\n\
	GODOG_JSON_SCHEMA_DIR=${GODOG_JSON_SCHEMA_DIR}" > .env

# download-dependencies download go packages and godog binary
download-dependencies:
	go mod download
	go install github.com/cucumber/godog/cmd/godog@v0.12.6

# build builds docker image from Dockerfile and tags it
build:
	docker build -t ${image_tag} .

# clean removes directories with binaries, git repository, github actions workflow and test suite
clean:
	rm -rf ${git_dir}
	rm -rf ${github_actions_dir}
	rm -rf ${assets_dir}
	rm -rf ${features_dir}
	rm ${gitignore_path}

# tests-using-host demonstrates how tests can be run using godog binary on host side
# command runs all tests from features/httpbin/* directory
tests-using-host:
	godog --format=progress --concurrency=2 --random ${features_dir}/httpbin

# tests-using-docker demonstrates how tests can be run using docker
# command runs tests from features/httpbin/* directory
#
# before first run, use "build" & "env" commands, or single command "all" above
#
# command can be reused many times
# you can add/remove/modify project files or tests from features/httpbin/* directory
# docker volumes will reflect those changes in container file system
# without need to rebuild image after each change in project
#
# feel free to modify command so it match your needs, for example
# this command can be easily modified so it can run tests from any directory user wish within project
# or you can pass additional environment variables if needed
tests-using-docker:
	docker run \
	 --rm \
	 -v $(shell pwd):/godog-http-api \
	 --name pawelWritesCode.${image_tag}.tests \
	 --env-file .env \
	 ${image_tag} run --format=progress --concurrency=2 ${features_dir}/httpbin

# tests-using-compose demonstrates how tests can be run in multi-container project using docker compose
# command runs tests related to user-crud service
# full definition of multi-container project can be found in compose.yaml file
#
# command may be used multiple times
# after last usage, it is recommended to use "down" command below to clean up containers
tests-using-compose:
	docker compose --profile tests up --abort-on-container-exit

# down cleans up containers created by "tests-using-compose" command above
down:
	sudo docker compose down --remove-orphans

