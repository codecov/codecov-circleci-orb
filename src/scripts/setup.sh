set -e
set -x

family=$(uname -s | tr '[:upper:]' '[:lower:]')
codecov_os="windows"
[[ $family == "darwin" ]] && codecov_os="macos"

[[ $family == "linux" ]] && codecov_os="linux"
[[ $codecov_os == "linux" ]] && \
  osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
[[ $osID == "alpine" ]] && codecov_os="alpine"
echo "Detected ${codecov_os}"
echo "export codecov_os=${codecov_os}" >> $BASH_ENV

if [ ${PARAM_VERSION} = "latest" ]
then
  version="$(curl https://uploader.codecov.io/${codecov_os}/latest | grep 'uploader.codecov.io/v' | head -1 | sed -e 's/^.*uploader.codecov.io\///g' | sed -e 's/\/.*$//g')"
else
  version="${PARAM_VERSION}"
fi
echo "Using version ${version}"
echo "export codecov_version=${version}" >> $BASH_ENV

codecov_filename="codecov"
[[ $codecov_os == "windows" ]] && codecov_filename+=".exe"
echo "export codecov_filename=${codecov_filename}" >> $BASH_ENV
