#!/usr/bin/env bash

source ./codecov_envs
if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ -n "$CODECOV_BINARY" ] || [ "$CODECOV_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
else
  . ./set_validation_key.sh
  echo "${CODECOV_PUBLIC_PGP_KEY}"  | \
    gpg --no-default-keyring --import
  # One-time step
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${CODECOV_VERSION}/${CODECOV_OS}"
  sha_url="${sha_url}/${codecov_filename}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "

  curl -Os $retry --connect-timeout 2 "$sha_url"
  curl -Os $retry --connect-timeout 2 "${sha_url}.sig"

  if ! gpg --verify "${codecov_filename}.SHA256SUM.sig" "${codecov_filename}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi

  if ! (shasum -a 256 -c "${codecov_filename}.SHA256SUM" 2>/dev/null || \
    sha256sum -c "${codecov_filename}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
  chmod +x "$codecov_command"
fi

if [ -n "$CODECOV_BINARY_LOCATION" ];
then
  mkdir -p "$CODECOV_BINARY_LOCATION" && mv "$codecov_filename" $_
  say "$g==>$x Codecov binary moved to ${CODECOV_BINARY_LOCATION}"
fi

if [ "$CODECOV_DOWNLOAD_ONLY" = "true" ];
then
  say "$g==>$x Codecov download only called. Exiting..."
fi
env | grep -i "CODECOV_" | sed -e 's/^/export /' > tee ./codecov_envs
