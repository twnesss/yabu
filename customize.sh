#!/sbin/sh

# Declaring a variable to skip the default installation steps
SKIPUNZIP=1

install_module() {
    ui_print "Installing......"
    sleep 1

    ui_print "- Extracting module files"
    mkdir -p /data/adb/boxui/run

    unzip -o "${ZIPFILE}" -x 'META-INF/*' -d "${MODPATH}" >/dev/null 2>&1
    unzip -j -o "${ZIPFILE}" 'box_ui_service.sh' -d /data/adb/service.d >/dev/null 2>&1
    unzip -j -o "${ZIPFILE}" 'scripts/*' -d /data/adb/boxui >/dev/null 2>&1
    unzip -j -o "${ZIPFILE}" 'module.prop' -d "${MODPATH}" >/dev/null 2>&1
    unzip -j -o "${ZIPFILE}" 'service.sh' -d "${MODPATH}" >/dev/null 2>&1
    unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d "${MODPATH}" >/dev/null 2>&1
    unzip -o "${MODPATH}/boxui.zip" -d /data/adb/box >/dev/null 2>&1

    rm -rf "${MODPATH}/scripts"
    rm -rf "${MODPATH}/boxui.zip"
    rm -rf "${MODPATH}/box_ui_service.sh"

    sleep 1
    ui_print "- Setting module permissions"
    set_perm_recursive "${MODPATH}" 0 0 0755 0644
    set_perm_recursive /data/adb/boxui 0 0 0755 0644

    set_perm /data/adb/service.d/box_ui_service.sh 0 0 0755

    set_perm /data/adb/box/file.php 0 0 0755
    set_perm /data/adb/box/index.php 0 0 0755
    set_perm /data/adb/box/exec.php 0 0 0755

    set_perm /data/adb/boxui/boxui.service 0 0 0755
    set_perm /data/adb/boxui/boxui.inotify 0 0 0755
    set_perm /data/adb/boxui/start.sh 0 0 0755

    chmod ugo+x /data/adb/boxui/*
}

# check android
if [ "$API" -lt 28 ]; then
  ui_print "! Unsupported sdk: $API"
  abort "! Minimal supported sdk is 28 (Android 9)"
else
  ui_print "- Device sdk: $API"
fi

# check version
service_dir="/data/adb/service.d"
if [ "$KSU" = true ]; then
  ui_print "- kernelSU version: $KSU_VER ($KSU_VER_CODE)"
  [ "$KSU_VER_CODE" -lt 10683 ] && service_dir="/data/adb/ksu/service.d"
  busybox_path="/data/adb/magisk/busybox"
else
  ui_print "- Magisk version: $MAGISK_VER ($MAGISK_VER_CODE)"
  busybox_path="/data/adb/ksu/bin/busybox"
fi

if [ ! -f /data/data/com.termux/files/usr/bin/php ]; then
    ui_print "- install PHP"
    ui_print "- open Termux"
    ui_print "- pkg upgrade -y && pkg updates -y"
    ui_print "- pkg install php"
    abort "********************************"
fi

if [ ! -d /data/adb/box ]; then
    ui_print "- No folder /data/adb/box"
    ui_print "- Please install BFR first"
    abort "********************************"
else
    if [ ! -d "${service_dir}" ]; then
        mkdir -p "${service_dir}"
    fi
    for PID in $(${busybox_path} pidof inotifyd); do
      if grep -q boxui.inotify /proc/$PID/cmdline; then
        kill -15 $PID
      fi
    done
    sleep 1
    install_module
fi
