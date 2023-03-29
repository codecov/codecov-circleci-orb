unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $codecov_filename
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_XTRA_ARGS}" ] && \
  set - "${@}" "${PARAM_XTRA_ARGS}"
[ -n "${PARAM_FLAGS}" ] && \
  set - "${@}" "-F" "${PARAM_FLAGS}"
# alpine doesn't allow for indirect expansion
#create commit
./"$filename" \
  create-commit \
  -t "$(eval echo \$$PARAM_TOKEN)" \

#create report
./"$filename" \
  create-report \
  -t "$(eval echo \$$PARAM_TOKEN)" \

#upload reports
./"$filename" \
  do-upload \
  -t "$(eval echo \$$PARAM_TOKEN)" \
  -n "${PARAM_UPLOAD_NAME}" \
  ${@}
