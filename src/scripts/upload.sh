unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $codecov_filename
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_XTRA_ARGS}" ] && \
  set - "${@}" "${PARAM_XTRA_ARGS}"
[ -n "${PARAM_UPLOAD_NAME}" ] && \
  PARAM_UPLOAD_NAME="${CIRCLE_BUILD_NUM}"

FLAGS=()
IFS=',' read -ra FLAG_ARRAY <<< "$PARAM_FLAGS"
for flag in "${FLAG_ARRAY[@]}"; do
  eval e="\$$flag"
  for param in "${e}" "${flag}"; do
    if [ -n "${param}" ]; then
      FLAGS+=("${param}")
      break
    fi
  done
done

FINAL_FLAGS=$(IFS=',' ; echo "${FLAGS[*]}")

# alpine doesn't allow for indirect expansion
./"$codecov_filename" \
  -Q "codecov-circleci-orb-3.2.5" \
  -t "$(eval echo \$$PARAM_TOKEN)" \
  -n "${PARAM_UPLOAD_NAME}" \
  -F "${FINAL_FLAGS}" \
  ${@}
