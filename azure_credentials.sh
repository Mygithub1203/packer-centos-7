#!/bin/bash -eu

createmenu(){
    arrsize=$1
    select option in "${@:2}"; do
        if [ "$REPLY" -eq "$((arrsize +1))" ];
        then
            echo "Exiting..."
            break;
        elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((arrsize+1)) ];
        then
            echo "$((REPLY-1))"
            break;
        else
            echo "Incorrect Input: Select a number 1-$arrsize"
        fi
    done
}

# requires jq & azure cli
echo "This should only be executed after you have logged in with azure login -u username"
read -p "Did you login successfully, to the right account? [y/n]" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    azure config mode arm

    APPURL="http://provision.deeplearn.online"
    export ARM_CLIENT_SECRET=$(openssl rand -base64 24)

    ARM_SUBSCRIPTION_NAMES=$(azure account list --json | jq '.[]| .name'| tr " " '_')
    ARM_SUBSCRIPTION_IDS=$(azure account list --json | jq '.[]| .id')
    ARM_SUBSCRIPTION_NAMES=($ARM_SUBSCRIPTION_NAMES)
    ARM_SUBSCRIPTION_IDS=($ARM_SUBSCRIPTION_IDS)

    SELECTED=$(createmenu "${#ARM_SUBSCRIPTION_NAMES[@]}" "${ARM_SUBSCRIPTION_NAMES[@]}")

    ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_IDS[$SELECTED]}

    ARM_SUBSCRIPTION_ID=$(azure account show --json | jq ".[] | .id")
    ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID%\"}
    export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID#\"}

    ARM_FORMER_CLIENT_ID=$(azure ad app list --json |  jq '.[] | select(.displayName | contains("centos7-image-provisioning")) | .objectId')
    ARM_FORMER_CLIENT_ID=${ARM_FORMER_CLIENT_ID%\"}
    export ARM_FORMER_CLIENT_ID=${ARM_FORMER_CLIENT_ID#\"}
    if [ ! -z $ARM_FORMER_CLIENT_ID ]; then
        azure ad app delete $ARM_FORMER_CLIENT_ID
    fi
    azure ad app create -n "centos7-image-provisioning" -i $APPURL --home-page $APPURL -p $ARM_CLIENT_SECRET
    sleep 30 # app ID registration takes time
    ARM_CLIENT_ID=$(azure ad app list --json |  jq '.[] | select(.displayName | contains("centos7-image-provisioning")) | .appId')
    ARM_CLIENT_ID=${ARM_CLIENT_ID%\"}
    export ARM_CLIENT_ID=${ARM_CLIENT_ID#\"}
    azure ad sp create --applicationId $ARM_CLIENT_ID
    sleep 40
    azure role assignment create --spn $APPURL -o "Owner" -c /subscriptions/$ARM_SUBSCRIPTION_ID

    export ARM_RESOURCE_GROUP="centos7-image-provisioning$(openssl rand -hex 4)"
    azure group create -n "$ARM_RESOURCE_GROUP" -l eastus
    export ARM_STORAGE_ACCOUNT="centos7storage$(openssl rand -hex 4)"
    # export ARM_STORAGE_ACCOUNT="centos7storageprovision
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
