source $BASH_ENV

if [ -f ${codecov_filename} ]; then
  echo "${codecov_filename} already exists"
  exit 0
fi

[[ $codecov_os == "macos" ]] && \
  HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
codecov_url="https://uploader.codecov.io"
codecov_url="$codecov_url/${codecov_version}"
codecov_url="$codecov_url/${codecov_os}/${codecov_filename}"
echo "Downloading ${codecov_url}"
curl -Os $codecov_url -v
