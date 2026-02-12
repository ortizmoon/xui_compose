#!/bin/sh
set -e

domain="$DOMAIN"
email="$EMAIL"

## Temp cloudflare.ini
creds="/tmp/cloudflare.ini"
printf "dns_cloudflare_api_token = %s\n" "$CF_API_TOKEN" > "$creds"
chmod 600 "$creds"

cert_dir="/etc/letsencrypt/live/${domain}"

bundle_pem() {
  cat "${cert_dir}/fullchain.pem" "${cert_dir}/privkey.pem" > "${cert_dir}/bundle.pem"
  chmod 600 "${cert_dir}/bundle.pem"
}

if [ ! -e "${cert_dir}/fullchain.pem" ]; then
  certbot certonly \
    --non-interactive --agree-tos \
    --email "${email}" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$creds" \
    --dns-cloudflare-propagation-seconds 60 \
    -d "${domain}" -d "*.${domain}"
fi

bundle_pem

while :; do
  certbot renew \
    --non-interactive \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$creds" \
    --dns-cloudflare-propagation-seconds 60
  bundle_pem
  sleep 12h
done