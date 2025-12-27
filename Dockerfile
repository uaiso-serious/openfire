FROM eclipse-temurin:17-jre

RUN adduser --disabled-password --quiet --system --home /opt/openfire --gecos "Openfire XMPP server" --group openfire

ADD ["openfire.tar.gz", "/opt/"]

ADD ["https://github.com/igniterealtime/openfire-restAPI-plugin/releases/download/v1.12.0/restAPI.jar", "https://github.com/igniterealtime/openfire-subscription-plugin/releases/download/v1.4.3/subscription.jar", "https://github.com/igniterealtime/openfire-xmppweb-plugin/releases/download/v0.10.6.1/xmppweb.jar", "/tmp/plugins/"]

RUN mkdir /data && \
    chown -R openfire:openfire /opt/openfire && \
    chown -R openfire:openfire /tmp/plugins && \
    chown -R openfire:openfire /data && \
    chmod +x /opt/openfire/bin/openfire.sh

ADD ["entrypoint.sh", "setup.sh", "setup-restapi.sh", "readiness.sh", "/opt/"]

USER openfire

WORKDIR /opt/openfire

EXPOSE 5222 9090

CMD ["/opt/entrypoint.sh"]
