#! /bin/bash
set -e

alias='UatScratch'
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

echo "Create scratch org without namespace ..."
sf org create scratch \
    -v "$devhubusername" \
    --duration-days "$duration" \
    --definition-file "$configFile" \
    --alias "$alias" \
    --set-default \
    --no-namespace
