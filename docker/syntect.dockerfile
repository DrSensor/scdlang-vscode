# TODO: add stage for building examples/syntect when https://github.com/rust-lang/docker-rust/issues/10 resolved
FROM busybox as sublimehq

ADD https://github.com/sublimehq/Packages/archive/master.tar.gz /tmp/
RUN tar xvzf /tmp/master.tar.gz && rm -r /tmp/*

FROM gcr.io/distroless/cc

COPY --from=sublimehq /Packages-master /Packages

# COPY --from=build target/release/examples/syntect /bin/
# ENTRYPOINT [ "syntect" ]
# CMD ["synpack", "Packages", "dist/newlines.packdump", "dist/nonewlines.packdump", "dist/metadata.packdump", "Rules"]
# CMD ["themepack" "Themes" "dist/default.themedump"]