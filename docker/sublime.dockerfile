FROM ruby

WORKDIR /opt
RUN git clone https://github.com/MatthiasSaihttam/SublimeSyntaxConvertor . \
	&& bundle install --system --no-cache --clean