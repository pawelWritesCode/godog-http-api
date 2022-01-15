#bin_dir is path to directory with server binaries
bin_dir=./bin

#git_dir is path to default git folder with repository
git_dir=./.git

#github_actions_dir is path to github actions directory with workflow
github_actions_dir=./.github

#features_dir is path to directory with features
features_dir=./features

#gitignore_path is path to .gitignore file
gitignore_path=./.gitignore

#env creates .env file and populates it with default values
env:
	touch .env
	echo "GODOG_DEBUG=false\nGODOG_MY_APP_URL=http://localhost:1234\nGODOG_JSON_SCHEMA_DIR=/your/local/full/path/to/schema/directory" >> .env

#download-dependencies download go packages and godog binary
download-dependencies:
	go mod download
	go install github.com/cucumber/godog/cmd/godog@v0.12.0

#clean removes directories with binaries, git repository, github actions workflow and test suite
clean:
	rm -rf ${bin_dir}
	rm -rf ${git_dir}
	rm -rf ${github_actions_dir}
	rm ${features_dir}/users_crud.feature
	rm ./usage_1.gif
	rm ./usage_2.gif
	rm ${gitignore_path}