#!/usr/bin/env bash

set -e

WORKSPACE="$HOME/workspace"
POST_INSTALL="\n\n$(tput setaf 2)************\n* Success! *\n************\n$(tput setaf 6)"

function clone() {
    local remote="$1"
    local destination="$2"

    if [[ "$destination" == "" ]]; then
      destination="$WORKSPACE/$(echo "$remote" | sed "s/.*\///" | sed "s/.git$//")"
    fi

    if [ -d "$destination" ]; then
      return 0
    fi

    git clone "$remote" "$destination"
}

function bash-profile() {
    ln -fs "$PWD/.bash_profile" "$HOME/"
    source "$HOME/.bash_profile"
}

function make-workspace() {
    mkdir "$HOME/workspace" 2> /dev/null || true
}

function homebrew() {
    set +e
    which brew > /dev/null
    local exit_code="$?"
    set -e

    if [[ "$exit_code" -eq 0 ]]; then
      return 0
    fi

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function brewfile() {
    brew bundle --file="$PWD/Brewfile"
}

function git-repositories() {
    clone https://github.com/pivotal-cf/pcf-bosh-ci "$WORKSPACE/ci"
    clone https://github.com/cloudfoundry/bosh-deployment
    clone https://github.com/cloudfoundry/cf-deployment
    clone https://github.com/pivotal-cf/p-ert-bosh-experiment
    clone https://github.com/pivotal-cf/pcf-bosh-terraforming-gcp "$WORKSPACE/terraforming-gcp"
}

function git-config() {
    git config --global url."git@github.com:".pushInsteadOf https://github.com/
    git config --global submodule.fetchJobs 16

    ln -fs "$PWD/.git-authors" "$HOME/"
}

function bash-it-setup() {
    clone https://github.com/revans/bash-it ~/.bash_it

    set +e

    bash-profile

    bash-it update

    bash-it enable completion system
    bash-it enable completion git
    bash-it enable completion ssh

    bash-it enable plugin fzf

    bash-it enable alias general

    ln -fs "$PWD"/bash_it/* "$BASH_IT/custom/"

    bash-profile

    set -e
}

function mount-gcs() {
    mkdir -p "$HOME/gcs/pcf-bosh-ci" 2> /dev/null || true

    set +e
    mount | grep -q pcf-bosh-ci
    local exit_code="$?"
    set -e

    if [[ "$exit_code" -ne 0 ]]; then
        POST_INSTALL="${POST_INSTALL}\nTo mount your GCS bucket, run:\n"
        POST_INSTALL="${POST_INSTALL}gcsfuse pcf-bosh-ci \"$HOME/gcs/pcf-bosh-ci\"\n"
    fi
}

function pivotal_ide_prefs() {
    clone https://github.com/pivotal/pivotal_ide_prefs

    pushd "$WORKSPACE/pivotal_ide_prefs" > /dev/null
        cli/bin/ide_prefs install --ide=intellij
    popd
}

function credalert() {
    echo "Installing cred alert cli"

    set +e
    which cred-alert-cli > /dev/null
    local exit_code="$?"
    set -e

    #cli
    if [[ "$exit_code" -ne 0 ]]; then
        wget -q -O /usr/local/bin/cred-alert-cli https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_darwin
        chmod +x /usr/local/bin/cred-alert-cli
    else
        cred-alert-cli update
    fi

    #githooks repo
    echo "Setting up git-hooks-core-repo"
    clone https://github.com/pivotal-cf-experimental/git-hooks-core
    git config --global core.hooksPath "$WORKSPACE/git-hooks-core"
}

function post-install() {
    echo -e "$POST_INSTALL"
}

function main() {
    make-workspace
    homebrew
    brewfile
    git-repositories
    git-config
    bash-it-setup
    mount-gcs
    pivotal_ide_prefs
    credalert
    post-install

#    TODO wait until the CLI is downloadable from somewhere other than Concourse
#    bosh-cli
}

main
