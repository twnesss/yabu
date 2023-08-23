#!/system/bin/sh

(
    until [ "$(getprop init.svc.bootanim)" = "stopped" ]; do
        sleep 5
    done

    chmod 755 /data/adb/boxui/start.sh
    /data/adb/boxui/start.sh
) &
