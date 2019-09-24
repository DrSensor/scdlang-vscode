FROM busybox:musl as bat

ADD https://glare.now.sh/sharkdp/bat/bat-v[0-9.]+-x86_64-.*-musl.tar.gz /tmp/
RUN for file in /tmp/*.tar.gz; do tar xvf "$file"; done && \
	mv bat-*-linux*/bat /bin/ && rm -r bat-*-linux* /tmp/*


FROM gcr.io/distroless/static
COPY --from=bat /bin/bat /bin/