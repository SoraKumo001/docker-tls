# docker-tls

## usage

```.sh
sudo sh docker-tls.sh
```

## Create files

- Server keys
  - /etc/docker/certs/ca.pem
  - /etc/docker/certs/server-key.pem
  - /etc/docker/certs//server-cert.pem
- Client keys
  - ~/.docker/ca.pem
  - ~/.docker/cert.pem
  - ~/.docker/key.pem

## Docker server setting

- /lib/systemd/system/docker.service

```/lib/systemd/system/docker.service
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/docker/certs/ca.pem --tlscert=/etc/docker/certs/server-cert.pem --tlskey=/etc/docker/certs/server-key.pem -H tcp://0.0.0.0 -H fd:// --containerd=/run/containerd/containerd.sock
```

## Restart service

```.sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Client command

```.sh
docker --tls -H server-address ps
```
