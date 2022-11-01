#! /bin/bash
set -e

alias='JsApexUtils'
duration=7
configFile='config/default-scratch-def.json'
devhubusername=

while getopts a:d:f:v: option
do
    case "${option}" in
        a )             alias=${OPTARG};;
        d )             duration=${OPTARG};;
        f )             configFile=${OPTARG};;
        v )             devhubusername=${OPTARG};;
        * )
    esac
done

echo "npm ci"
npm ci

if [ -z "$devhubusername" ]; then
    echo "sfdx force:org:create -d $duration -f $configFile -a $alias -s"
    sfdx force:org:create -d "$duration" -f "$configFile" -a "$alias" -s
else
    echo "sfdx force:org:create -v $devhubusername -d $duration -f $configFile -a $alias -s"
    sfdx force:org:create -v "$devhubusername" -d "$duration" -f "$configFile" -a "$alias" -s
fi

echo "sfdx force:source:push -u $alias"
sfdx force:source:push -u "$alias"

echo "sfdx force:data:tree:import -p data/plans/standard-plan.json -u $alias"
sfdx force:data:tree:import -p data/plans/standard-plan.json -u "$alias"

echo "sfdx force:org:open -u $alias"
sfdx force:org:open -u "$alias"
