#!/usr/bin/env bash

source ./codecov_envs
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
env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
