local SResetSkillRes = class("SResetSkillRes")
SResetSkillRes.TYPEID = 12596514
function SResetSkillRes:ctor(index, skillIndex, mainSkillId, index2subskillid)
  self.id = 12596514
  self.index = index or nil
  self.skillIndex = skillIndex or nil
  self.mainSkillId = mainSkillId or nil
  self.index2subskillid = index2subskillid or {}
end
function SResetSkillRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillIndex)
  os:marshalInt32(self.mainSkillId)
  local _size_ = 0
  for _, _ in pairs(self.index2subskillid) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.index2subskillid) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SResetSkillRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
  self.mainSkillId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.index2subskillid[k] = v
  end
end
function SResetSkillRes:sizepolicy(size)
  return size <= 65535
end
return SResetSkillRes
