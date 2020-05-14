#!/bin/bash

#set -e

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

echo "create cluster role and binding for user $user"
kubectl create -f ${user}clusterrole.yaml
kubectl create -f ${user}clusterrolebinding.yaml

kubectl get clusterrole ${user}clusterrole -n ${user}-namespace --tenant=${user}tenant -o yaml > generatedclusterrole
kubectl get clusterrolebinding ${user}clusterrolebinding -n ${user}-namespace --tenant=${user}tenant -o yaml > generatedclusterrolebinding

echo "created cluster role and cluster role binding"
echo ----------------------
diff -y -W 150 generatedclusterrole generatedclusterrolebinding
echo ----------------------
