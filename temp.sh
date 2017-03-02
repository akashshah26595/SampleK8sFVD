#!/bin/bash

# Notes:
#  - Please install "jq" package before using this driver.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#JQ="$DIR/jq"
echo "Value of $JQ"
#MOUNT_CIFS="$DIR/mount.cifs"

usage() {
	err "Invalid usage. Usage: "
	err "\t$0 init"
	err "\t$0 attach <json params>"
	err "\t$0 detach <mount device>"
	# err "\t$0 mount <mount dir> <mount device> <json params>"
    err "\t$0 mount <json params>"
	err "\t$0 unmount <mount dir>"
	exit 1
}

err() {
	echo -e $* 1>&2
}

log() {
	echo -e $* >&1
}

ismounted() {
	MOUNT=`findmnt -n ${MNTPATH} 2>/dev/null | cut -d' ' -f1`
	[ "${MOUNT}" == "${MNTPATH}" ]
}

attach() {
	log '{"status": "Success", "device": "/dev/null"}'
	exit 0
}

detach() {
	log '{"status": "Success"}'
	exit 0
}

domount() {
    echo "Value of $JQ in domount method"
	#DMDEV="$2"
    MNTPATH=$(cat "$1"|jq -r '.spec.containers.mountPath')
	VOLUME_SRC=$(cat "$1"|jq -r '.spec.volumes.flexVolume.options.source')
    #READ_MODE=$(echo "$3"|"$JQ" -r '.["kubernetes.io/readwrite"]')
    MOUNT_OPTIONS=$(cat "$1"|jq -r '.spec.volumes.flexVolume.options.mountOptions')
        
        #USERNAME=$(echo "$3"|"$JQ" -r '.["kubernetes.io/secret/username"] // empty'|base64 -d)
        #PASSWORD=$(echo "$3"|"$JQ" -r '.["kubernetes.io/secret/password"] // empty'|base64 -d)

        #ALL_OPTIONS="user=${USERNAME},pass=${PASSWORD},${READ_MODE}"
    #ALL_OPTIONS="${READ_MODE}"

        if [ -n "$MOUNT_OPTIONS" ]; then
            #ALL_OPTIONS="${ALL_OPTIONS},${MOUNT_OPTIONS}"
            ALL_OPTIONS="${MOUNT_OPTIONS}"
        fi
        
        if ismounted ; then
                log '{"status": "Success"}'
                exit 0
        fi

        sudo mkdir -p ${MNTPATH} &> /dev/null
        sudo mkdir -p ${VOLUME_SRC} &> /dev/null
        
        #"$MOUNT_CIFS" -o "${ALL_OPTIONS}" "${VOLUME_SRC}" "${MNTPATH}" &> /dev/null
        #mount -o rw,noexec,nosuid,nodev,bind /tmp /var/tmp

        sudo mount -o rw,noexec,nosuid,nodev,bind "${VOLUME_SRC}" "${MNTPATH}" &> /dev/null

        if [ $? -ne 0 ]; then
                2>&1
                err '{ "status": "Failure", "message": "Failed to mount device '${VOLUME_SRC}' at '${MNTPATH}' , volume_src: '${VOLUME_SRC}'"}'
                exit 1
        fi
        log '{"status": "Success"}'

        exit 0
}

unmount() {
        MNTPATH="$1"
        if ! ismounted ; then
                log '{"status": "Success"}'
                exit 0
        fi

        sudo umount "${MNTPATH}" &> /dev/null
        if [ $? -ne 0 ]; then
                err '{ "status": "Failed", "message": "Failed to unmount volume at '${MNTPATH}'"}'
                exit 1
        fi
        rmdir "${MNTPATH}" &> /dev/null

        log '{"status": "Success"}'
        exit 0
}

op=$1

if [ "$op" = "init" ]; then
        log '{"status": "Success"}'
        exit 0
fi

if [ $# -lt 2 ]; then
        usage
fi

shift

case "$op" in
        attach)
                attach $*
                ;;
        detach)
                detach $*
                ;;
        mount)
                domount $*
                ;;
	unmount)
		unmount $*
		;;
	*)
		usage
esac

exit 1