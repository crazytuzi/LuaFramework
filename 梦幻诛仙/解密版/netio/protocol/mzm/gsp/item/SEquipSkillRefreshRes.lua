local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SEquipSkillRefreshRes = class("SEquipSkillRefreshRes")
SEquipSkillRefreshRes.TYPEID = 12584857
function SEquipSkillRefreshRes:ctor(iteminfo)
  self.id = 12584857
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SEquipSkillRefreshRes:marshal(os)
  self.iteminfo:marshal(os)
end
function SEquipSkillRefreshRes:unmarshal(os)
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SEquipSkillRefreshRes:sizepolicy(size)
  return size <= 65535
end
return SEquipSkillRefreshRes
