#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x


core_count=$1

end=$((SECONDS+24*60*60))

while [ $SECONDS -lt $end ]; do
    echo "*****"

    echo "Timeout: $SECONDS elapsed out of $end allotted "

    running_builds=$(curl -s "https://api.bitrise.io/v0.1/apps/${BITRISE_APP_SLUG}/builds?status=0" -H "accept: application/json" -H "Authorization: $BITRISE_PERSONAL_ACCESS_TOKEN" | jq ".data | .[] | .machine_type_id" | grep -c "g2.$core_count" || true)
    

    if [[ "$running_builds" -gt '0' ]]; then
    echo "There are still running builds. Not starting more"
    sleep 30
    continue
    fi

    echo "Starting builds" 

    workflow_suffixes=("xcode13.0-6_sims" "xcode12.5-6_sims" "xcode12.4-6_sims" "xcode12.3-6_sims" "xcode12.2-6_sims" "xcode12.1-6_sims" "xcode12.0-6_sims" "xcode11.7-6_sims")
    deployment_targets=("14.5" "14.5" "14.4" "14.3" "14.2" "14.1" "14.0" "13.7")
    
    for i in {0..7};
    do
    echo $i
    curl https://app.bitrise.io/app/${BITRISE_APP_SLUG}/build/start.json --data "{\"hook_info\":{\"type\":\"bitrise\",\"build_trigger_token\":\"${BUILD_TRIGGER_TOKEN}\"},\"build_params\":{\"branch\":\"main\",\"workflow_id\":\"clone_test-gen2-${core_count}_core-${workflow_suffixes[i]}\", \"environments\": [{\"mapped_to\":\"DEPLOYMENT_TARGET\",\"value\":\"${deployment_targets[i]}\",\"is_expand\":true}]},\"triggered_by\":\"curl\"}"
    sleep 15
    done
done