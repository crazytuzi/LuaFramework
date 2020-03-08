local SSynPartnerSkills = class("SSynPartnerSkills")
SSynPartnerSkills.TYPEID = 12588053
function SSynPartnerSkills:ctor(partnerId, skills)
  self.id = 12588053
  self.partnerId = partnerId or nil
  self.skills = skills or {}
end
function SSynPartnerSkills:marshal(os)
  os:marshalInt32(self.partnerId)
  local _size_ = 0
  for _, _ in pairs(self.skills) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.skills) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynPartnerSkills:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skills[k] = v
  end
end
function SSynPartnerSkills:sizepolicy(size)
  return size <= 65535
end
return SSynPartnerSkills
