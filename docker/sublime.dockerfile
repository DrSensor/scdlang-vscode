FROM ruby

ADD https://github.com/aziz/SublimeSyntaxConvertor/archive/master.tar.gz /tmp/
RUN tar xzfv /tmp/master.tar.gz -C opt --strip=1 SublimeSyntaxConvertor-master && \
	cd opt && bundle install --system --no-cache --clean && \
	rm -r /tmp/*

ENV PATH="${PATH}:/opt/bin"