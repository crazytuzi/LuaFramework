local SEnterFightOperFighters = class("SEnterFightOperFighters")
SEnterFightOperFighters.TYPEID = 12594211
function SEnterFightOperFighters:ctor(fight_uuid, round, operUuids)
  self.id = 12594211
  self.fight_uuid = fight_uuid or nil
  self.round = round or nil
  self.operUuids = operUuids or {}
end
function SEnterFightOperFighters:marshal(os)
  os:marshalInt64(self.fight_uuid)
  os:marshalInt32(self.round)
  local _size_ = 0
  for _, _ in pairs(self.operUuids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.operUuids) do
    os:marshalInt32(k)
  end
end
function SEnterFightOperFighters:unmarshal(os)
  self.fight_uuid = os:unmarshalInt64()
  self.round = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.operUuids[v] = v
  end
end
function SEnterFightOperFighters:sizepolicy(size)
  return size <= 65535
end
return SEnterFightOperFighters
