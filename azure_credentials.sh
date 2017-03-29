#!/bin/bash -eu

# requires jq & azure cli
echo "This should only be executed after you have logged in with azure login -u username"
read -p "Did you login successfully, to the right account? [y/n]" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    azure config mode arm

    APPURL="http://provisioning.deeplearn.online"
    export ARM_CLIENT_SECRET=$(openssl rand -base64 24)
    ARM_SUBSCRIPTION_ID=$(azure account show --json | jq ".[] | .id")
    ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID%\"}
    export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID#\"}

    azure ad app create -n "centos7-provisioning" -i $APPURL --home-page $APPURL -p $ARM_CLIENT_SECRET
    sleep 30 # app ID registration takes time
    ARM_CLIENT_ID=$(azure ad app list --json |  jq '.[] | select(.displayName | contains("centos7-provisioning")) | .appId')
    ARM_CLIENT_ID=${ARM_CLIENT_ID%\"}
    export ARM_CLIENT_ID=${ARM_CLIENT_ID#\"}
    azure ad sp create --applicationId $ARM_CLIENT_ID
    sleep 40
    azure role assignment create --spn $APPURL -o "Owner" -c /subscriptions/$ARM_SUBSCRIPTION_ID

    export ARM_RESOURCE_GROUP="centos7-provisioning-$(openssl rand -base64 6)"
    azure group create -n "$ARM_RESOURCE_GROUP" -l eastus
    export ARM_STORAGE_ACCOUNT="centos7storageprovision-$(openssl rand -base64 6)"
    azure storage account create -g $ARM_RESOURCE_GROUP -l eastus --sku-name LRS --kind storage $ARM_STORAGE_ACCOUNT

    ARM_TENANT_ID=$(azure account show --json | jq ".[] | .user.name")
    ARM_TENANT_ID=${ARM_TENANT_ID%\"}
    export ARM_TENANT_ID=${ARM_TENANT_ID#\"}

    echo "ARM_CLIENT_ID=$ARM_CLIENT_ID"
    echo "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET"
    echo "ARM_TENANT_ID=$ARM_TENANT_ID"
    echo "ARM_RESOURCE_GROUP=$ARM_RESOURCE_GROUP"
    echo "ARM_STORAGE_ACCOUNT=$ARM_STORAGE_ACCOUNT"
    echo "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
fi
