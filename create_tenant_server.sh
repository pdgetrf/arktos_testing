#!/bin/bash

set -e

if [ "$#" -ne 1 ]
then
        echo "Usage: create_cred_server.sh [user]"
        exit 1
fi

user=$1
tenant_name="${user}tenant"
namespace="${user}-namespace"

echo "create cert for tenant $tenant_name"

kubectl create tenant $tenant_name
#kubectl create ns $namespace --tenant $tenant_name
