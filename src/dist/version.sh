#!/usr/bin/env bash
source ./codecov_envs
CODECOV_WRAPPER_VERSION="0.2.2"

env | grep "CODECOV_" | tee ./codecov_envs
cat ./codecov_envs
