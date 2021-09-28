DeviceKey_Back = 1
local DeviceKeyMgr = class("DeviceKeyMgr")
function DeviceKeyMgr:ctor()
end
function DeviceKeyMgr:dispatchAndroidKey()
  print("---------->> 安卓返回键 ")
  SendMessage(MsgID_Key_Back)
end
g_DeviceKeyMgr = DeviceKeyMgr.new()
