#!/bin/sh

TEMP_DIR=/tmp/docker-temp
SERVER_DIR=/etc/docker/certs
CLIENT_DIR=${HOME}/.docker
CERTS_PASS=password
CERTS_NAMES=IP:127.0.0.1,DNS:localhost
CERTS_INFO="JP\n\n\n\n\n\n\n\n\n"
CERTS_DAYS=36500

if [ -n $1 ]; then
    CERTS_NAMES=$CERTS_NAMES,$1
fi

#mkdir
mkdir -p $TEMP_DIR
mkdir -p $SERVER_DIR
mkdir -p $CLIENT_DIR
cd ${TEMP_DIR}

#Myself
openssl genrsa -aes256 -passout pass:$CERTS_PASS -out ca-key.pem 4096 
echo -e $CERTS_INFO | openssl req -new -x509 -passin pass:$CERTS_PASS -days $CERTS_DAYS -key ca-key.pem -sha256 -out ca.pem

#Server
openssl genrsa -out server-key.pem 4096 
echo -e $CERTS_INFO | openssl req -subj "/CN=server" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = $CERTS_NAMES > extfile.cnf
openssl x509 -req -days $CERTS_DAYS -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -passin pass:$CERTS_PASS -out server-cert.pem -extfile extfile.cnf

#Client
openssl genrsa -out key.pem 4096 
echo -e $CERTS_INFO | openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth > extfile.cnf
openssl x509 -req -days $CERTS_DAYS -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -passin pass:$CERTS_PASS -out cert.pem -extfile extfile.cnf

#chmod
chmod 0400 ca-key.pem server-key.pem key.pem
chmod 0444 ca.pem server-cert.pem cert.pem

# Server keys
cp -f ./ca.pem ${SERVER_DIR}
mv -f ./server-key.pem ${SERVER_DIR}
mv -f ./server-cert.pem ${SERVER_DIR}

# Client keys
mv -f ca.pem ${CLIENT_DIR}
mv -f cert.pem ${CLIENT_DIR}
mv -f key.pem ${CLIENT_DIR}
if [ -n $SUDO_UID -a -n $SUDO_GID ]; then
    chown -R ${SUDO_UID}:${SUDO_GID} ${CLIENT_DIR}
fi

#delete temp
rm -rf ${TEMP_DIR}

echo -e "\n\n-- Create files --"
echo ${SERVER_DIR}/ca.pem
echo ${SERVER_DIR}/server-key.pem
echo ${SERVER_DIR}/server-cert.pem
echo ${CLIENT_DIR}/ca.pem
echo ${CLIENT_DIR}/cert.pem
echo ${CLIENT_DIR}/key.pem

echo -e "\n\n-- Edit file--"
echo -e "/lib/systemd/system/docker.service\n"
echo ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/etc/docker/certs/ca.pem --tlscert=/etc/docker/certs/server-cert.pem --tlskey=/etc/docker/certs/server-key.pem -H tcp://0.0.0.0 -H fd:// --containerd=/run/containerd/containerd.sock
echo
