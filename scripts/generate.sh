#!/bin/bash

export CLUSTER_NAME="do-lon1-demo"

export APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

export TOKEN=$(kubectl get secret sa1-token -o jsonpath='{.data.token}' | base64 --decode)


server="https://378e3ca6-b825-44c4-85bc-a982fdc51242.k8s.ondigitalocean.com"
ca=$(kubectl get secret/sa1-token -o jsonpath='{.data.ca\.crt}')
token=$(kubectl get secret/sa1-token -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get secret/sa1-token -o jsonpath='{.data.namespace}' | base64 --decode)

echo "
apiVersion: v1
kind: Config
clusters:
- name: default-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: default-context
  context:
    cluster: default-cluster
    namespace: default
    user: default-user
current-context: default-context
users:
- name: default-user
  user:
    token: ${token}
"

