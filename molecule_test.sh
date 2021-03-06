#!/bin/bash
# Execute molecule testing for each role that contains molecule scenario

set -eo pipefail

if [[ ! -n "${TEST_HOST}" && ! -n "${TEST_SSH_KEY}" ]]; then
    echo "Some of the scenarious require the following env variables:"
    echo "TEST_HOST and TEST_SSH_KEY"
    echo "Set the env variables and rerun the test."
    echo "For explanation of the env variables, look for the openstack_task molecule role."
    exit 1
fi

runs=0
failed_runs=0
declare -a tested_roles
declare -a failed_roles

molecules="$(find roles/ -name molecule -type d)"
for molecule in $molecules; do
    pushd $(dirname $molecule)

    if ! molecule test; then
        failed_runs=$((failed_runs + 1))
        failed_roles+=($(dirname $molecule))
    fi
    runs=$((runs + 1))
    tested_roles+=($(dirname $molecule))
    popd
done

echo "Tests results:"
if [[ $failed_runs -ne 0 ]]; then
    echo -e "\nFailed $failed_runs/$runs molecule tests"
    echo -e "\nTested roles:"
    for role in "${tested_roles[@]}"; do
        echo "- $role"
    done
    echo -e "\nFailed molecule roles:"
    for role in "${failed_roles[@]}"; do
        echo "- $role"
    done
    exit 1
fi

echo -e "\nRan sucesfully $runs molecule tests"
echo -e "\nTested roles:"
for role in "${tested_roles[@]}"; do
    echo "- $role"
done
