FROM opensuse:tumbleweed

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install java-1_8_0-openjdk-devel curl wget tar
ENV JAVA_HOME=/usr/lib64/jvm/java-1.8.0-openjdk
RUN curl https://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-3.4.1.tar.gz \
         --output shibboleth-identity-provider-3.4.1.tar.gz
RUN curl https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.10.v20180503/jetty-distribution-9.4.10.v20180503.tar.gz \
        --output jetty-distribution-9.4.10.v20180503.tar.gz

RUN tar zxvf shibboleth-identity-provider-3.4.1.tar.gz
RUN sed -i -e 's!idp.entityID = https://idp.example.org!idp.entityID = https://cephdashboard/idp!g' /shibboleth-identity-provider-3.4.1/conf/idp.properties
RUN sed -i -e 's!idp.scope = example.org!idp.scope = ceph-dev-docker.org!g' /shibboleth-identity-provider-3.4.1/conf/idp.properties
RUN cd shibboleth-identity-provider-3.4.1 && \
    ./bin/install.sh -Didp.target.dir=/opt/shibboleth-idp -Didp.host.name=localhost \
                     -Didp.src.dir=/shibboleth-identity-provider-3.4.1 -Didp.noprompt=true \
                     -Didp.merge.properties=conf/idp.properties -Didp.scope=ceph-dev-docker.org \
                     -Didp.keystore.password=password -Didp.sealer.password=password

RUN tar zxvf jetty-distribution-9.4.10.v20180503.tar.gz
ENV JETTY_HOME=/jetty-distribution-9.4.10.v20180503
RUN keytool -noprompt -genkey -keystore "$JETTY_HOME/etc/rc.keystore" \
    -alias cephkeystore -keyalg RSA -keypass helloworld -storepass helloworld \
    -dname "CN=shibboleth.ceph.com, OU=ID, O=ceph, L=Hello, S=Hello, C=GB" \
    -storetype pkcs12
ADD files/jetty-ssl-context.xml $JETTY_HOME/etc/
RUN sed -i -e 's/8080/9080/g' $JETTY_HOME/etc/jetty-http.xml
RUN sed -i -e 's/8443/9443/g' $JETTY_HOME/etc/jetty.xml
RUN sed -i -e 's/8443/9443/g' $JETTY_HOME/etc/jetty-ssl.xml
RUN sed -i -e 's/--module=http/--module=https/g' $JETTY_HOME/start.ini

RUN zypper -n install which psmisc

RUN cp /opt/shibboleth-idp/war/idp.war $JETTY_HOME/webapps/

RUN zypper -n install apache2 shibboleth-sp
RUN sed -i -e 's/Listen 80/Listen 9080/g' /etc/apache2/listen.conf
ADD files/shibboleth2.xml /etc/shibboleth/
RUN shibd && httpd && cd /opt/shibboleth-idp && \
    curl http://localhost:9080/Shibboleth.sso/Metadata --output metadata/sp-metadata.xml && \
    cp metadata/sp-metadata.xml metadata/cephdashboard-metadata.xml && \
    killall httpd && killall shibd

RUN sed -i -e 's!localhost:8443!localhost:9443!g' /opt/shibboleth-idp/metadata/idp-metadata.xml
RUN sed -i -e 's!localhost/!localhost:9443/!g' /opt/shibboleth-idp/metadata/idp-metadata.xml
RUN sed -i -e 's/#idp.encryption.optional = false/idp.encryption.optional = true/g' /opt/shibboleth-idp/conf/idp.properties
ADD files/metadata-providers.xml /opt/shibboleth-idp/conf/

RUN sed -i -e 's!<PolicyRequirementRule xsi:type="Requester" value="https://sp.example.org" />!<PolicyRequirementRule xsi:type="Requester" value="https://cephdashboard.local/auth/saml2/metadata" />!g' /opt/shibboleth-idp/conf/attribute-filter.xml
RUN sed -i -e 's/name="urn:oid:0.9.2342.19200300.100.1.1"/name="uid"/g' /opt/shibboleth-idp/conf/attribute-resolver.xml

ADD files/ldap.properties /opt/shibboleth-idp/conf/
ADD files/start.sh /
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /
RUN chmod +x /wait-for-it.sh

ENTRYPOINT [ "/start.sh" ]

