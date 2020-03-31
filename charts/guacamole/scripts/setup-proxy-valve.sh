#!/bin/sh
set -e # Fail on error

if [ -n "$GUACAMOLE_INTERNAL_PROXIES" ]; then

  echo 'Setting up the proxy valve'

  GUACAMOLE_PROXY_IP_HEADER=${GUACAMOLE_PROXY_IP_HEADER:-X-FORWARDED-FOR}
  GUACAMOLE_PROXY_PROTOCOL_HEADER=${GUACAMOLE_PROXY_PROTOCOL_HEADER:-X-FORWARDED-PROTO}
  GUACAMOLE_PROXY_BY_HEADER=${GUACAMOLE_PROXY_BY_HEADER:-X-FORWARDED-BY}

  cat > /tmp/valve.xml <<EOF
        <Valve className="org.apache.catalina.valves.RemoteIpValve"
          internalProxies="$GUACAMOLE_INTERNAL_PROXIES"
          remoteIpHeader="$GUACAMOLE_PROXY_IP_HEADER"
          remoteIpProxiesHeader="$GUACAMOLE_PROXY_BY_HEADER"
          protocolHeader="$GUACAMOLE_PROXY_PROTOCOL_HEADER" />
EOF

  LINEN=$(grep -n '</Host>' /usr/local/tomcat/conf/server.xml | cut -d ':' -f 1)
  head -n "$(( LINEN - 1 ))" < /usr/local/tomcat/conf/server.xml > /tmp/head.xml
  tail -n "+$LINEN" < /usr/local/tomcat/conf/server.xml > /tmp/tail.xml

  cat /tmp/head.xml /tmp/valve.xml /tmp/tail.xml > /usr/local/tomcat/conf/server.xml
  cat /usr/local/tomcat/conf/server.xml

  rm -f /tmp/*.xml
fi
