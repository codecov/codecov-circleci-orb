#!/usr/bin/env bash
source ./codecov_envs

set +u
say() {
  echo -e "$1"
}

exit_if_error() {
  say "$r==> $1$x"
  if [ "$CODECOV_FAIL_ON_ERROR" = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
  fi
}

lower() {
  echo $(echo $1 | sed 's/CODECOV//' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]')
}

k_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "--$(lower "$1")"
  fi
}

v_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "$(eval echo \$"CODECOV_$1")"
  fi
}

write_bool_args() {
  if [ "$(eval echo \$$1)" = "true" ] || [ "$(eval echo \$$1)" = "1" ];
  then
    echo "-$(lower $1)"
  fi
}

b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
x="\033[0m"
retry="--retry 5 --retry-delay 2"

codecov_cli_args=()

codecov_cli_args+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
codecov_cli_args+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CODECOV_YML_PATH" ]
then
  codecov_cli_args+=( "--codecov-yml-path" )
  codecov_cli_args+=( "$CODECOV_YML_PATH" )
fi
codecov_cli_args+=( $(write_bool_args CODECOV_DISABLE_TELEM) )
codecov_cli_args+=( $(write_bool_args CODECOV_VERBOSE) )

if [ -n "$CODECOV_TOKEN_VAR" ];
then
  token="$(eval echo \$$CODECOV_TOKEN_VAR)"
else
  token="$(eval echo $CODECOV_TOKEN)"
fi
say "$g ->$x Token length: ${#token}"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi

codecov_args=()
if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then

# Args for create commit
codecov_args+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
codecov_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_args+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
codecov_args+=( $(k_arg PR) $(v_arg PR))
codecov_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))

# Args for create report
codecov_args+=( $(k_arg CODE) $(v_arg CODE))

# Args for do upload
codecov_args+=( $(k_arg ENV) $(v_arg ENV))

OLDIFS=$IFS;IFS=,

codecov_args+=( $(k_arg BRANCH) $(v_arg BRANCH))
codecov_args+=( $(k_arg BUILD) $(v_arg BUILD))
codecov_args+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
codecov_args+=( $(k_arg DIR) $(v_arg DIR))
codecov_args+=( $(write_bool_args CODECOV_DISABLE_FILE_FIXES) )
codecov_args+=( $(write_bool_args CODECOV_DISABLE_SEARCH) )
codecov_args+=( $(write_bool_args CODECOV_DRY_RUN) )

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    codecov_args+=( "--exclude" "$directory" )
  done
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    codecov_args+=( "--file" "$file" )
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    codecov_args+=( "--flag" "$flag" )
  done
fi

codecov_args+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
codecov_args+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
codecov_args+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
codecov_args+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
codecov_args+=( $(write_bool_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
codecov_args+=( $(write_bool_args CODECOV_RECURSE_SUBMODULES) )
codecov_args+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
codecov_args+=( $(write_bool_args CODECOV_LEGACY) )
if [ -n "$CODECOV_NAME" ];
then
  codecov_args+=( "--name" "$CODECOV_NAME" )
fi
codecov_args+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
codecov_args+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
codecov_args+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    codecov_args+=( "--plugin" "$plugin" )
  done
fi

codecov_args+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
codecov_args+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))

IFS=$OLDIFS
elif [ "$CODECOV_RUN_CMD" == "empty-upload" ]; then

codecov_args+=( $(k_arg BRANCH) $(v_arg BRANCH))
codecov_args+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
codecov_args+=( $(write_bool_args CODECOV_FORCE) )
codecov_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_args+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
codecov_args+=( $(k_arg PR) $(v_arg PR))
codecov_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))
elif [ "$CODECOV_RUN_CMD" == "pr-base-picking" ]; then

codecov_args+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
codecov_args+=( $(k_arg PR) $(v_arg PR))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))
codecov_args+=( $(k_arg SERVICE) $(v_arg SERVICE))
elif [ "$CODECOV_RUN_CMD" == "send-notifications" ]; then

codecov_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_args+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
codecov_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_CMD"
  exit
fi
env | grep -io "CODECOV_.*=" | tr "=" " " | while read -r val; do echo "export $val=$(eval echo \"\$$val\")"; done > ./codecov_envs
cat ./codecov_envs
