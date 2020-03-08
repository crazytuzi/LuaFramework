local SMultiOccupationRes = class("SMultiOccupationRes")
SMultiOccupationRes.TYPEID = 12606978
function SMultiOccupationRes:ctor(activated_occpations, activate_time, switch_time)
  self.id = 12606978
  self.activated_occpations = activated_occpations or {}
  self.activate_time = activate_time or nil
  self.switch_time = switch_time or nil
end
function SMultiOccupationRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.activated_occpations))
  for _, v in ipairs(self.activated_occpations) do
    os:marshalInt32(v)
  end
  os:marshalInt64(self.activate_time)
  os:marshalInt64(self.switch_time)
end
function SMultiOccupationRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.activated_occpations, v)
  end
  self.activate_time = os:unmarshalInt64()
  self.switch_time = os:unmarshalInt64()
end
function SMultiOccupationRes:sizepolicy(size)
  return size <= 65535
end
return SMultiOccupationRes
