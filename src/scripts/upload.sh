unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
set -x

chmod +x $codecov_filename
echo ${CIRCLE_BUILD_NUM}
[ -n "${PARAM_FILE}" ] && \
  set - "${@}" "-f" "${PARAM_FILE}"
[ -n "${PARAM_UPLOAD_ARGS}" ] && \
  set - "${@}" "${PARAM_UPLOAD_ARGS}"
[ -n "${PARAM_UPLOAD_NAME}" ] && \
  PARAM_UPLOAD_NAME="${CIRCLE_BUILD_NUM}"

FLAGS=""
OLDIFS=$IFS;IFS=,
for flag in $PARAM_FLAGS; do
  eval e="\$$flag"
  for param in "${e}" "${flag}"; do
    if [ -n "${param}" ]; then
      if [ -n "${FLAGS}" ]; then
        FLAGS="${FLAGS},${param}"
      else
        FLAGS="${param}"
      fi
      break
    fi
  done
done
IFS=$OLDIFS

#create commit
./"$codecov_filename" \
  ${PARAM_CLI_ARGS} \
  create-commit \
  -t "$(eval echo \$$PARAM_TOKEN)"

#create report
./"$codecov_filename" \
  ${PARAM_CLI_ARGS} \
  create-report \
  -t "$(eval echo \$$PARAM_TOKEN)"

#upload reports
# alpine doesn't allow for indirect expansion
./"$codecov_filename" \
  ${PARAM_CLI_ARGS} \
  do-upload \
  -t "$(eval echo \$$PARAM_TOKEN)" \
  -n "${PARAM_UPLOAD_NAME}" \
  -F "${FLAGS}" \
  ${PARAM_UPLOAD_ARGS} \
  ${@}
