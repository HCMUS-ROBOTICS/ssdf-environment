ARG SSDF_BASE_IMAGE
FROM $SSDF_BASE_IMAGE

RUN python3 -m pip install --no-cache-dir --upgrade \
    # Executable for VSCode
    autopep8 cmake-format flake8 \
    flake8-bugbear flake8-builtins flake8-comprehensions flake8-isort pep8-naming \
    # Executable for pre-commit run
    pre-commit clang-format cpplint

