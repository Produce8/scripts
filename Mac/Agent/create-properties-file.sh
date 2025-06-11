#! /bin/bash

# EG: accountId=59079b49-772c-453b-bb33-70a04e372466
accountId={###}

currentuser=`/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4`

mkdir "/Users/$currentuser/Library/Application Support/Produce8-Agent/"

echo "account.accountId=$accountId" > "/Users/$currentuser/Library/Application Support/Produce8-Agent/account.properties"