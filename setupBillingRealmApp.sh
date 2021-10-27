#!/bin/bash



echo "
/***
 *                                                                                                             
 *     _____                 ____  _____    _____ _ _ _ _            ____          _   _                 _     
 *    |     |___ ___ ___ ___|    \| __  |  | __  |_| | |_|___ ___   |    \ ___ ___| |_| |_ ___ ___ ___ _| |___ 
 *    | | | | . |   | . | . |  |  | __ -|  | __ -| | | | |   | . |  |  |  | .'|_ -|   | . | . | .'|  _| . |_ -|
 *    |_|_|_|___|_|_|_  |___|____/|_____|  |_____|_|_|_|_|_|_|_  |  |____/|__,|___|_|_|___|___|__,|_| |___|___|
 *                  |___|                                    |___|                                             
 */
"


echo "STEP I -1/2- Provide the Public API Key at the  project level:"
read publicKeyProject
echo
echo "***************************************************************"
echo

echo "STEP I -2/2- Provide the Private API Key at the  project level:"
read privateKeyProject
echo
echo "***************************************************************"
echo

echo "STEP II -1/2- Provide the Public API key at the  org level:"
read publicKeyOrg
echo
echo "***************************************************************"
echo

echo "STEP II -2/2- Provide the Private API key at the  org level:"
read privateKeyOrg
echo
echo "***************************************************************"
echo

echo "STEP III -1/1- What is the name of the cluster you will store the billing data?"
read clusterName
echo
echo "***************************************************************"
echo

echo "Thanks....."

# Obtain Organization ID and Cluster info from Atlas API
#resp=$(curl -s https://cloud.mongodb.com/api/atlas/v1.0/clusters --digest -u $publicKeyProject:$privateKeyProject)
#orgId=$(grep -Po "\"orgId\":\"\K.*?(?=\")" <<< $resp)
#groupId=$(grep -Po "\"groupId\":\"\K.*?(?=\")" <<< $resp)
orgID=$(curl -s https://cloud.mongodb.com/api/atlas/v1.0 --digest -u $publicKeyOrg:$privateKeyOrg | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F/ '/^href/ {print $8}')

#Rewrite the config.json file in data source so we can select a different cluster
config='{
    "name": "mongodb-atlas",
    "type": "mongodb-atlas",
    "config": {
        "clusterName": "'$clusterName'",
        "readPreference": "primary",
        "wireProtocolEnabled": false
    },
    "version": 1
}'
echo "$config" > ./data_sources/mongodb-atlas/config.json

realm-cli login --api-key="$publicKeyProject" --private-api-key="$privateKeyProject"

realm-cli import --yes 

echo "We will create the missing secrets now: ..."

realm-cli secrets create -n billing-orgSecret -v $orgID
realm-cli secrets create -n billing-usernameSecret -v $publicKeyOrg
realm-cli secrets create -n billing-passwordSecret -v $privateKeyOrg

realm-cli push --remote "billing" -y

echo "Please wait a few seconds (30s) before we run the function ..."

sleep 30

realm-cli function run --name "getData"
