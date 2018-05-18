#!/usr/bin/env bash
export KUBECONFIG=~/Downloads/dev-kubeconfig_yaml.yaml
rawAWS=$(aws ec2 --profile fishtech describe-volumes | jq '.Volumes[] | .State, .VolumeId')
AWS="$(echo "$rawAWS" | fgrep -xv '"in-use"')"
final="$(echo "$AWS" | egrep -A 1 -o '"available"')"
if [ -z "$final" ]
then
    echo "All in-use" && exit 0
else
    rawKUBE=$(kubectl describe pv | egrep -o 'vol-\w+')
    arr=($rawKUBE)
    ARR=()
    for i in "${arr[@]}"
    do 
        ARR+="$(echo $final | egrep -o $i)"
    done
    if [ -z "$ARR"]
    then
        remove="$(echo $final | egrep -o "vol-\w+")"
        echo "$remove should be deleted" && exit 1
    else
        echo 'Available volumes listed in Kubernetes' && exit 0
    fi
fi 
