#!/bin/bash

set -e

if [ "$#" -ne 1 ]
then
        echo "Usage: create_cred.sh [user]"
        exit 1
fi

user=$1

echo "create role and binding for user $user"
kubectl create -f ${user}role.yaml
kubectl create -f ${user}rolebinding.yaml

kubectl get role ${user}role -n ${user}-namespace --tenant=${user}tenant -o yaml > generatedrole
kubectl get rolebinding ${user}rolebinding -n ${user}-namespace --tenant=${user}tenant -o yaml > generatedrolebinding

echo "created role and role binding"
echo ----------------------
diff -y -W 150 generatedrole generatedrolebinding
echo ----------------------
