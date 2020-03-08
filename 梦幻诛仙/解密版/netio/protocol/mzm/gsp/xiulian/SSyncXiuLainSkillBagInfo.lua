local SSyncXiuLainSkillBagInfo = class("SSyncXiuLainSkillBagInfo")
SSyncXiuLainSkillBagInfo.TYPEID = 12589569
function SSyncXiuLainSkillBagInfo:ctor(skillBagList, defaultSkill)
  self.id = 12589569
  self.skillBagList = skillBagList or {}
  self.defaultSkill = defaultSkill or nil
end
function SSyncXiuLainSkillBagInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillBagList))
  for _, v in ipairs(self.skillBagList) do
    v:marshal(os)
  end
  os:marshalInt32(self.defaultSkill)
end
function SSyncXiuLainSkillBagInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.xiulian.SkillBagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.skillBagList, v)
  end
  self.defaultSkill = os:unmarshalInt32()
end
function SSyncXiuLainSkillBagInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncXiuLainSkillBagInfo
