#!/usr/bin/env bash
source ./codecov_envs

set +u
say() {
  echo -e "$1"
}

exit_if_error() {
  say "$r==> $1$x"
  if [ "$CODECOV_FAIL_ON_ERROR" = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
  fi
}

lower() {
  echo $(echo $1 | sed 's/CODECOV//' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]')
}

k_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "--$(lower "$1")"
  fi
}

v_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "$(eval echo \$"CODECOV_$1")"
  fi
}

write_bool_args() {
  if [ "$(eval echo \$$1)" = "true" ] || [ "$(eval echo \$$1)" = "1" ];
  then
    echo "-$(lower $1)"
  fi
}

b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
x="\033[0m"
retry="--retry 5 --retry-delay 2"

if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ "$CODECOV_SKIP_VALIDATION" == "1" ] || [ -n "$CODECOV_BINARY" ] || [ "$CODECOV_USE_PYPI" == "true" ] || [ "$CODECOV_USE_PYPI" == "1" ];
then
  say "$r==>$x Bypassing validation..."
  if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ "$CODECOV_SKIP_VALIDATION" == "1" ];
  then
    chmod +x "$CODECOV_COMMAND"
  fi
else
  gpg_key_url="https://keybase.io/codecovsecops/pgp_keys.asc"
  gpg_import_ok=false
  for gpg_attempt in 1 2 3; do
    if curl -sf $retry "$gpg_key_url" | gpg --no-default-keyring --import; then
      gpg_import_ok=true
      break
    fi
    if [ "$gpg_attempt" -lt 3 ]; then
      say "$r ->$x GPG key import attempt $gpg_attempt failed, retrying..."
      sleep 2
    fi
  done
  if [ "$gpg_import_ok" != "true" ]; then
    exit_if_error "Could not import GPG verification key after 3 attempts. Please contact Codecov if problem continues"
  fi

  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${CODECOV_VERSION}/${CODECOV_OS}"
  sha_url="${sha_url}/${CODECOV_FILENAME}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "

  curl -o "$CODECOV_DOWNLOAD_DIR/${CODECOV_FILENAME}.SHA256SUM" -s $retry --connect-timeout 2 "$sha_url"
  curl -o "$CODECOV_DOWNLOAD_DIR/${CODECOV_FILENAME}.SHA256SUM.sig" -s $retry --connect-timeout 2 "${sha_url}.sig"

  if ! gpg --verify "$CODECOV_DOWNLOAD_DIR/${CODECOV_FILENAME}.SHA256SUM.sig" "$CODECOV_DOWNLOAD_DIR/${CODECOV_FILENAME}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi

  if ! (cd "$CODECOV_DOWNLOAD_DIR" && (shasum -a 256 -c "${CODECOV_FILENAME}.SHA256SUM" 2>/dev/null || \
    sha256sum -c "${CODECOV_FILENAME}.SHA256SUM"));
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
  chmod +x "$CODECOV_COMMAND"
fi

if [ -n "$CODECOV_BINARY_LOCATION" ];
then
  mkdir -p "$CODECOV_BINARY_LOCATION" && mv "$CODECOV_COMMAND" "$CODECOV_BINARY_LOCATION/$CODECOV_FILENAME"
  CODECOV_COMMAND="$CODECOV_BINARY_LOCATION/$CODECOV_FILENAME"
  say "$g==>$x ${CODECOV_CLI_TYPE} binary moved to ${CODECOV_BINARY_LOCATION}"
fi

if [ "$CODECOV_DOWNLOAD_ONLY" = "true" ];
then
  if [ "$CODECOV_CLEANUP" == "true" ] && [ -z "$CODECOV_BINARY_LOCATION" ]; then
    cp "$CODECOV_COMMAND" "./$CODECOV_FILENAME"
    CODECOV_COMMAND="./$CODECOV_FILENAME"
  fi
  say "$g==>$x ${CODECOV_CLI_TYPE} download only called. Exiting..."
  exit
fi
env | grep -io "CODECOV_.*=" | tr "=" " " | while read -r val; do echo "export $val=$(eval echo \"\$$val\")"; done > ./codecov_envs
