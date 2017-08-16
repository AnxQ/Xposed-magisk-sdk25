#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
XPOSEDPATH=$MODDIR
DISABLEPATH=/data/data/de.robv.android.xposed.installer/conf/disabled

log_xposed() {
  echo $1
  log -p i -t Xposed "Mount: $1"
}

bind_mount() {
  if [ -f "$XPOSEDPATH$1" ]; then
    mount -o bind $XPOSEDPATH/$1 $1
    if [ "$?" -eq "0" ]; then log_xposed "$XPOSEDPATH$1 -> $1";
    else log_xposed "$1 bind mount failed!"; exit 1; fi
  fi
}

bind_mount_app_process() {
  if [ ! -f "$DISABLEPATH" ]; then
    if [ -f "$XPOSEDPATH$1_xposed" ]; then
      mount -o bind $XPOSEDPATH$1_xposed $1
      if [ "$?" -eq "0" ]; then log_xposed "$XPOSEDPATH$1_xposed -> $1";
      else log_xposed "$1 bind mount failed!"; exit 1; fi
    fi
  fi
}
# Make sure things got correct SELinux contexts
chcon u:object_r:zygote_exec:s0 $XPOSEDPATH/system/bin/app_process32_xposed
chcon u:object_r:zygote_exec:s0 $XPOSEDPATH/system/bin/app_process64_xposed
chcon u:object_r:dex2oat_exec:s0 $XPOSEDPATH/system/bin/dex2oat
chcon u:object_r:dex2oat_exec:s0 $XPOSEDPATH/system/bin/patchoat

# Bind mount start

log_xposed "Bind mount start"

bind_mount_app_process /system/bin/app_process32
bind_mount_app_process /system/bin/app_process64
umount /system/bin/app_process32_xposed
umount /system/bin/app_process32_xposed
bind_mount /system/bin/dex2oat
bind_mount /system/bin/oatdump
bind_mount /system/bin/patchoat
bind_mount /system/lib/libart.so
bind_mount /system/lib/libart-compiler.so
bind_mount /system/lib/libsigchain.so
bind_mount /system/lib64/libart.so
bind_mount /system/lib64/libart-disassembler.so
bind_mount /system/lib64/libsigchain.so

