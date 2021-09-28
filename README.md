# SSDF Environment

This repository contains environment files for SSDF. The official supported code editor is [Visual Studio Code](https://code.visualstudio.com/).

## docker

Developing with Docker and VSCode

## dotfiles

### Prerequisites

- [pre-commit](https://pre-commit.com/#install)
- clang-format: included in VSCode environment, otherwise it could be installed by using pip, conda, etc

### Usage

1. Ensure `.pre-commit-config.yaml` existed in the repo
2. Run `pre-commit install --install-hooks` to install the hooks, pre-commit will be triggered on **staged files** before commit. It could run by using `pre-commit run` as well
3. Run `pre-commit run --all-files` to run the hooks against **all commited/staged** files.
