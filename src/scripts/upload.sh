unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $filename
echo "${PARAM_TOKEN}"
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_XTRA_ARGS}" ] && \
  set - "${@}" "${PARAM_XTRA_ARGS}"
./"$filename" \
  -Q "codecov-circleci-orb-3.2.3" \
  -t "${PARAM_TOKEN}" \
  -n "${PARAM_UPLOAD_NAME}" \
  -F "${PARAM_FLAGS}" \
  ${@}
