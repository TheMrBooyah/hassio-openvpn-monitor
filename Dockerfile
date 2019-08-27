ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev musl-dev openssl tar python2-dev py-pip curl \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn


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

# Create admin account
RUN useradd -ms /bin/bash admin
RUN chown -R admin:admin /openvpn-monitor
RUN chmod 755 /openvpn-monitor
RUN chmod 755 +x entrypoint.sh
USER admin

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
