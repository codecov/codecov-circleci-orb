family=$(uname -s | tr '[:upper:]' '[:lower:]')
os="windows"
[[ $family == "darwin" ]] && os="macos"

[[ $family == "linux" ]] && os="linux"
[[ $os == "linux" ]] && \
  osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
[[ $osID == "alpine" ]] && os="alpine"
echo "Detected ${os}"
echo "export os=${os}" >> $BASH_ENV
echo "export version=${PARAM_VERSION}" >> $BASH_ENV

filename="codecov"
[[ $os == "windows" ]] && filename+=".exe"
echo "export filename=${filename}" >> $BASH_ENV
[[ $os == "macos" ]] && \
  HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
codecov_url="https://uploader.codecov.io"
codecov_url="$codecov_url/${PARAM_VERSION}"
codecov_url="$codecov_url/${os}/${filename}"
echo "Downloading ${codecov_url}"
curl -Os $codecov_url -v
