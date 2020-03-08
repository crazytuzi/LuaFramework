local SFloorNormalResult = class("SFloorNormalResult")
SFloorNormalResult.TYPEID = 12617731
SFloorNormalResult.CHALLENGE_FLOOR_NOT_OPEN = 1
SFloorNormalResult.SWEEP_FLOOR_YUAN_BAO_ERROR = 2
function SFloorNormalResult:ctor(result, args)
  self.id = 12617731
  self.result = result or nil
  self.args = args or {}
end
function SFloorNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFloorNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFloorNormalResult:sizepolicy(size)
  return size <= 65535
end
return SFloorNormalResult
