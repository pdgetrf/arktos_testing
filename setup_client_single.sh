#!/bin/bash

set -e

if [ "$#" -ne 2 ]
then
        echo "Usage: setup_client.sh [org] [person]"
        exit 1
fi

org=$1
person=$2
tenant_name="${org}tenant"
namespace="${org}-namespace"
org_person="${org}-${person}"
group_name="${org}-group"
context_name="${org_person}-context"

CONFIG=/var/run/kubernetes/admin.kubeconfig
#if [ -f "$CONFIG" ]; then
#    echo "making a backup of previous config at $CONFIG.bk"
#    mv $CONFIG $CONFIG.bk
#fi

echo "generating a client key $org.key..."
openssl genrsa -out $org_person.key 2048 > /dev/null 2>&1

echo "creating a sign request $org.csr..."
openssl req -new -key $org_person.key -out $org.csr -subj "/CN=$person/O=tenant:$tenant_name/OU=$group_name" > /dev/null 2>&1

echo "creating an org certificate $org.crt and get it signed by CA"
openssl x509 -req -in $org.csr -CA /var/run/kubernetes/client-ca.crt -CAkey /var/run/kubernetes/client-ca.key -CAcreateserial -out $org_person.crt -days 500 > /dev/null 2>&1

echo "Setting up org context..."
kubectl config set-cluster ${org_person}-cluster --server=https://ip-172-31-27-32:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt > /dev/null 2>&1
kubectl config set-credentials ${org_person} --client-certificate=$org_person.crt --client-key=$org_person.key > /dev/null 2>&1
kubectl config set-context $context_name --cluster=${org_person}-cluster --namespace=$namespace --user=$org_person --tenant=$tenant_name > /dev/null 2>&1
echo ----------------------
cat $CONFIG 
echo ----------------------

set -x
kubectl --context=${context_name} get pods
