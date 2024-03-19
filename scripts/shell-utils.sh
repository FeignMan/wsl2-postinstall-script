#!/bin/bash

# Usage: printBanner "my title" "*"
printBanner() {
    local msg="> ${1} <"
    local edge
    edge=${msg//?/$2}
    tput setaf 4
    echo -e "\n${edge}"
    echo "$(tput setaf 3)${msg}$(tput setaf 4)"
    echo -e "${edge}\n"
    tput sgr0
}

readChoice() {
    printf "%s [Y|n]: " "${1}"
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty "$old_stty_cfg"
    if [ "$answer" != "${answer#[Yy]}" ];then
        echo Yes
        return 0
    else
        echo No
        return 1
    fi
}

isUrlValid() {
    local -r URL_REGEX='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

    if [[ ${#1} -ne 0 && $1 =~ $URL_REGEX ]]; then
        return 0
    else
        return 1
    fi
}

makeCurlRequest() {
    local http_url http_method http_timeout http_headers http_status_code output_filepath curl_command exit_code
    local -a http_headers_list

    # Either print the help message
    if [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [ -z "${1}" ]; then
        echo "
    USAGE: makeCurlRequest <URL> [options]

Helper command to make curl requests. Accepts the following options:

-m | --method       : HTTP Verb to use <GET/PUT/POST/DELETE/HEAD>
-o | --out-file     : Override the default output file path ${PRIVATE_FOLDER_PATH}curlRequestResponse
-t | --timeout      : Timeout in seconds. Defaults to 15 seconds
-H | --headers      : Add any other custom headers. Takes a list of headers but, very importantly, needs to be the last option provided to the command
-h | --help         : Print this help text
-BA | --bearer-auth : Adds provided bearer auth token to the headers - \"Authorization: Bearer <provided token>\"
"
        return 0
    else
        # Or expect the first parameter to be the URL
        isUrlValid "${1}" && http_url="${1}"
    fi

    if [[ -z "${http_url}" ]]; then
        echo -e "$(tput setaf 1)[makeCurlRequest][isUrlValid] Error: A valid URL is expected as the first argument!\nReceived - ${1}$(tput sgr0)" >&2
        return 1
    fi
    shift

    # default parameters
    http_method="-X GET"
    http_timeout="-m 15"
    output_filepath="-o ${PRIVATE_FOLDER_PATH}curlRequestResponse"

    while (($# > 0)); do
        case "${1}" in
        -m | --method)
            shift
            http_method="-X ${1}"
            ;;
        -o | --out-file)
            shift
            output_filepath="--output ${1}"
            ;;
        -t | --timeout)
            shift
            http_timeout="-m {$1}"
        ;;
        -BA | --bearer-auth)
            shift
            # http_auth="{$1}"
            http_headers+=" -H \"Authorization: Bearer ${1}\""
        ;;
        -H | --headers)
            shift   # consume the flag and take remaining strings as headers
            http_headers_list=("$@")
        ;;            
        esac
        shift
    done

    # create string of headers
    for header in "${http_headers_list[@]}"; do
        http_headers+=" -H ${header}"
    done

    # http_status_code=$(curl --write-out "%{http_code}" --silent "${http_method}" "$http_url" "${output_filepath}" "${http_timeout}" "${http_headers}")
    curl_command="curl --write-out '%{http_code}' --silent ${http_method} ${http_url} ${output_filepath} ${http_timeout} ${http_headers}"
    exit_code=$?
    http_status_code=$(eval "$curl_command")
    echo -n "$http_status_code"

    if [[ ${http_status_code} -lt 200 || ${http_status_code} -gt 299 ]]; then
        echo -e "$(tput setaf 1)\n[makeCurlRequest] Error - Curl request failed with exit code: [$exit_code] and HTTP status code: [${http_status_code}] $(tput sgr0)" >&2
        echo -e "\nFailed curl command: $(tput setaf 3)$curl_command$(tput sgr0)"
        return 1
    fi

    # echo -e "[ToDo][Remove] Successful curl request to [$http_url] with response code [$http_status_code]"
    return 0
}
