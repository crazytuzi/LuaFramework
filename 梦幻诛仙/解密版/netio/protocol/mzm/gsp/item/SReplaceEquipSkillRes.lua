local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SReplaceEquipSkillRes = class("SReplaceEquipSkillRes")
SReplaceEquipSkillRes.TYPEID = 12584858
function SReplaceEquipSkillRes:ctor(iteminfo)
  self.id = 12584858
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SReplaceEquipSkillRes:marshal(os)
  self.iteminfo:marshal(os)
end
function SReplaceEquipSkillRes:unmarshal(os)
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SReplaceEquipSkillRes:sizepolicy(size)
  return size <= 65535
end
return SReplaceEquipSkillRes
