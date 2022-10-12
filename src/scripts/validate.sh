source $BASH_ENV
cat pgp_keys.asc | \
  gpg --no-default-keyring --keyring trustedkeys.gpg --import
# One-time step
sha_url="https://uploader.codecov.io"
sha_url="$sha_url/${version}/${os}"
sha_url="$sha_url/${filename}.SHA256SUM"
echo "Downloading ${sha_url}"
curl -Os $sha_url
curl -Os $sha_url".sig"
gpgv $filename.SHA256SUM.sig $filename.SHA256SUM
shasum -a 256 -c $filename.SHA256SUM || \
  sha256sum -c $filename.SHA256SUM
