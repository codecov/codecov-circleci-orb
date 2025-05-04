#!/usr/bin/env bash

source ./codecov_envs
env | grep "CODECOV_"
cat ./codecov_envs
echo $CODECOV_VERSION
