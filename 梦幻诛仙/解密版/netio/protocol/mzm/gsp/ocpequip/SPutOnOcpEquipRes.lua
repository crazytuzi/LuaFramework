local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SPutOnOcpEquipRes = class("SPutOnOcpEquipRes")
SPutOnOcpEquipRes.TYPEID = 12607750
function SPutOnOcpEquipRes:ctor(ocp, key, item)
  self.id = 12607750
  self.ocp = ocp or nil
  self.key = key or nil
  self.item = item or ItemInfo.new()
end
function SPutOnOcpEquipRes:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.key)
  self.item:marshal(os)
end
function SPutOnOcpEquipRes:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.item = ItemInfo.new()
  self.item:unmarshal(os)
end
function SPutOnOcpEquipRes:sizepolicy(size)
  return size <= 65535
end
return SPutOnOcpEquipRes
