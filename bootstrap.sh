#!/usr/bin/env bash

app_name='oh-my-mint'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.oh-my-mint"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/robchou/oh-my-mint.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='master'
debug_mode='0'
fork_maintainer='0'

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

############################ SETUP FUNCTIONS

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    debug
}

setup_oh_my_zsh() {
    success "Setup oh-my-zsh"
}

setup_spf13() {
    echo let g:spf13_bundle_groups=[\'general\', \'neocomple\'] > .vimrc.before.fork
    echo let g:airline_powerline_fonts = 1 > ~/.vimrc.before.local
    echo Bundle \'godlygeek/tabular\' > ~/.vimrc.bundles.local

    curl https://j.mp/spf13-vim3 -L -o - | sh
}

############################ MAIN()
main() {
    variable_set "$HOME"
    program_must_exist "vim"
    program_must_exist "git"

    sync_repo       "$APP_PATH" \
                    "$REPO_URI" \
                    "$REPO_BRANCH" \
                    "$app_name"
    setup_spf13
    msg             "\nThanks for installing $app_name."
}

main
