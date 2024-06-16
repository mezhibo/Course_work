#!/bin/bash

# Получаем IP-адреса
WEBSERVER_1_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-1 | jq -r '.')
WEBSERVER_2_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-2 | jq -r '.')
GRAFANA_INTERNAL_IP=$(terraform output -json internal_ip_address_grafana-server | jq -r '.')
KIBANA_INTERNAL_IP=$(terraform output -json internal_ip_address_kibana-server | jq -r '.')
ELASTICSEARCH_INTERNAL_IP=$(terraform output -json internal_ip_address_elasticsearch-server | jq -r '.')
PROMETHEUS_INTERNAL_IP=$(terraform output -json internal_ip_address_prometheus-server | jq -r '.')
BASTION_EXTERNAL_IP=$(terraform output -json external_ip_address_bastion | jq -r '.')
GRAFANA_EXTERNAL_IP=$(terraform output -json external_ip_address_grafana-server | jq -r '.')
KIBANA_EXTERNAL_IP=$(terraform output -json external_ip_address_kibana-server | jq -r '.')

# Формируем inventory
cat <<EOF > /home/ubuntu/yandex/Ansible/host.ini
[all:vars]
ansible_user=ubuntu
private_key_file = ~/.ssh/id_rsa

[bastion]
bastion-server ansible_host=$BASTION_EXTERNAL_IP

[non_bastion:children]
webservers
elk
monitoring

[non_bastion:vars]
ansible_ssh_common_args='-o ProxyJump={{ansible_user}}@$BASTION_EXTERNAL_IP'

[webservers]
webserver-1 ansible_host=$WEBSERVER_1_INTERNAL_IP 
webserver-2 ansible_host=$WEBSERVER_2_INTERNAL_IP 

[elk]
elasticsearch-server ansible_host=$ELASTICSEARCH_INTERNAL_IP 
kibana-server ansible_host=$KIBANA_INTERNAL_IP 

[monitoring]
prometheus-server ansible_host=$PROMETHEUS_INTERNAL_IP 
grafana-server ansible_host=$GRAFANA_INTERNAL_IP 

EOF

# Добавляем в шаблон nginx внешние IP чтобы можно было их использовать для формирования страницы с информацией.

cat <<EOF > /home/ubuntu/yandex/Ansible/nginx_for_webservers/defaults/main.yml
---
# defaults file for nginx_for_webservers
page_title: "Добро пожаловать на мой сайт"
content_heading: "Информационный сайт по курсовой работе"
content_body: "*ссылки на внешние сервисы, которые доступны из интернета"

bastion_host_info: "bastion-host внешний IP :$BASTION_EXTERNAL_IP"

grafana_info: "http://$GRAFANA_EXTERNAL_IP:3000"
kibana_info: "http://$KIBANA_EXTERNAL_IP:5601"

EOF

# Добавляем данные в var/main.yml для filebeat 

cat <<EOF > /home/ubuntu/yandex/Ansible/filebeat/vars/main.yml
---
# vars file for filebeat
kibana_host: "$KIBANA_EXTERNAL_IP:5601"
elastic_host: "{{ hostvars['elasticsearch-server']['ansible_host'] }}:9200"

EOF

# Добавляем данные в defaults/main.yml для Grafana 

cat <<EOF > /home/ubuntu/yandex/Ansible/grafana_server/defaults/main.yml
---
# defaults file for grafana_server
grafana_admin_user: admin
grafana_admin_password: admin
grafana_external_ip: $GRAFANA_EXTERNAL_IP

EOF

