#!/system/bin/sh

moddir="/data/adb/modules/boxui"
if [ -n "$(magisk -v | grep lite)" ]; then
  moddir="/data/adb/lite_modules/boxui"
fi

scripts_dir="/data/adb/boxui"
busybox_path="/data/adb/magisk/busybox"
boxui_run_path="/data/adb/boxui/run"
boxui_pid_file="${boxui_run_path}/boxui.pid"

busybox_path="/data/adb/magisk/busybox"
if ! command -v "${busybox_path}" >/dev/null 2>&1; then
  busybox_path="/data/adb/ksu/bin/busybox"
fi

start_service() {
    ${scripts_dir}/boxui.service start
}

start_boxui() {
    if [ -f "${boxui_pid_file}" ]; then
        ${scripts_dir}/boxui.service stop
    fi
}

start_run() {
  for PID in $(${busybox_path} pidof inotifyd) ; do
    if grep -q boxui.inotify /proc/$PID/cmdline ; then
      kill -15 $PID
    fi
  done
  sleep 1
  if [ ! -f "${moddir}/disable" ]; then
      start_service
  fi
  if [ "$?" = 0 ]; then
      inotifyd ${scripts_dir}/boxui.inotify ${moddir} > /dev/null 2>&1 &
  fi
}

start_boxui
start_run
