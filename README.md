# nginx-certbot

# environment

- `SERVICE_NAME`: name of linked service
- `SERVICE_PORT`: port of linked service (default: 80)
- `SERVER_NAME`: DNS name for letsecnrypt
- `CERT_EMAIL`:  email for letsencrypt

# volume

- `/etc/letsencrypt`

# ports

- 80
- 443

# links

- link your service
