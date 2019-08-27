ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

COPY GeoIP.conf /usr/local/etc/

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev openssl tar curl go git musl-dev \
  && apk add --no-cache python2-dev py-pip \
  && go get -u github.com/quantumew/mustache-cli \
  && go get -u github.com/maxmind/geoipupdate2/cmd/geoipupdate \
  && cp $GOPATH/bin/* /usr/local/bin/ \
  && mkdir /usr/local/share/GeoIP \
  && ./usr/local/bin/geoipupdate \
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
RUN apk add --no-cache geoip

EXPOSE 80

#ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
