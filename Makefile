.PHONY: tests

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

# env creates .env file and populates it with default values
env:
	touch .env
	echo "GODOG_DEBUG=false\nGODOG_MY_APP_URL=http://localhost:1234\nGODOG_JSON_SCHEMA_DIR=./assets/test_server/doc/schema" >> .env

# download-dependencies download go packages and godog binary
download-dependencies:
	go mod download
	go install github.com/cucumber/godog/cmd/godog@v0.12.5

# clean removes directories with binaries, git repository, github actions workflow and test suite
clean:
	rm -rf ${git_dir}
	rm -rf ${github_actions_dir}
	rm -rf ${assets_dir}
	rm -rf ${features_dir}
	rm ${gitignore_path}

# tests run all tests concurrently, server should be run manually
tests:
	godog --format=progress --concurrency=2 --random