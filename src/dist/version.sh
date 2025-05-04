#!/usr/bin/env bash
source ./codecov_envs
CODECOV_WRAPPER_VERSION="0.2.2"

codecov_envs=""
env | grep "CODECOV_" > ./codecov_envs
