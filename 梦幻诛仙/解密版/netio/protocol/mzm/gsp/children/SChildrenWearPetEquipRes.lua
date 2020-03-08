local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SChildrenWearPetEquipRes = class("SChildrenWearPetEquipRes")
SChildrenWearPetEquipRes.TYPEID = 12609428
function SChildrenWearPetEquipRes:ctor(childrenid, itemInfo)
  self.id = 12609428
  self.childrenid = childrenid or nil
  self.itemInfo = itemInfo or ItemInfo.new()
end
function SChildrenWearPetEquipRes:marshal(os)
  os:marshalInt64(self.childrenid)
  self.itemInfo:marshal(os)
end
function SChildrenWearPetEquipRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemInfo = ItemInfo.new()
  self.itemInfo:unmarshal(os)
end
function SChildrenWearPetEquipRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenWearPetEquipRes
