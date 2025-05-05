#!/usr/bin/env bash

source ./codecov_envs
codecov_args=()
if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then
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

unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475

say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$codecov_command $(echo "${codecov_cli_args[@]}") $CODECOV_RUN_CMD$token_str $(echo "${codecov_args[@]}")$x"
if ! $codecov_command \
  ${codecov_cli_args[*]} \
  ${CODECOV_RUN_CMD} \
  ${token_arg[*]} \
  "${codecov_args[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
