local SCircleTaskNormalResult = class("SCircleTaskNormalResult")
SCircleTaskNormalResult.TYPEID = 12587610
SCircleTaskNormalResult.ADD_FACTION_CONTRIBUTION_TO_MAX = 1
function SCircleTaskNormalResult:ctor(result, args)
  self.id = 12587610
  self.result = result or nil
  self.args = args or {}
end
function SCircleTaskNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCircleTaskNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCircleTaskNormalResult:sizepolicy(size)
  return size <= 65535
end
return SCircleTaskNormalResult
