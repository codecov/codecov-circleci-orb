unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
source $BASH_ENV
chmod +x $filename
[ -n "<< parameters.file >>" ] && \
  set - "${@}" "-f" "<< parameters.file >>"
[ -n "<< parameters.xtra_args >>" ] && \
  set - "${@}" "<< parameters.xtra_args >>"
./$filename \
  -Q "codecov-circleci-orb-3.2.3" \
  -t "${<< parameters.token >>}" \
  -n "<< parameters.upload_name >>" \
  -F "<< parameters.flags >>" \
  ${@}
