local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SImproveSuperEquipmentStageSuccess = class("SImproveSuperEquipmentStageSuccess")
SImproveSuperEquipmentStageSuccess.TYPEID = 12618757
function SImproveSuperEquipmentStageSuccess:ctor(improved, item_info)
  self.id = 12618757
  self.improved = improved or nil
  self.item_info = item_info or ItemInfo.new()
end
function SImproveSuperEquipmentStageSuccess:marshal(os)
  os:marshalInt32(self.improved)
  self.item_info:marshal(os)
end
function SImproveSuperEquipmentStageSuccess:unmarshal(os)
  self.improved = os:unmarshalInt32()
  self.item_info = ItemInfo.new()
  self.item_info:unmarshal(os)
end
function SImproveSuperEquipmentStageSuccess:sizepolicy(size)
  return size <= 65535
end
return SImproveSuperEquipmentStageSuccess
