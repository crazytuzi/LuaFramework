local SSyncLifeSkillBagInfo = class("SSyncLifeSkillBagInfo")
SSyncLifeSkillBagInfo.TYPEID = 12589065
function SSyncLifeSkillBagInfo:ctor(skillBagList)
  self.id = 12589065
  self.skillBagList = skillBagList or {}
end
function SSyncLifeSkillBagInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillBagList))
  for _, v in ipairs(self.skillBagList) do
    v:marshal(os)
  end
end
function SSyncLifeSkillBagInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.lifeskill.SkillBagInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.skillBagList, v)
  end
end
function SSyncLifeSkillBagInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncLifeSkillBagInfo
