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

echo "This script configures a MongoDB Realm app which extracts data from the Atlas Billing API"
echo "and writes it to an Atlas Cluster"
echo 
echo "Before you run this script, make sure you have:"
echo "1. Created a new MongoDB Atlas project for your billing app"
echo "2. Created a new cluster inside that project for storing billing data"
echo "3. Created an API Key inside that project, and recorded the public and private key details"
echo "4. Created an API Key for your Organization and recorded the public and private key details"
echo "5. Installed dependencies for this script: node, mongodb-realm-cli"
echo "For more details on these steps, see the README.md file."
echo

# Prompt for API Keys
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

# Import the Realm app
realm-cli login --api-key="$publicKeyProject" --private-api-key="$privateKeyProject"
realm-cli import --yes 

# Write secrets to Realm app
echo "We will create the missing secrets now: ..."
realm-cli secrets create -n billing-orgSecret -v $orgID
realm-cli secrets create -n billing-usernameSecret -v $publicKeyOrg
realm-cli secrets create -n billing-passwordSecret -v $privateKeyOrg
realm-cli push --remote "billing" -y

# Run functions to retrieve billing data for the first time
echo "Please wait a few seconds (30s) before we run the function ..."

sleep 30

realm-cli function run --name "getData"


# Next Steps
echo
echo "Setup Complete! Please log into Atlas and verify that data has been loaded into the cluster."
echo "To visualize the billing data on a dashboard:"
echo "1. Activate Charts in your Atlas project"
echo "2. Add Data Sources for your billing collections"
echo "3. Import the dashboard from the included file 'charts_billing_template.charts'"