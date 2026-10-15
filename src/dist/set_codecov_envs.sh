#!/usr/bin/env bash

touch ./codecov_envs
chmod u+x ./codecov_envs
echo "#!/usr/bin/env bash" > ./codecov_envs

export CODECOV_CLEANUP="${CODECOV_CLEANUP-}"
export CODECOV_CLI_TYPE="${CODECOV_CLI_TYPE-}"
export CODECOV_COMMAND="${CODECOV_COMMAND-}"
export CODECOV_DOWNLOAD_DIR="${CODECOV_DOWNLOAD_DIR-}"
export CODECOV_FAIL_ON_ERROR="${CODECOV_FAIL_ON_ERROR-}"
export CODECOV_FILENAME="${CODECOV_FILENAME-}"
export CODECOV_OS="${CODECOV_OS-}"
export CODECOV_RUN_CMD="${CODECOV_RUN_CMD-}"
export CODECOV_URL="${CODECOV_URL-}"
export CODECOV_VERSION="${CODECOV_VERSION-}"
export CODECOV_WRAPPER_VERSION="${CODECOV_WRAPPER_VERSION-}"

# CircleCI renders boolean parameters as 1/0; the wrapper compares against true.
if [ "$CODECOV_FAIL_ON_ERROR" = "1" ]; then
  export CODECOV_FAIL_ON_ERROR=true
fi

env | grep -i "CODECOV_" | grep -iv "CODECOV_TOKEN" | sed -e 's/^/export /' > ./codecov_envs
cat ./codecov_envs
touch ./codecov_step_ok
