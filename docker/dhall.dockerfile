FROM bash

ADD \
    https://glare.now.sh/dhall-lang/dhall-haskell/dhall-[0-9.]+-x86_64-linux.tar.bz2        \
    https://glare.now.sh/dhall-lang/dhall-haskell/dhall-json-[0-9.]+-x86_64-linux.tar.bz2   \
    https://glare.now.sh/dhall-lang/dhall-haskell/dhall-bash-[0-9.]+-x86_64-linux.tar.bz2   \
    /tmp/

RUN for file in /tmp/*; do  \
        tar xvf "$file";    \
    done && rm -r /tmp/*