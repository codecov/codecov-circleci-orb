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

CODECOV_CLI_ARGS=()

CODECOV_CLI_ARGS+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
CODECOV_CLI_ARGS+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CODECOV_YML_PATH" ]
then
  CODECOV_CLI_ARGS+=( "--codecov-yml-path" )
  CODECOV_CLI_ARGS+=( "$CODECOV_YML_PATH" )
fi
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_DISABLE_TELEM) )
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_VERBOSE) )

CODECOV_ARGS=()
if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then

# Args for create commit
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))

# Args for create report
CODECOV_ARGS+=( $(k_arg CODE) $(v_arg CODE))

# Args for do upload
CODECOV_ARGS+=( $(k_arg ENV) $(v_arg ENV))

OLDIFS=$IFS;IFS=,

CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(k_arg BUILD) $(v_arg BUILD))
CODECOV_ARGS+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
CODECOV_ARGS+=( $(k_arg DIR) $(v_arg DIR))
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_FILE_FIXES) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_SEARCH) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DRY_RUN) )

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    CODECOV_ARGS+=( "--exclude" "$directory" )
  done
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    CODECOV_ARGS+=( "--file" "$file" )
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    CODECOV_ARGS+=( "--flag" "$flag" )
  done
fi

CODECOV_ARGS+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
CODECOV_ARGS+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
CODECOV_ARGS+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
CODECOV_ARGS+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
CODECOV_ARGS+=( $(write_bool_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_RECURSE_SUBMODULES) )
CODECOV_ARGS+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
CODECOV_ARGS+=( $(write_bool_args CODECOV_LEGACY) )
if [ -n "$CODECOV_NAME" ];
then
  CODECOV_ARGS+=( "--name" "$CODECOV_NAME" )
fi
CODECOV_ARGS+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
CODECOV_ARGS+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
CODECOV_ARGS+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    CODECOV_ARGS+=( "--plugin" "$plugin" )
  done
fi

CODECOV_ARGS+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
CODECOV_ARGS+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))

IFS=$OLDIFS
elif [ "$CODECOV_RUN_CMD" == "empty-upload" ]; then

CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_FORCE) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
elif [ "$CODECOV_RUN_CMD" == "pr-base-picking" ]; then

CODECOV_ARGS+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
CODECOV_ARGS+=( $(k_arg SERVICE) $(v_arg SERVICE))
elif [ "$CODECOV_RUN_CMD" == "send-notifications" ]; then

CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_CMD"
  exit
fi

unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475

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

say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$CODECOV_COMMAND $(echo "${CODECOV_CLI_ARGS[@]}") $CODECOV_RUN_CMD$token_str $(echo "${CODECOV_ARGS[@]}")$x"
if ! $CODECOV_COMMAND \
  ${CODECOV_CLI_ARGS[*]} \
  ${CODECOV_RUN_CMD} \
  ${token_arg[*]} \
  "${CODECOV_ARGS[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
rm ./codecov_envs
