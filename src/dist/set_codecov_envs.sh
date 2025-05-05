#!/usr/bin/env bash

touch ./codecov_envs
chmod u+x ./codecov_envs
"#!/usr/bin/env bash" > ./codecov_envs

export CODECOV_BINARY_LOCATION=
export CODECOV_CLI_URL=
export CODECOV_DOWNLOAD_ONLY=
export CODECOV_GCOV_ARGS=
export CODECOV_GCOV_EXECUTABLE=
export CODECOV_GCOV_IGNORE=
export CODECOV_GCOV_INCLUDE=
export CODECOV_PUBLIC_PGP_KEY=
export CODECOV_SWIFT_PROJECT=
export CODECOV_TOKEN=
export CODECOV_WRAPPER_VERSION=
export CODECOV_YML_PATH=

env | grep "CODECOV_" | tee ./codecov_envs
