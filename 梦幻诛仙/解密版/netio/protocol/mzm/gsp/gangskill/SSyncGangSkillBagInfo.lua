local SSyncGangSkillBagInfo = class("SSyncGangSkillBagInfo")
SSyncGangSkillBagInfo.TYPEID = 12599299
function SSyncGangSkillBagInfo:ctor(skills)
  self.id = 12599299
  self.skills = skills or {}
end
function SSyncGangSkillBagInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skills))
  for _, v in ipairs(self.skills) do
    v:marshal(os)
  end
end
function SSyncGangSkillBagInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gangskill.GangSkillBagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.skills, v)
  end
end
function SSyncGangSkillBagInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncGangSkillBagInfo
