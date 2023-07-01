#!/bin/bash

set -ex

GITLAB_SERVER=https://gitlab.com
GITLAB_ACCESS_TOKEN=glpat-nztNsQeQWCaEuJ6cZWWJ
PROJECT_ID=47132125
KUBE_TOKEN=MGMT_WEST_KUBE_TOKEN
KUBE_PEM_FILE=MGMT_WEST_KUBE_PEM_FILE
KUBE_URL=MGMT_WEST_KUBE_URL
SA=devops-cluster-admin

SECRET=$(kubectl get sa $SA -o json -n kube-system | jq -r .secrets[].name)
export SA_SECRET_TOKEN=$(kubectl -n kube-system get secret $SECRET -o=go-template='{{.data.token}}' | base64 --decode)
export CLUSTER_CA_CERT=$(kubectl get secret $SECRET -n kube-system -o jsonpath="{['data']['ca\.crt']}" | base64 --decode)
export CLUSTER_ENDPOINT=$(dig +short myip.opendns.com @resolver1.opendns.com)
export API_SERVER_URL=https://$CLUSTER_ENDPOINT:8443

# Update Existing KUBE_TOKEN var
curl --request PUT --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
     "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/variables/$KUBE_TOKEN" --form "value=$SA_SECRET_TOKEN"

# Update Existing KUBE_PEM_FILE var
curl --request PUT --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
     "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/variables/$KUBE_PEM_FILE" --form "value=$CLUSTER_CA_CERT"

# Update Exixting KUBE_URL var
curl --request PUT --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
     "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/variables/$KUBE_URL" --form "value=$API_SERVER_URL"
