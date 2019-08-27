ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev musl-dev openssl tar python2-dev py-pip curl go git \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn \
  && go get -u github.com/quantumew/mustache-cli \
  && cp $GOPATH/bin/* /usr/local/bin/ \
  && rm -rf $GOPATH 

# Copy app
RUN mkdir /openvpn-monitor 
COPY . /openvpn-monitor

# Prepare environment
RUN pip install /openvpn-monitor 
RUN apk del .build-dependencies
RUN apk add --no-cache geoip

# Prepare config
COPY confd /etc/confd
COPY entrypoint.sh /
COPY server.mustache /templates/

# Create admin account
RUN adduser -DH admin
RUN chown -R admin:admin /openvpn-monitor
RUN chmod 755 /openvpn-monitor
RUN chmod +x /entrypoint.sh
USER admin

WORKDIR /openvpn-monitor

EXPOSE 80

#ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
