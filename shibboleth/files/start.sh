#!/bin/bash

# LDAP configuration
echo "Waiting for LDAP server"
/wait-for-it.sh openldap:636 --strict

echo "LDAP server is ready"

echo -n | openssl s_client -connect openldap:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /opt/shibboleth-idp/credentials/ldap-server.crt
LDAPHOST=`echo -n | openssl s_client -connect openldap:636 | grep CN= | head -1 | sed -e 's/.*CN=\(.*\)/\1/'`
sed -i -e "s/#LDAPHOST#/$LDAPHOST/g" /opt/shibboleth-idp/conf/ldap.properties

httpd
shibd -f
$JETTY_HOME/bin/jetty.sh start
tail -f /opt/shibboleth-idp/logs/idp-process.log
