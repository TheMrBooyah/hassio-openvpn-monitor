ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers python2-dev py-pip geoip-dev openssl tar curl go git musl-dev \
  && go get -u github.com/quantumew/mustache-cli \
  && cp $GOPATH/bin/* /usr/local/bin/ \
  && rm -rf $GOPATH 

# Copy app
RUN mkdir /openvpn-monitor 
COPY . /openvpn-monitor

# Prepare config
COPY server.mustache /templates/

WORKDIR /openvpn-monitor

# Prepare environment
RUN pip install openvpn-monitor gunicorn
RUN apk del .build-dependencies
RUN apk add --no-cache geoip python2

EXPOSE 80

#ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
