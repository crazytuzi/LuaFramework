local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SFabaoComposeSuccessRes = class("SFabaoComposeSuccessRes")
SFabaoComposeSuccessRes.TYPEID = 12596023
function SFabaoComposeSuccessRes:ctor(key, eqpInfo)
  self.id = 12596023
  self.key = key or nil
  self.eqpInfo = eqpInfo or ItemInfo.new()
end
function SFabaoComposeSuccessRes:marshal(os)
  os:marshalInt32(self.key)
  self.eqpInfo:marshal(os)
end
function SFabaoComposeSuccessRes:unmarshal(os)
  self.key = os:unmarshalInt32()
  self.eqpInfo = ItemInfo.new()
  self.eqpInfo:unmarshal(os)
end
function SFabaoComposeSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoComposeSuccessRes
