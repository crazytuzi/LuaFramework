local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
local SItemSwitchChanged = class("SItemSwitchChanged")
SItemSwitchChanged.TYPEID = 12601106
function SItemSwitchChanged:ctor(info)
  self.id = 12601106
  self.info = info or ItemSwitchInfo.new()
end
function SItemSwitchChanged:marshal(os)
  self.info:marshal(os)
end
function SItemSwitchChanged:unmarshal(os)
  self.info = ItemSwitchInfo.new()
  self.info:unmarshal(os)
end
function SItemSwitchChanged:sizepolicy(size)
  return size <= 65535
end
return SItemSwitchChanged
