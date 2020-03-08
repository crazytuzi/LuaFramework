local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local SModuleFunSwitchInfoChanged = class("SModuleFunSwitchInfoChanged")
SModuleFunSwitchInfoChanged.TYPEID = 12599043
function SModuleFunSwitchInfoChanged:ctor(info)
  self.id = 12599043
  self.info = info or ModuleFunSwitchInfo.new()
end
function SModuleFunSwitchInfoChanged:marshal(os)
  self.info:marshal(os)
end
function SModuleFunSwitchInfoChanged:unmarshal(os)
  self.info = ModuleFunSwitchInfo.new()
  self.info:unmarshal(os)
end
function SModuleFunSwitchInfoChanged:sizepolicy(size)
  return size <= 65535
end
return SModuleFunSwitchInfoChanged
