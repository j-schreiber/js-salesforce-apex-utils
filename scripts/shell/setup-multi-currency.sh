#! /bin/bash
set -e

alias='JsApexUtilsCurrencies'
duration=7
configFile='config/default-scratch-def.json'
devhubusername=''

while getopts a:d:f:v: option; do
    case "${option}" in
    a) alias=${OPTARG} ;;
    d) duration=${OPTARG} ;;
    f) configFile=${OPTARG} ;;
    v) devhubusername=${OPTARG} ;;
    *) ;;
    esac
done

echo "npm ci"
npm ci

if [ -z "$devhubusername" ]; then
    echo "sf org create scratch -y $duration -f $configFile -a $alias -d --json"
    sf org create scratch -y $duration -f $configFile -a $alias -d --json
else
    echo "sf org create scratch -v $devhubusername -y $duration -f $configFile -a $alias -d --json"
    sf org create scratch -v $devhubusername -y $duration -f $configFile -a $alias -d --json
fi

echo "sf project deploy start -o $alias"
sf project deploy start -o "$alias"

echo "sf data tree import -p data/plans/multi-currency-plan.json -o $alias"
sf data tree import -p data/plans/multi-currency-plan.json -o "$alias"

echo "sf org open -o $alias"
sf org open -o "$alias"
