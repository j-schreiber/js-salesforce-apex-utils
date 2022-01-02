#!bin/bash
set -e

alias='YourPackageAlias'
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
    esac
done

KEYS=scripts/.config/keys.env
if [ -f "$KEYS" ]; then
    set -o allexport
    source scripts/.config/keys.env
    set +o allexport
fi

if [ -z "$INSTALLATION_KEY_ONE" ]; then 
    echo 'Installation key for dependency not set. Export the key as environment variable with "export INSTALLATION_KEY_ONE=key" to avoid this prompt.'
    read -p 'Enter installation key for the converter dependency: ' key
    export INSTALLATION_KEY_ONE=$key
fi
if [ -z "$INSTALLATION_KEY_TWO" ]; then 
    echo 'Installation key for dependency not set. Export the key as environment variable with "export INSTALLATION_KEY_TWO=key" to avoid this prompt.'
    read -p 'Enter installation key for the core dependency: ' key
    export INSTALLATION_KEY_TWO=$key
fi

if [ -z "$INSTALLATION_KEY_ONE" ] || [ -z "$INSTALLATION_KEY_TWO" ]
then
    echo "At least one installation key not setup. Exiting ..." >&2
    exit 1
fi

echo "npm ci"
npm ci

echo "mkdir -p force-app"
mkdir -p force-app

if [ -z "$devhubusername" ]; then
    echo "sfdx force:org:create -d $duration -f $configFile -a $alias -s"
    sfdx force:org:create -d $duration -f $configFile -a $alias -s
else
    echo "sfdx force:org:create -v $devhubusername -d $duration -f $configFile -a $alias -s"
    sfdx force:org:create -v $devhubusername -d $duration -f $configFile -a $alias -s
fi

echo "sfdx force:package:install -p \"First Dependency Package Version\" -u $alias -w 10 -k $INSTALLATION_KEY_ONE"
sfdx force:package:install -p "First Converter Dependency Package Version" -u $alias -w 10 -k $INSTALLATION_KEY_ONE

echo "sfdx force:package:install -p \"Second Dependency Package Version\" -u $alias -w 10 -k $INSTALLATION_KEY_TWO"
sfdx force:package:install -p "Second Dependency Package Version" -u $alias -w 10 -k $INSTALLATION_KEY_TWO

echo "sfdx force:source:push -u $alias"
sfdx force:source:push -u $alias

echo "sfdx force:user:permset:assign -n Package_Developer_Permission_Set -u $alias"
sfdx force:user:permset:assign -n Package_Developer_Permission_Set -u $alias

echo "sfdx force:data:tree:import -p data/plans/standard-plan.json -u $alias"
sfdx force:data:tree:import -p data/plans/standard-plan.json -u $alias

echo "sfdx force:org:open -u $alias"
sfdx force:org:open -u $alias
