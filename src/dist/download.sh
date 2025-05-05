#!/usr/bin/env bash

source ./codecov_envs
if [ -n "$CODECOV_BINARY" ];
then
  if [ -f "$CODECOV_BINARY" ];
  then
    codecov_filename=$CODECOV_BINARY
    codecov_command=$CODECOV_BINARY
  else
    exit_if_error "Could not find binary file $CODECOV_BINARY"
  fi
elif [ "$CODECOV_USE_PYPI" == "true" ];
then
  if ! pip install codecov-cli"$([ "$CODECOV_VERSION" == "latest" ] && echo "" || echo "==$CODECOV_VERSION" )"; then
    exit_if_error "Could not install via pypi."
    exit
  fi
  codecov_command="codecovcli"
else
  if [ -n "$CODECOV_OS" ];
  then
    say "$g==>$x Overridden OS: $b${CODECOV_OS}$x"
  else
    CODECOV_OS="windows"
    family=$(uname -s | tr '[:upper:]' '[:lower:]')
    [[ $family == "darwin" ]] && CODECOV_OS="macos"
    [[ $family == "linux" ]] && CODECOV_OS="linux"
    [[ $CODECOV_OS == "linux" ]] && \
      osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
    [[ $osID == "alpine" ]] && CODECOV_OS="alpine"
    [[ $(arch) == "aarch64" && $family == "linux" ]] && CODECOV_OS+="-arm64"
    say "$g==>$x Detected $b${CODECOV_OS}$x"
  fi

  codecov_filename="codecov"
  [[ $CODECOV_OS == "windows" ]] && codecov_filename+=".exe"
  codecov_command="./$codecov_filename"
  [[ $CODECOV_OS == "macos" ]]  && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  codecov_url="${CODECOV_CLI_URL:-https://cli.codecov.io}"
  codecov_url="$codecov_url/${CODECOV_VERSION}"
  codecov_url="$codecov_url/${CODECOV_OS}/${codecov_filename}"
  say "$g ->$x Downloading $b${codecov_url}$x"
  curl -O $retry "$codecov_url"
  say "$g==>$x Finishing downloading $b${CODECOV_OS}:${CODECOV_VERSION}$x"

  v_url="https://cli.codecov.io/api/${CODECOV_OS}/${CODECOV_VERSION}"
  v=$(curl $retry --retry-all-errors -s "$v_url" -H "Accept:application/json" | tr \{ '\n' | tr , '\n' | tr \} '\n' | grep "\"version\"" | awk  -F'"' '{print $4}' | tail -1)
  say "      Version: $b$v$x"
  say " "
fi
env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
