#!/bin/bash -e

if [ -z "${SERVER_NAME}" ]; then
	echo "Missing SERVER_NAME env."
	exit 1
fi

if [ -z "${SERVICE_NAME}" ]; then
	echo "Missing SERVICE_NAME env."
	exit 1
fi

if [ -z "${SERVICE_PORT}" ]; then
	SERVICE_PORT=80
fi

if [ -z "${CERT_EMAIL}" ]; then
	echo "Missing CERT_EMAIL env."
	exit 1
fi

sed	-e "s/SERVER_NAME/${SERVER_NAME}/" \
	-e "s/SERVICE_NAME/${SERVICE_NAME}/" \
	-e "s/SERVICE_PORT/${SERVICE_PORT}/" \
	/nginx.conf.template > /etc/nginx/conf.d/default.conf

if [ -e "/etc/letsencrypt/live/${SERVER_NAME}/fullchain.pem" ] && [ -e "/etc/letsencrypt/live/${SERVER_NAME}/privkey.pem" ]; then
	sed -i "s/#ssl_certificate/ssl_certificate/" /etc/nginx/conf.d/default.conf
fi

service dnsmasq restart

mkdir -p /etc/letsencrypt/www

echo "Starting nginx..."
nginx -g "daemon off;" &

NGINX_PID=$!

sleep 1

certbot certonly --non-interactive --agree-tos --email "$CERT_EMAIL" --webroot -w /etc/letsencrypt/www -d $SERVER_NAME

if [ ! -e "/etc/letsencrypt/live/${SERVER_NAME}/fullchain.pem" ] || [ ! -e "/etc/letsencrypt/live/${SERVER_NAME}/privkey.pem" ]; then
	echo "Missing certificates, something went wrong."
	exit 1
fi

sed -i "s/#ssl_certificate/ssl_certificate/" /etc/nginx/conf.d/default.conf

nginx -s reload

while s=`ps -p $NGINX_PID -o s=` && [[ "$s" && "$s" != 'Z' ]]; do
	sleep 1
done

echo "Exit!"
