local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SEquipMakeRes = class("SEquipMakeRes")
SEquipMakeRes.TYPEID = 12584749
function SEquipMakeRes:ctor(key, eqpInfo)
  self.id = 12584749
  self.key = key or nil
  self.eqpInfo = eqpInfo or ItemInfo.new()
end
function SEquipMakeRes:marshal(os)
  os:marshalInt32(self.key)
  self.eqpInfo:marshal(os)
end
function SEquipMakeRes:unmarshal(os)
  self.key = os:unmarshalInt32()
  self.eqpInfo = ItemInfo.new()
  self.eqpInfo:unmarshal(os)
end
function SEquipMakeRes:sizepolicy(size)
  return size <= 65535
end
return SEquipMakeRes
