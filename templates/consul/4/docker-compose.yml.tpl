us-east-1-consul-base:
  image: consul:0.8.1
  entrypoint:
    - /opt/rancher/bin/start_consul.sh
  net: "container:consul"
  labels:
    io.rancher.container.hostname_override: container_name
  volumes_from:
    - us-east-1-consul-data
us-east-1-consul-data:
  image: alpine:latest
  entrypoint:
    - /bin/true
  labels:
    io.rancher.container.hostname_override: container_name
    io.rancher.container.start_once: true
  volumes:
    - /var/consul
    - /opt/rancher/bin
    - /opt/rancher/ssl
    - /opt/rancher/config
  net: none
us-east-1:
  image: bluemedorapublic/consul-config:latest
  labels:
    io.rancher.container.hostname_override: container_name
    io.rancher.sidekicks: us-east-1-consul-base,us-east-1-consul-data
    io.rancher.scheduler.affinity:host_label: region=us-east-1
  volumes_from:
    - us-east-1-consul-data
{{- if eq .Values.ui "true"}}
consul-lb:
  ports:
  - 8500:8500/tcp
  expose:
  - 8500:8500/tcp
  tty: true
  image: rancher/load-balancer-service
  links:
  - us-east-1:us-east-1-consul-base
  stdin_open: true
{{- end }}
