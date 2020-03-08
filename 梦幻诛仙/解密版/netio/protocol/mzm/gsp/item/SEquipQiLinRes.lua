local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SEquipQiLinRes = class("SEquipQiLinRes")
SEquipQiLinRes.TYPEID = 12584747
function SEquipQiLinRes:ctor(isSuccess, strengthLevel, iteminfo)
  self.id = 12584747
  self.isSuccess = isSuccess or nil
  self.strengthLevel = strengthLevel or nil
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SEquipQiLinRes:marshal(os)
  os:marshalUInt8(self.isSuccess)
  os:marshalInt32(self.strengthLevel)
  self.iteminfo:marshal(os)
end
function SEquipQiLinRes:unmarshal(os)
  self.isSuccess = os:unmarshalUInt8()
  self.strengthLevel = os:unmarshalInt32()
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SEquipQiLinRes:sizepolicy(size)
  return size <= 65535
end
return SEquipQiLinRes
