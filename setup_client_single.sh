#!/bin/bash

set -e

if [ "$#" -ne 2 ]
then
        echo "Usage: setup_client.sh [user] [person]"
        exit 1
fi

user=$1
person=$2
tenant_name="${user}tenant"
namespace="${user}-namespace"
group_name="${user}-group"
context_name="${user}-context"

CONFIG=/var/run/kubernetes/admin.kubeconfig
#if [ -f "$CONFIG" ]; then
#    echo "making a backup of previous config at $CONFIG.bk"
#    mv $CONFIG $CONFIG.bk
#fi

echo "generating a client key $user.key..."
openssl genrsa -out $user.key 2048 > /dev/null 2>&1

echo "creating a sign request $user.csr..."
openssl req -new -key $user.key -out $user.csr -subj "/CN=$person/O=tenant:$tenant_name/OU=$group_name" > /dev/null 2>&1

echo "creating a user certificate $user.crt and get it signed by CA"
openssl x509 -req -in $user.csr -CA /var/run/kubernetes/client-ca.crt -CAkey /var/run/kubernetes/client-ca.key -CAcreateserial -out $user.crt -days 500 > /dev/null 2>&1

echo "Setting up user context..."
kubectl config set-cluster ${user}-cluster --server=https://ip-172-31-27-32:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt > /dev/null 2>&1
kubectl config set-credentials $person --client-certificate=$user.crt --client-key=$user.key > /dev/null 2>&1
kubectl config set-context $context_name --cluster=${user}-cluster --namespace=$namespace --user=$person --tenant=$tenant_name > /dev/null 2>&1
echo ----------------------
cat $CONFIG 
echo ----------------------

set -x
kubectl --context=${user}-context get pods
