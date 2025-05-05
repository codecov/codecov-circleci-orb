#!/usr/bin/env bash

source ./codecov_envs
CODECOV_WRAPPER_VERSION="0.2.2"

env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
