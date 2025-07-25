#! /bin/bash

accountId=###
configFileDir="/Users/Shared/Produce8-Agent"

mkdir $configFileDir

echo "account.accountId=$accountId" > "$configFileDir/account.properties"