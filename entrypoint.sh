#!/bin/sh -l

set -eu

AUTIFY_BASE_URL="https://app.autify.com/api/v1"

main() {
    project_id="${1}"
    testplan_id="${2}"

    echo "[DEBUG] Running with project_id:${project_id}, testplan_id:${testplan_id}"

    scheduled_response=$(curl \
        -s \
        --fail \
        -H "Authorization: Bearer ${AUTIFY_PERSONAL_TOKEN}" \
        -X POST "${AUTIFY_BASE_URL}/schedules/${testplan_id}")
    
    echo "[DEBUG] Autify Schedule API response: $(echo $scheduled_response | jq)"

    result_id=$(echo $scheduled_response | jq ".data.id" -r)

    while :
    do
        fetch_result_response=$(curl \
            -s \
            --fail \
            -H "Authorization: Bearer ${AUTIFY_PERSONAL_TOKEN}" \
            -X GET "${AUTIFY_BASE_URL}/projects/${project_id}/results/${result_id}")
        
        echo "[DEBUG] Autify Result API response: $(echo $fetch_result_response | jq)"

        current_status=$(echo $fetch_result_response | jq ".status" -r)

        # waiting, running, queuing : retry after 60sec
        if [ ${current_status} = "waiting" ]; then
            echo "[DEBUG] Current status is ${current_status} . retry after 60sec."
            sleep 60
        fi

        if [ ${current_status} = "running" ]; then
            echo "[DEBUG] Current status is ${current_status} . retry after 60sec."
            sleep 60
        fi

        if [ ${current_status} = "queuing" ]; then
            echo "[DEBUG] Current status is ${current_status} . retry after 60sec."
            sleep 60
        fi

        # passed : CI passed
        if [ ${current_status} = "passed" ]; then
            echo "[DEBUG] Current status is ${current_status} . CI passed."
            return 0
        fi

        # failed, skipped : CI failed
        if [ ${current_status} = "skipped" ]; then
            echo "[DEBUG] Current status is ${current_status} . CI failed."
            return 1
        fi
        if [ ${current_status} = "failed" ]; then
            echo "[DEBUG] Current status is ${current_status} . CI failed."
            return 2
        fi
    done
    return 2
}

main "$@"