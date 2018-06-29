#!/bin/bash

# Enables strict mode which causes the script to end one first error with the
# location and command that failed.
strict_mode() {
    set -ueo pipefail
    IFS=$'\n\t'
}

# Checks to see if a command already exists, used for validating required
# commands are present.
check_command() {
    strict_mode
    if ! command -v ${1} &>/dev/null; then
        echo "Missing '${1}' command. Please install it to continue."
        exit 1
    fi
}

bandit_ssh() {
    local level="${1}"
    local passpath="out/level$((level-1))"
    local user="bandit$((level-1))"
    local password="$(cat ${passpath})"
    shift

    [[ -f "${passpath}" ]] || {
        echo "Missing password file '${passpath}'. Please run that level to continue."
        return 1
    }

    sshpass -p "${password}" \
        ssh -p 2220 "${user}@bandit.labs.overthewire.org" "${@}" \
        2> >(grep -v "This is a OverTheWire game server." 1>&2)
}

# Runs a level with the given command.
run_level() {
    strict_mode
    local level="${1}"
    local passpath="out/level$((level-1))"
    local outpath="out/level${level}"
    shift

    # Password for this level is cached so return as we don't need to run
    [[ -f "${outpath}" ]] && {
        echo "Level${level}: $(cat "${outpath}")"
        return 0
    }

    local out=$(bandit_ssh "${level}" "${@}" | head -n1 | tr -d '\n')
    local ret=$?

    if [[ "${ret}" -ne 0 ]]; then
        echo "SSH command failed: '${@}'"
        return $ret
    fi

    printf "${out}" > "${outpath}"
    echo "Level${level}: ${out}"
}

CSD=$(dirname "$(readlink -f "$0")")
check_command ssh
check_command sshpass
