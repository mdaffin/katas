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
    if ! command -v "${1}" &>/dev/null; then
        echo "Missing '${1}' command. Please install it to continue."
        exit 1
    fi
}

bandit_ssh() {
    strict_mode
    local level="${1}"
    shift

    local passpath="${OUTPATH}/level$((level-1))"
    local user="bandit$((level-1))"
    local password

    [[ -f "${passpath}" ]] || {
        echo "Missing password file '${passpath}'. Please run that level to continue." 1>&2
        return 1
    }
    password="$(head -n1 < "${passpath}"  | tr -d '\n')"

    if [[ "${password}" == "-----BEGIN RSA PRIVATE KEY-----" ]]; then
        bandit_ssh_key "${user}" "${passpath}" "${@}"
    else
        bandit_ssh_password "${user}" "${password}" "${@}"
    fi
}

bandit_ssh_key() {
    strict_mode
    local user="${1}"
    local keyfile="${2}"
    shift 2
    ssh -i "${keyfile}" -p 2220 "${user}@bandit.labs.overthewire.org" "${@}" \
        2> >(grep -v "This is a OverTheWire game server.\|Warning: Permanently added" 1>&2)
}

bandit_ssh_password() {
    strict_mode
    local user="${1}"
    local password="${2}"
    shift 2
    sshpass -p "${password}" \
        ssh -p 2220 "${user}@bandit.labs.overthewire.org" "${@}" \
        2> >(grep -v "This is a OverTheWire game server.\|Warning: Permanently added" 1>&2)
}

# Runs a level with the given command.
run_level() {
    strict_mode
    local out
    local ret
    local level="${1}"
    local passpath="${OUTPATH}/level$((level-1))"
    local outpath="${OUTPATH}/level${level}"
    shift

    [[ -f "${outpath}" ]] && {
        echo "Level${level}: *$(head -n1 < "${outpath}")"
        return 0
    }

    out=$(bandit_ssh "${level}" "${@}")
    ret=$?

    if [[ "${ret}" -ne 0 ]]; then
        echo "SSH command failed: '${*}'"
        return $ret
    fi

    if [[ -z "${out}" ]]; then
        echo "No output from ssh command"
        return 1
    fi

    printf -- "%s" "${out}" > "${outpath}"
    chmod 600 "${outpath}"
    echo "Level${level}: ${out}" | head -n1
}

OUTPATH=out
check_command ssh
check_command sshpass
mkdir -p "${OUTPATH}"
