local SGetRelatedRolePlantTreeSpecialStateSuccess = class("SGetRelatedRolePlantTreeSpecialStateSuccess")
SGetRelatedRolePlantTreeSpecialStateSuccess.TYPEID = 12611606
function SGetRelatedRolePlantTreeSpecialStateSuccess:ctor(activity_cfg_id, special_states)
  self.id = 12611606
  self.activity_cfg_id = activity_cfg_id or nil
  self.special_states = special_states or {}
end
function SGetRelatedRolePlantTreeSpecialStateSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  local _size_ = 0
  for _, _ in pairs(self.special_states) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.special_states) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SGetRelatedRolePlantTreeSpecialStateSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.special_states[k] = v
  end
end
function SGetRelatedRolePlantTreeSpecialStateSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRelatedRolePlantTreeSpecialStateSuccess
