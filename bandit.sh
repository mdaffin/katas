#!/bin/bash
strict_mode() {
    set -uo pipefail
    trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
    IFS=$'\n\t'
}
strict_mode

check_command() {
    if ! command -v ${1} &>/dev/null; then
        echo "Missing '${1}' command. Please install it to continue."
        exit 1
    fi
}

ssh() {
    local user=${1}
    local password=${2}
    shift 2
    sshpass -p "${password}" ssh -p 2220 "${user}@bandit.labs.overthewire.org" "${@}"
}


check_command ssh
check_command sshpass

level0() {
    strict_mode
    ssh bandit0 bandit0 cat readme | head -n1 | tr -d '\n'
}

level1_password=$(level0)
echo "Level0: $level1_password"
