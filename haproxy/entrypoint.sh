#!/bin/sh
sleep 120
sed "s/\${DOMAIN}/$DOMAIN/g" /etc/haproxy/haproxy.cfg > /tmp/haproxy.cfg
exec haproxy -f /tmp/haproxy.cfg
