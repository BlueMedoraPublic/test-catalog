us-east-1-consul-base:
  image: consul:0.8.1
  entrypoint:
    - /opt/rancher/bin/start_consul.sh
  net: "container:us-east-1"
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
  environment:
  - DC=${DC}
  - DNS=${DNS}
  - HTTPPORT=${HTTPPORT}
  - SERVERPORT=${SERVERPORT}
  - SERF_LANPORT=${SERF_LANPORT}
  - SERF_WANPORT=${SERF_WANPORT}
  ports:
  - "${SERVERPORT}:8300/tcp"
  - "${SERF_LANPORT}:8301/tcp"
  - "${SERF_LANPORT}:8301/udp"
  - "${SERF_WANPORT}:8302/tcp"
  - "${SERF_WANPORT}:8302/udp"
  - "${HTTPPORT}:8500/tcp"
  - "${DNS}:8600/tcp"
  - "${DNS}:8600/udp"
  - 127.0.0.1:8400/tcp
  - 127.0.0.1:8400/udp
  labels:
    io.rancher.container.dns: true
    io.rancher.container.hostname_override: container_name
    io.rancher.sidekicks: us-east-1-consul-base,us-east-1-consul-data
    io.rancher.scheduler.affinity:host_label: region=us-east-1
    io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
  volumes_from:
    - us-east-1-consul-data
{{- if eq .Values.ui "true"}}
us-east-1-lb:
  ports:
  - 8500:8500/tcp
  expose:
  - 8500:8500/tcp
  tty: true
  image: rancher/load-balancer-service
  links:
  - us-east-1:us-east-1-consul-base
  labels:
    io.rancher.scheduler.affinity:host_label: region=us-east-1
  stdin_open: true
{{- end }}
