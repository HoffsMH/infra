FROM nginx:latest

RUN apt-get update && apt-get install -y \
  certbot \
  python3-certbot-nginx \
	cron \
  && rm -rf /var/lib/apt/lists/*


COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY www/ /usr/share/nginx/html

# certbot initial
COPY init-certbot /usr/sbin/init-certbot
RUN chmod 0744 /usr/sbin/init-certbot

# certbot renewal
COPY renew-certbot /etc/cron.d/renew-certbot
RUN chmod 0744 /etc/cron.d/renew-certbot
RUN crontab /etc/cron.d/renew-certbot
RUN touch /var/log/cron.log

COPY entrypoint.sh /entrypoint.sh

RUN chmod 0744 /entrypoint.sh

CMD ["/entrypoint.sh"]
