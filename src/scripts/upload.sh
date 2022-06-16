unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $filename
[[ $os == "alpine" ]] && token=${eval echo \$$PARAM_TOKEN}
[[ $os != "alpine" ]] && token="${!PARAM_TOKEN}"
echo $token
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_XTRA_ARGS}" ] && \
  set - "${@}" "${PARAM_XTRA_ARGS}"
./"$filename" \
  -Q "codecov-circleci-orb-3.2.3" \
  -t "${token}" \
  -n "${PARAM_UPLOAD_NAME}" \
  -F "${PARAM_FLAGS}" \
  ${@}
