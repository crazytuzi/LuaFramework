local SNewGetSkill = class("SNewGetSkill")
SNewGetSkill.TYPEID = 12588043
function SNewGetSkill:ctor(partner2Skills)
  self.id = 12588043
  self.partner2Skills = partner2Skills or {}
end
function SNewGetSkill:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.partner2Skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.partner2Skills) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SNewGetSkill:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.partner.SkillList")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.partner2Skills[k] = v
  end
end
function SNewGetSkill:sizepolicy(size)
  return size <= 65535
end
return SNewGetSkill
