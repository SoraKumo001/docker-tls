# docker-tls

## Download

```.sh
curl -O https://raw.githubusercontent.com/SoraKumo001/docker-tls/master/docker-tls.sh
```

## Usage

```.sh
sudo sh docker-tls.sh
```

```.sh
sudo sh docker-tls.sh DNS:host.example.com,IP:10.1.1.1
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
