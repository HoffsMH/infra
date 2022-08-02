FROM pihole/pihole:latest

COPY pihole-updatelists.php /usr/local/sbin/pihole-updatelists
COPY pihole-updatelists.conf /etc/pihole-updatelists.conf
COPY pihole-updatelists.cron /etc/cron.d/pihole-updatelists
COPY additional-regex.txt /etc/additional-regex.txt

RUN chmod 700 /usr/local/sbin/pihole-updatelists

RUN chmod 600 /etc/cron.d/pihole-updatelists

RUN /usr/local/sbin/pihole-updatelists
RUN pihole -w "api.rescuetime.com"


RUN apt-get update && apt-get install -y \
  php-curl \
  && rm -rf /var/lib/apt/lists/*
