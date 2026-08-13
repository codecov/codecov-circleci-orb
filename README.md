# codecov-circleci-orb

[![codecov.io](https://codecov.io/github/codecov/codecov-circleci-orb/coverage.svg?branch=main)](https://codecov.io/github/codecov/codecov-circleci-orb)
[![Circle CI](https://circleci.com/gh/codecov/codecov-circleci-orb.png?style=badge)](https://circleci.com/gh/codecov/codecov-circleci-orb)

CircleCI orb for uploading coverage reports to [Codecov](https://codecov.io).

This orb embeds the [Codecov Wrapper](https://github.com/codecov/wrapper) (`0.3.0`).

## Parameters

See [`src/commands/upload.yml`](./src/commands/upload.yml) for the full parameter list. Notable options:

- `cleanup` — when `true`, download the CLI into a temporary directory and remove it after the run (off by default)
