#!/bin/bash
# {{ansible_managed}}
#
# This script is to be used in a cron job to automatically renew
# certificates and restart processes.

if [ "$(whoami)" != "root" ]; then
  echo "must be root"
  exit 1
fi

wanted_domains=(
  {% for domain in wanted_domains %}
  {{domain}}
  {% endfor %}
)

/usr/bin/acmetool --batch reconcile
if [ $? -ne 0 ]; then
  echo "acmetool reconcile failed"
  exit 1
fi

for domain in ${wanted_domains[@]}; do
  ln -sf /var/lib/acme/live/${domain}/haproxy /etc/haproxy/certs/${domain}
done

systemctl restart haproxy
