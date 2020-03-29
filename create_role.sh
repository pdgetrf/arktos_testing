#!/bin/bash

set -e

if [ "$#" -ne 1 ]
then
        echo "Usage: create_cred.sh [user]"
        exit 1
fi

user=$1

echo "create role and binding for user $user"

set -x
kubectl create -f ${user}role.yaml
kubectl create -f ${user}rolebinding.yaml

# test
kubectl --context=${user}-context get pods
#kubectl --context=${user}-context create -f vanilla.yaml
