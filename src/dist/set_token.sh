#!/usr/bin/env bash

source ./codecov_envs
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
env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
