FROM mambaorg/micromamba

RUN micromamba install -y -n base -c pytorch -c nvidia -c main \
    cudatoolkit=11.1 numpy pytorch torchvision &&\
    micromamba clean -y --all

RUN micromamba install -y -n base -c main \
    git matplotlib tensorboard tqdm &&\
    micromamba clean -y --all

RUN micromamba install -y -n base -c conda-forge \
    autopep8 clang-format pre-commit &&\
    micromamba clean -y --all

RUN micromamba shell init -s bash -p $MAMBA_ROOT_PREFIX &&\
    echo "micromamba activate $ENV_NAME" >> ~/.bashrc

ENTRYPOINT ["bash"]
WORKDIR /home/micromamba