#!/bin/bash

set -e

if [ "$#" -ne 1 ]
then
        echo "Usage: create_cred.sh [user]"
        exit 1
fi

user=$1
namespace="$1namespace"

tenant_name="$1tenant"
tenant_name2="${tenant_name}xyz"
group_name="$1group"
context_name="$1-context"

echo "create cert for tenant $tenant_name"

set -x
kubectl create ns $namespace
openssl genrsa -out $user.key 2048
openssl req -new -key $user.key -out $user.csr -subj "/CN=$user/O=tenant:$tenant_name/OU=$group_name"
openssl x509 -req -in $user.csr -CA /var/run/kubernetes/client-ca.crt -CAkey /var/run/kubernetes/client-ca.key -CAcreateserial -out $user.crt -days 500
kubectl config set-credentials $user --client-certificate=/root/$user.crt --client-key=/root/$user.key
kubectl config set-context $context_name --cluster=local-up-cluster --namespace=$namespace --user=$user --tenant=$tenant_name2
