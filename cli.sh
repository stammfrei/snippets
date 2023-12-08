#! /usr/bin/env bash
# This file is template to make a basic Bash CLI with subcommand
#
# All functions not prefixed with `_` will be subcommands in this CLI.
#
# Read the file to understand how it works.

# Script sysnopsis
read -r -d '' SYNOPSIS <<EOF
Write the global descriptions of your CLI here.

This will be rendered when calling $0 help.
EOF

# Add colored output
_C_RED="\e[31m"
_C_GREEN="\e[32m"
_C_YELLOW="\e[33m"
_C_BLUE="\e[36m"
_C_RESET="\e[0m"

# -- Utilities --
# Add internal function here with a '_' as prefix
# All command name prefixed with `_` will not be available as subcommand.
# Echoes error logs to stderr
function _log() {
	local level="${1:-"i"}"
	shift
	local msg="${*}"
	case "$level" in
	"i" | "info")
		echo -e "${_C_GREEN}info${_C_RESET}: ${msg}"
		;;
	"w" | "warning")
		echo -e "${_C_WARNING}warn${_C_RESET}: ${msg}"
		;;
	"e" | "error")
		echo -e "${_C_RED}error${_C_RESET}: ${msg}"
		;;
	"d" | "debug")
		echo -e "${_C_BLUE}debug${_C_RESET}: ${msg}"
		;;
	*)
		# In case of non valid input, assume info and print all args
		_log i "$level" "$@"
		;;
	esac
} 1>&2

# This functions expect 2 arguments, the function name and the description
# This is a tool to expose documentation to the script user
function _doc() {
	local name=${1:?Please input the name of your function first}
	shift

	local description=${*:-""}

	_HELP[${name}]=$description
}

# Create the global var for _doc
declare -A _HELP

# -- Subcommands --
# Each function is a subcommand of this CLI
# Add a call to _doc <func> <description> to add help on your command
_doc "test" "testing things"
function test() {
	_log i testing things
}

_doc "start" "start something"
function start() {
	_log i "starting something"
}

# -- Standard help command
_doc "help" "display the help and exit"
function help() {
	echo "-- $0 --"
	echo "$SYNOPSIS"
	echo ""
	echo "-- Available subcommands --"
	for command in "${!_HELP[@]}"; do
		echo "# ${_HELP[${command}]}"
		echo "$0 ${command}"
		echo ""
	done
}

# -- Argument parsing
# Do not edit this part unless you know what you are doing.
#
# This if condition is is equivalent to `if __name__ == "__name__" in python`
# If you source the script, it will not exec.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# Parse all function, pick all the one not prefixed with `_`
	# and put it in an array called functions.
	_functions=()
	while IFS= read -r line; do
		_func="${line#"declare -f "}"
		if [ "${_func:0:1}" != "_" ]; then
			_functions+=("$_func")
		fi
	done < <(printf '%s\n' "$(declare -F)")

	# Parse the fist arg as subcommand
	cmd="${1:-"__empty__"}"
	shift

	case "$cmd" in
	"__empty__")
		_log e "Missing subcommand"
		help
		exit 3
		;;

	"help" | "-h" | "--help")
		# Get help
		help
		exit 0
		;;

	*)
		# Try to match the subcommand to our functions
		for function in "${_functions[@]}"; do
			if [ "$cmd" == "$function" ]; then
				# execute the subcommand with subcommand arguments.
				$function "$@"
				exit 0
			fi
		done

		# Or exit displaying help
		_log e "command not found $cmd"
		help
		exit 1
		;;
	esac
fi
