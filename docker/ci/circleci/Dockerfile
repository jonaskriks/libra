#while using circle we'll use circle's base image.
FROM cimg/base:2020.12@sha256:a9adc0fb9b3d2440961a8042c5b03a387b3a0d6e2ab9e73ce20bff1ae84d64be  AS setup_ci

WORKDIR /libra
COPY rust-toolchain /libra/rust-toolchain
COPY cargo-toolchain /libra/cargo-toolchain
COPY scripts/dev_setup.sh /libra/scripts/dev_setup.sh

#Batch mode and all operations tooling
RUN scripts/dev_setup.sh -t -o -b -p -y
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
USER circleci
ENV PATH "/home/circleci/.cargo/bin:$PATH"

FROM setup_ci as tested_ci

#Compile a small rust tool?  But we already have in dev_setup (sccache/grcov)...?
#Test that all commands we need are installed and on the PATH
RUN [ -x "$(command -v shellcheck)" ] \
    && [ -x "$(command -v hadolint)" ] \
    && [ -x "$(command -v vault)" ] \
    && [ -x "$(command -v terraform)" ] \
    && [ -x "$(command -v kubectl)" ] \
    && [ -x "$(command -v rustup)" ] \
    && [ -x "$(command -v cargo)" ] \
    && [ -x "$(command -v sccache)" ] \
    && [ -x "$(command -v grcov)" ] \
    && [ -x "$(command -v helm)" ] \
    && [ -x "$(command -v aws)" ] \
    && [ -x "$(command -v z3)" ] \
    && [ -x "$(command -v "$HOME/.dotnet/tools/boogie")" ] \
    && [ -x "$(xargs rustup which cargo --toolchain < /libra/rust-toolchain )" ] \
    && [ -x "$(xargs rustup which cargo --toolchain < /libra/cargo-toolchain)" ]

#should be a no-op
# sccache builds fine, but is not executable ??? in alpine, ends up being recompiled.  Wierd.
RUN scripts/dev_setup.sh -b -p

FROM setup_ci as build_environment
