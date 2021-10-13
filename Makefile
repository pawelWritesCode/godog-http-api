#bin_dir is path to directory with server binaries
bin_dir=./bin

#git_dir is path to default git folder with repository
git_dir=./.git

#github_actions_dir is path to github actions directory with workflow
github_actions_dir=./.github

#features_dir is path to directory with features
features_dir=./features

#env creates .env file and populates it with default values
env:
	touch .env
	echo "GODOG_DEBUG=false\nGODOG_MY_APP_URL=http://localhost:1234" >> .env

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