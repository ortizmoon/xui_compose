#!/bin/sh
set -e

domain="$DOMAIN"
email="$EMAIL"

## Temp cloudflare.ini
creds="/tmp/cloudflare.ini"
printf "dns_cloudflare_api_token = %s\n" "$CF_API_TOKEN" > "$creds"
chmod 600 "$creds"

if [ ! -e "/etc/letsencrypt/live/${domain}/fullchain.pem" ]; then
  certbot certonly \
    --non-interactive --agree-tos \
    --email "${email}" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$creds" \
    --dns-cloudflare-propagation-seconds 60 \
    -d "${domain}" -d "*.${domain}"
fi

while :; do
  certbot renew \
    --non-interactive \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$creds" \
    --dns-cloudflare-propagation-seconds 60
  sleep 12h
done