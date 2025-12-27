FROM eclipse-temurin:17-jre

RUN adduser --disabled-password --quiet --system --home /opt/openfire --gecos "Openfire XMPP server" --group openfire

ADD ["openfire.tar.gz", "entrypoint.sh","setup.sh", "/opt/"]

ADD ["https://www.igniterealtime.org/projects/openfire/plugins/1.12.0/restAPI.jar", "/tmp/plugins/restAPI.jar"]

RUN chown -R openfire:openfire /opt/openfire && \
    chown -R openfire:openfire /tmp/plugins && \
    chmod +x /opt/openfire/bin/openfire.sh

USER openfire

WORKDIR /opt/openfire

EXPOSE 5222 9090

CMD ["/opt/entrypoint.sh"]
