#!/usr/bin/env bash

## You will need a .csv with comma-separated values (you can change the separator on awk -F 'separator' line) file with the repo name to Gogs, the GitHub url and a description to your new Gogs repo
##      Example: repo,https://github.com/gogs/go-gogs-client.git,My description

## To find your Gogs token (if you already created one on your Gogs cliente) you can run this command on Terminal:
##      curl -u 'myuser' mygogsurl/api/v1/users/myuser/tokens
## You will receive a json output, and then, copy the token and paste on 'GOGS_TOKEN' variable replancing '#' symbol

## Here your .csv file path. I recommend you put in the same directory as the bash script, so you can just insert .csv filename
file="#"

## Your gogs url example: https://mygogsurl.com
GOGS_URL=${GOGS_URL:-"#"}

## Gogs Token (you have to generate one on your gogs client if you don't already have one)
GOGS_TOKEN=${GOGS_TOKEN:-"#"}

## The owner_uid (int) of the user/organization
owner_uid=#

## Loop to read the csv file and store values on arrays to run the command for multiple repos
while read line; do

	name=($(echo $line | awk -F "," {'print $1'} $file))
	clone_url=($(echo $line | awk -F "," {'print $2'} $file))

## The IFS says that you can insert descriptions with blank spaces
	IFS=$'\n' description=($(echo $line | awk -F "," {'print $3'} $file))

done < $file

##Loop to iterate the arrays and run curl command to migrate the repos and store the output in a .json file. I recommend that you use a .json beautifier
for ((i = 0; i < ${#name[@]}; i++)); do

## Verbose curl command to migrate all repos that are listed on your .csv file
	curl -v --data '{"repo_name": "'"${name[i]}"'", "description":"'"${description[i]}"'", "mirror": true, "uid": '$owner_uid', "clone_addr": "'"${clone_url[i]}"'"}' \
	-H "Content-Type: application/json" $GOGS_URL/api/v1/repos/migrate?token=$GOGS_TOKEN  > gogs.json

done
