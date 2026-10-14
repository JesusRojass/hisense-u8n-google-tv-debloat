#!/system/bin/sh
# DEVICE-SIDE. Sends the PS button (CEC "Root Menu") to the active HDMI source via the TV's HDMI control service.
# Must run as the shell user (adb, or Shizuku / Button Mapper's helper). Lives at /data/local/tmp/psbutton.sh on the TV.
# txn 16 = IHdmiControlService.sendKeyEvent(deviceType=0 TV, keyCode=3 KEYCODE_HOME -> CEC 0x09, isPressed)
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 1
sleep 0.1
/system/bin/service call hdmi_control 16 i32 0 i32 3 i32 0
