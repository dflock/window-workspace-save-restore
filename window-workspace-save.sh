#!/usr/bin/env bash

# Bash strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o nounset   # Using an undefined variable is fatal
set -o errexit   # A sub-process/shell returning non-zero is fatal
# set -o pipefail  # If a pipeline step fails, the pipelines RC is the RC of the failed step
# set -o xtrace    # Output a complete trace of all bash actions; uncomment for debugging

# IFS=$'\n\t'  # Only split strings on newlines & tabs, not spaces.

function init() {
  readonly script_path="${BASH_SOURCE[0]:-$0}"
  readonly script_dir="$(dirname "$(readlink -f "$script_path")")"
  readonly script_name="$(basename "$script_path")"

  verbose=false

  setup_colors
  parse_params "$@"
}

usage() {
  cat <<EOF

Save the current workspace of all windows, to stdout.

${bld}USAGE${off}
  $script_name

${bld}ARGUMENTS${off}
  help             show this help

${bld}OPTIONS${off}
  -h, --help       show this help
  -v, --verbose    show verbose/debug output

${bld}EXAMPLES${off}
  ${gry}# Save the workspce placement of all windows to a file:${off}
  $ $script_name > ~/tmp/windows.txt

  ${gry}# Save the workspce placement of all Google Chrome windows to a file:${off}
  $ $script_name | grep 'Google Chrome' > ~/tmp/chrome-windows.txt
EOF
  exit
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    # Control sequences for fancy colours
    readonly gry="$(tput setaf 240 2> /dev/null || true)"
    readonly bld="$(tput bold 2> /dev/null || true)"
    readonly off="$(tput sgr0 2> /dev/null || true)"
  else
    readonly gry=''
    readonly bld=''
    readonly off=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

vmsg() {
  if [ "$verbose" = "true" ]; then
    msg "$@"
  fi
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

function parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
      -h | --help | help)
        usage
        ;;
      -v | --verbose)
        verbose=true
        ;;
      *)
        msg "Unknown parameter: $param"
        usage
        ;;
    esac
  done
}

init "$@"

if ! command -v wmctrl &> /dev/null
then
  die "wmctrl could not be found\n\
    $script_name requires wmctrl (tested with 1.07)\n\
    See: https://www.freedesktop.org/wiki/Software/wmctrl/" 127
fi

wmctrl -l | awk '{ if( $2 != "-1") { $1=""; $3="";  print $0} }' | sort -n