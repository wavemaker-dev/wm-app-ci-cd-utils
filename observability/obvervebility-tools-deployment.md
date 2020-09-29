# Observability tools deployments

## Fluentd deployment

- Create Kubernetess config map using kubernetes con file , by editing file according to requirements. 
- Example provide name of deployment in file path at source section and providing tag.

```conf
<source>
  @type tail
  path /var/log/containers/<webapp-deployment-name>*.log
  pos_file /var/log/<posfilename>.log.pos
  tag <tag>
  read_from_head true
  format multiline
  format_firstline /[0-9].[0-9].[0-9].[0-9]/
  format1 /^(?<datetime>[0-9]{2} [A-Za-z]{3} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}) (?<log-level>[A-Z]*) (?<thread>[^ ]*)  \[(?<classname>.*)\] - (?<message>.*)$/
  <parse>
    @type "#{ENV['FLUENT_CONTAINER_TAIL_PARSER_TYPE'] || 'json'}"
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>
```

- Execute the below command for create Config Map

```shell
kubectl create configmap kubernetes-conf --from-file=kubernetes.conf
```

- Create config map for fluent conf file, by execute the following command

```shell
kubectl create configmap fluentd-conf --from-file=fluent.conf
```

- Deploy fluentd daemon set , by executing the following command.

```
kubectl apply -f fluentd-daemonset.yml
```

## Elasticsearch Cluster deployment

- Deploy Elasticsearch Cluster by running following command

```shell
kubectl apply -f elasticsearch-deployment.yml
```

## Kibana deployment

- Deploy kibana using helm charts, use the following helm command deploy kibana

```shell
helm install kibana stable/kibana  -f kibana-values.yml --set service.type=NodePort --set service.nodePort=<port-no> --set service.externalPort=80
```

## Prometheus deployment

- Use the following command to Deploy prometheus by using helm chart

```shell
helm install prometheus stable/prometheus -f values.yml --namespace default --set alertmanager.persistentVolume.storageClass="<storage-class-name" --set server.persistentVolume.storageClass="storage-class-name" --set server.service.type=NodePort --set server.service.nodePort=<nodeport>
```

## Grafana deployment

- use following command to deploy grafana using helm chart

```shell
helm install grafana stable/grafana --namespace default --set persistence.storageClassName="storage-class-name" --set persistence.enabled=true --set adminPassword='<PASSWORD>' --values grafana.yaml --set service.type=NodePort --set service.nodePort=32510
```
