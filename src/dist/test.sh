#!/usr/bin/env bash

cat ./codecov_envs
source ./codecov_envs
env | grep "CODECOV_"
echo $CODECOV_VERSION
