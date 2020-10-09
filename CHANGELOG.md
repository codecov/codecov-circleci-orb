## 1.1.2
**Features**
None

**Fixes**
- [#52](https://github.com/codecov/codecov-circleci-orb/pull/52) Show error message when curl fails.

## 1.1.1
**Features**
None

**Fixes**
- [#44](https://github.com/codecov/codecov-circleci-orb/pull/44) Security fixes on `lodash`

## 1.1.0
**Features**
- [#38](https://github.com/codecov/codecov-circleci-orb/pull/38) Automated orb publishing

**Fixes**
- [#30](https://github.com/codecov/codecov-circleci-orb/pull/30) Update homepage URL
- [#36](https://github.com/codecov/codecov-circleci-orb/pull/36) Run tests against development orb
- [#37](https://github.com/codecov/codecov-circleci-orb/pull/37) Publish orb based on semver commit

## 1.0.6
**Features**
None

**Fixes**
- (https://github.com/codecov/codecov-circleci-orb/commit/e579d6ce54eae6910dd72aaada1ff9082b5b152d) Add link to `GitHub` repository
- (https://github.com/codecov/codecov-circleci-orb/commit/026635e8b82417d623fb63c6f0efe18d6a5daf32) Allow for custom `Codecov` URL as a parameter (for Enterprise users)
- (https://github.com/codecov/codecov-circleci-orb/commit/d7fcbfd1df6bb3e370fd5ce2c3a5337a81002db6) Update token type to `env_var_name`

## 1.0.5
**Features**
None

**Fixes**
- (https://github.com/codecov/codecov-circleci-orb/pull/10/commits/c9aeab8802fc1dc2065c231e128339d94c559c47) Do not fail if no `flags` are provided
- (https://github.com/codecov/codecov-circleci-orb/commit/65091155fee5cc0773ecb53963031d74b243c696) Add a `when` parameter to denote when this should be run
- (https://github.com/codecov/codecov-circleci-orb/commit/f0fe5d9bf0d4ac7d2fd195c3feaa684925ba0be1) Place nicely with Alpine images
- (https://github.com/codecov/codecov-circleci-orb/commit/f0fe5d9bf0d4ac7d2fd195c3feaa684925ba0be1) Do not fail if no `token` is provided

## 1.0.4
**Features**
None

**Fixes**
- (https://github.com/codecov/codecov-circleci-orb/commit/c9aeab8802fc1dc2065c231e128339d94c559c47) Only send the `-F` argument if `flags` are present

## 1.0.3
**Features**
- (https://github.com/codecov/codecov-circleci-orb/commit/141f2e6feb423c62b970a4d2fe11ebf966fff195) `File` parameter is now optional and behaves in line with the bash uploader

**Fixes**
None

## 1.0.2
**Features**
None

**Fixes**
- (https://github.com/codecov/codecov-circleci-orb/commit/37eb2601c601a55caa3cb24dcb3b05a3a919d0ee) `Flags` flag is not getting properly parsed due to potentially taking in an empty string.  Moving it to the bottom of the bash command to prevent improper argument parsing

## 1.0.1
This release marks the beginning of the Codecov CircleCI Orb.

The orb currently supports 5 parameters:
1. `file` (Required): The filename of the report to upload
1. `conf`: The filename of the configuration yaml to read (defaults to `.codecov.yml`)
1. `flags`: A comma separated list of flags ([Read more about flags](https://docs.codecov.io/docs/flags))
1. `token`: Codecov private token (defaults to environment variable `$CODECOV_TOKEN`)
1. `upload_name`: Custom defined name of the upload (defaults to `$CIRCLE_BUILD_NUM`)

[Find more documentation on the orb](https://circleci.com/orbs/registry/orb/codecov/codecov)
[Read more about CircleCI Orbs](https://circleci.com/docs/2.0/orb-intro/)
