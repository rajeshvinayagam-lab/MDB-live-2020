$ErrorActionPreference = "Stop"

Write-Output "
/***
 *                                                                               
 *     _____                 ____  _____    _____ _ _ _ _            ____          _   _                 _
 *    |     |___ ___ ___ ___|    \| __  |  | __  |_| | |_|___ ___   |    \ ___ ___| |_| |_ ___ ___ ___ _| |___
 *    | | | | . |   | . | . |  |  | __ -|  | __ -| | | | |   | . |  |  |  | .'|_ -|   | . | . | .'|  _| . |_ -|
 *    |_|_|_|___|_|_|_  |___|____/|_____|  |_____|_|_|_|_|_|_|_  |  |____/|__,|___|_|_|___|___|__,|_| |___|___|
 *                  |___|                                    |___|               
 */
"


#$orgID= Read-Host "STEP I -1/1- Provide your organisation ID"
#Write-Output "***************************************************************"

$publicKeyProject= Read-Host "STEP I -1/2- Provide the Public API Key at the  project level"
Write-Output "***************************************************************"
$privateKeyProject= Read-Host "STEP I -2/2- Provide the Private API Key at the  project level"
Write-Output "***************************************************************"
$publicKeyOrg= Read-Host "STEP II -1/2- Provide the Public API key at the  org level"
Write-Output "***************************************************************"
$privateKeyOrg= Read-Host "STEP II -2/2- Provide the Private API key at the  org level"
Write-Output "***************************************************************"
$clusterName= Read-Host "STEP III -1/1- What is the name of the cluster you will store the billing data"
Write-Output "***************************************************************"
Write-Output "Thanks....."

# Obtain Organization ID and Cluster info from Atlas API
$securePassword = ConvertTo-SecureString -String $privateKeyProject -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($publicKeyProject, $securePassword)
$resp = Invoke-WebRequest -Uri https://cloud.mongodb.com/api/atlas/v1.0/clusters -credential $credentials
$json = (ConvertFrom-Json $resp.Content).results[0]
$groupId = $json.groupId
$orgID = $json.orgId


#update the config file for the data source link with the cluster name
$config="{
    `"name`": `"mongodb-atlas`",
    `"type`": `"mongodb-atlas`",
    `"config`": {
        `"clusterName`":`"$clusterName`",
        `"readPreference`": `"primary`",
        `"wireProtocolEnabled`": false
    },
    `"version`": 1
}"

Write-Output "$config" > ./data_sources/mongodb-atlas/config.json


realm-cli login --api-key="$publicKeyProject" --private-api-key="$privateKeyProject"

realm-cli import --yes

Write-Output "Creating the missing secrets: ..."

realm-cli secrets create -n billing-orgSecret -v $orgID
realm-cli secrets create -n billing-usernameSecret -v $publicKeyOrg
realm-cli secrets create -n billing-passwordSecret -v $privateKeyOrg

realm-cli push --remote "billing" -y

Write-Output "Please wait a few seconds before we run the getall function ..."

sleep 30

realm-cli function run --name "getall"

Write-Output "Please wait a few seconds before we run the processall function ..."

realm-cli function run --name "processall"
