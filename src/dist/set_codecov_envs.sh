#!/usr/bin/env bash

touch ./codecov_envs
chmod u+x ./codecov_envs
echo "#!/usr/bin/env bash" > ./codecov_envs

export CODECOV_CLEANUP=
export CODECOV_CLI_TYPE=
export CODECOV_COMMAND=
export CODECOV_DOWNLOAD_DIR=
export CODECOV_FAIL_ON_ERROR=
export CODECOV_FILENAME=
export CODECOV_OS=
export CODECOV_RUN_CMD=
export CODECOV_URL=
export CODECOV_VERSION=
export CODECOV_WRAPPER_VERSION=

env | grep -i "CODECOV_" | grep -iv "CODECOV_TOKEN" | sed -e 's/^/export /' > ./codecov_envs
cat ./codecov_envs
