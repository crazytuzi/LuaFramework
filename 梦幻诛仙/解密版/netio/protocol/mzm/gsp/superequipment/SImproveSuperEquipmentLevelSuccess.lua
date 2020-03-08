local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SImproveSuperEquipmentLevelSuccess = class("SImproveSuperEquipmentLevelSuccess")
SImproveSuperEquipmentLevelSuccess.TYPEID = 12618759
function SImproveSuperEquipmentLevelSuccess:ctor(improved, item_info)
  self.id = 12618759
  self.improved = improved or nil
  self.item_info = item_info or ItemInfo.new()
end
function SImproveSuperEquipmentLevelSuccess:marshal(os)
  os:marshalInt32(self.improved)
  self.item_info:marshal(os)
end
function SImproveSuperEquipmentLevelSuccess:unmarshal(os)
  self.improved = os:unmarshalInt32()
  self.item_info = ItemInfo.new()
  self.item_info:unmarshal(os)
end
function SImproveSuperEquipmentLevelSuccess:sizepolicy(size)
  return size <= 65535
end
return SImproveSuperEquipmentLevelSuccess
