#!/bin/bash

FREEBOX_URL="http://mafreebox.freebox.fr"
_API_VERSION=
_API_BASE_URL=
_SESSION_TOKEN=

######## GLOBAL VARIABLES ########
_JSON_DATA=
_JSON_DECODE_DATA_KEYS=
_JSON_DECODE_DATA_VALUES=

case "$OSTYPE" in
    darwin*) SED_REX='-E' ;;
    *) SED_REX='-r' ;;
esac

if echo "test string" | egrep -ao --color=never "test" &>/dev/null; then
    GREP='egrep -ao --color=never'
else
    GREP='egrep -ao'
fi

######## FUNCTIONS ########

######## FUNCTIONS FROM JSON.SH ########
# This is from https://github.com/dominictarr/JSON.sh
# See LICENSE for more info.

_throw () {
    echo "$*" >&2
    exit 1
}

_tokenize_json () {
    local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    local CHAR='[^[:cntrl:]"\\]'
    local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
    # The Freebox api don't put quote between string values
    # STRING2 solve this problem
    local STRING2="[^:,][a-zA-Z][a-zA-Z0-9_-]*[^],}]"
    local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
    local KEYWORD='null|false|true'
    local SPACE='[[:space:]]+'

    $GREP "$STRING|$STRING2|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
    # " Fix xemacs fontification
}

_parse_array () {
    local index=0
    local ary=''
    read -r token
    case "$token" in
        ']') ;;
        *)
           while : ; do
               _parse_value "${1%*.}" "[$index]."
               index=$((index+1))
               ary="$ary""$value"
               read -r token
               case "$token" in
                   ']') break ;;
                   ',') ary="$ary," ;;
                   *) _throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '[%s]' "$ary")
}

_parse_object () {
    local key
    local obj=''
    read -r token
    case "$token" in
        '}') ;;
        *)
           while : ; do
               case "$token" in
                   '"'*'"') key=$token;;
                   *) _throw "EXPECTED string GOT ${token:-EOF}" ;;
               esac
               read -r token
               case "$token" in
                   ':') ;;
                   *) _throw "EXPECTED : GOT ${token:-EOF}" ;;
               esac
               read -r token
               _parse_value "$1" "$key"
               obj="$obj$key:$value"
               read -r token
               case "$token" in
                   '}') break ;;
                   ',') obj="$obj," ;;
                   *) _throw "EXPECTED , or } GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '{%s}' "$obj")
}

_parse_value () {
    local jpath="${1:-}${2:-}"
    case "$token" in
        '{') _parse_object "$jpath" ;;
        '[') _parse_array  "$jpath";;
        # At this point, the only valid single-character tokens are digits.
        ''|[!0-9]) _throw "EXPECTED value GOT ${token:-EOF}" ;;
        *) value=$token ;;
    esac
    [ "${value:-}" = '' ] && return
    jpath=${jpath//\"\"/.}
    jpath=${jpath//\"/}
    local key="${jpath%*.}"
    [[ "$key" = '' ]] && return
    _JSON_DECODE_DATA_KEYS+=("$key")
    value=${value#\"}  # Remove leading "
    value=${value%*\"} # Remove trailing "
    value=${value//\\\///} # convert \/ to /
    _JSON_DECODE_DATA_VALUES+=("$value")
}

_parse_json () {
    read -r token
    _parse_value
    read -r token
    case "$token" in
        '') ;;
        *) _throw "EXPECTED EOF GOT $token" ;;
    esac
}

######## END OF FUNCTIONS FROM JSON.SH ########

function _parse_and_cache_json {
    if [[ "$_JSON_DATA" != "$1" ]]; then
        _JSON_DATA="$1"
        _JSON_DECODE_DATA_KEYS=("")
        _JSON_DECODE_DATA_VALUES=("")
        _parse_json < <(echo "$_JSON_DATA" | _tokenize_json)
    fi
}

function get_json_value_for_key {
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        if [[ "${_JSON_DECODE_DATA_KEYS[$i]}" = "$2" ]]; then
            echo ${_JSON_DECODE_DATA_VALUES[$i]}
            return 0
        fi
        ((i++))
    done
    return 1
}

function dump_json_keys_values {
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        printf "%s = %s\n" "${_JSON_DECODE_DATA_KEYS[$i]}" "${_JSON_DECODE_DATA_VALUES[$i]}"
        ((i++))
    done
}

function _check_success {
    local value=$(get_json_value_for_key "$1" success)
    if [[ "$value" != true ]]; then
        echo "$(get_json_value_for_key "$1" msg): $(get_json_value_for_key "$1" error_code)" >&2
        return 1
    fi
    return 0
}

function _check_freebox_api {
    local answer=$(curl -s "$FREEBOX_URL/api_version")
    _API_VERSION=$(get_json_value_for_key "$answer" api_version | sed 's/\..*//')
    _API_BASE_URL=$(get_json_value_for_key "$answer" api_base_url)
}

function call_freebox_api {
    local api_url="$1"
    local data="${2-}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")
    [[ -n "$data" ]] && options+=(-d "$data")
    answer=$(curl -s "$url" "${options[@]}")
    _check_success "$answer" || return 1
    echo "$answer"
}

function login_freebox {
    local APP_ID="$1"
    local APP_TOKEN="$2"
    local answer=

    answer=$(call_freebox_api 'login') || return 1
    local challenge=$(get_json_value_for_key "$answer" "result.challenge")
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^(stdin)= //')
    answer=$(call_freebox_api '/login/session/' "{\"app_id\":\"${APP_ID}\", \"password\":\"${password}\" }") || return 1
    _SESSION_TOKEN=$(get_json_value_for_key "$answer" "result.session_token")
}

function authorize_application {
    local APP_ID="$1"
    local APP_NAME="$2"
    local APP_VERSION="$3"
    local DEVICE_NAME="$4"
    local answer=

    answer=$(call_freebox_api 'login/authorize' "{\"app_id\":\"${APP_ID}\", \"app_name\":\"${APP_NAME}\", \"app_version\":\"${APP_VERSION}\", \"device_name\":\"${DEVICE_NAME}\" }")
    local app_token=$(get_json_value_for_key "$answer" "result.app_token")
    local track_id=$(get_json_value_for_key "$answer" "result.track_id")

    echo 'Please grant/deny access to the application on the Freebox LCD...' >&2
    local status='pending'
    while [[ "$status" == 'pending' ]]; do
      sleep 5
      answer=$(call_freebox_api "login/authorize/$track_id")
      status=$(get_json_value_for_key "$answer" "result.status")
    done
    echo "Authorization $status" >&2
    [[ "$status" != 'granted' ]] && return 1
    echo >&2
    cat <<EOF
MY_APP_ID="$APP_ID"
MY_APP_TOKEN="$app_token"
EOF
}

function reboot_freebox {
    call_freebox_api '/system/reboot' '{}' >/dev/null
}

######## MAIN ########

# fill _API_VERSION and _API_BASE_URL variables
_check_freebox_api
