#!/bin/sh

EX_OK=0
EX_USAGE=64

SOCKET=/var/run/pen.ctl

do_cmd()
{
    penctl "${SOCKET}" "$@"
}

get_servers()
{
    do_cmd servers | cut -d' ' -f1 | tr '\n' ' ' | sed -Ee 's/ $//'
}

main()
{
    local current_servers
    current_servers=`get_servers`

    local server
    local index=0

    if [ -z "${current_servers}" ]; then
        for server in "$@"; do
            do_cmd server ${index} ${server} || exit $?

            index=$((index+1))
        done
    else
        local new_servers_length
        new_servers_length=$#

        while [ ${index} -lt ${new_servers_length} ]; do
            echo "$1 added"

            do_cmd server ${index} $1 || exit $?

            shift

            index=$((index+1))
        done

        local current_servers_length
        current_servers_length=`echo "${current_servers}" | wc -w`

        while [ ${index} -lt ${current_servers_length} ]; do
            do_cmd server ${index} address 0.0.0.0 || exit $?

            index=$((index+1))
        done
    fi

    exit ${EX_OK}
}

usage()
{
    echo "usage: update-servers.sh [<new-server> ...]"
}

main "$@"
