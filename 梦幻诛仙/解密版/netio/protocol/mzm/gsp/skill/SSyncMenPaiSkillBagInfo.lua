local SSyncMenPaiSkillBagInfo = class("SSyncMenPaiSkillBagInfo")
SSyncMenPaiSkillBagInfo.TYPEID = 12591626
function SSyncMenPaiSkillBagInfo:ctor(skillBags)
  self.id = 12591626
  self.skillBags = skillBags or {}
end
function SSyncMenPaiSkillBagInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillBags))
  for _, v in ipairs(self.skillBags) do
    v:marshal(os)
  end
end
function SSyncMenPaiSkillBagInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.skill.MenPaiSkillBagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.skillBags, v)
  end
end
function SSyncMenPaiSkillBagInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncMenPaiSkillBagInfo
