#!/bin/sh -l

set -eu

AUTIFY_BASE_URL="https://app.autify.com/api/v1"

main() {
    AUTIFY_PROJECT_ID="${1}"
    AUTIFY_TESTPLAN_ID="${2}"
    AUTIFY_PERSONAL_TOKEN="${3}"

    echo "[DEBUG] Running with project_id:${AUTIFY_PROJECT_ID}, testplan_id:${AUTIFY_TESTPLAN_ID}"

    scheduled_response=$(curl \
        -s \
        -H "Authorization: Bearer ${AUTIFY_PERSONAL_TOKEN}" \
        -X POST "${AUTIFY_BASE_URL}/schedules/${AUTIFY_TESTPLAN_ID}")
    
    echo "[DEBUG] Autify Schedule API response: $(echo $scheduled_response | jq)"

    result_id=$(echo $scheduled_response | jq ".data.id" -r)

    while :
    do
        fetch_result_response=$(curl \
            -s \
            -H "Authorization: Bearer ${AUTIFY_PERSONAL_TOKEN}" \
            -X GET "${AUTIFY_BASE_URL}/projects/${AUTIFY_PROJECT_ID}/results/${result_id}")
        
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