#!/bin/bash

set -e

if [ "$#" -ne 1 ]
then
        echo "Usage: create_cred.sh [user]"
        exit 1
fi

user=$1

tenant_name="${user}tenant"

namespace="${user}-namespace"

group_name="${user}-group"
context_name="${user}-context"

echo "create cert for tenant $tenant_name"

kubectl create tenant $tenant_name 
kubectl create ns $namespace --tenant $tenant_name

# create certificate for user
openssl genrsa -out $user.key 2048 # client key
openssl req -new -key $user.key -out $user.csr -subj "/CN=$user/O=tenant:$tenant_name/OU=$group_name" # create sign request
openssl x509 -req -in $user.csr -CA /var/run/kubernetes/client-ca.crt -CAkey /var/run/kubernetes/client-ca.key -CAcreateserial -out $user.crt -days 500 # create cert signed by CA

# set user in context
kubectl config set-credentials $user --client-certificate=/root/$user.crt --client-key=/root/$user.key
kubectl config set-context $context_name --cluster=local-up-cluster --namespace=$namespace --user=$user --tenant=$tenant_name
