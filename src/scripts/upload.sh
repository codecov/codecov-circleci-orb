unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $filename
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_XTRA_ARGS}" ] && \
  set - "${@}" "${PARAM_XTRA_ARGS}"
# alpine doesn't allow for indirect expansion
./"$filename" \
  -Q "codecov-circleci-orb-3.2.5" \
  -t "$(eval echo \$$PARAM_TOKEN)" \
  -n "$(eval echo \$$PARAM_UPLOAD_NAME)" \
  -F "${PARAM_FLAGS}" "$(eval echo \$$PARAM_FLAGS_BY_ENV)" \
  ${@}
