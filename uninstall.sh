#!/system/bin/sh

boxui_data_dir="/data/adb/boxui"

rm_data() {
    rm -rf ${boxui_data_dir}
    rm -rf /data/adb/service.d/box_ui_service.sh
}

rm_data
