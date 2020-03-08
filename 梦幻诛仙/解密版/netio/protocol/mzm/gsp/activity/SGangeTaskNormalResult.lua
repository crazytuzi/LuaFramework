local SGangeTaskNormalResult = class("SGangeTaskNormalResult")
SGangeTaskNormalResult.TYPEID = 12587571
SGangeTaskNormalResult.JOIN_ACTIVITY_ERROR__NO_FACTION = 1
SGangeTaskNormalResult.JOIN_ACTIVITY_ERROR__DONE = 2
SGangeTaskNormalResult.JOIN_ACTIVITY_ERROR__NOT_NEAR_NPC = 3
function SGangeTaskNormalResult:ctor(result, args)
  self.id = 12587571
  self.result = result or nil
  self.args = args or {}
end
function SGangeTaskNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SGangeTaskNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SGangeTaskNormalResult:sizepolicy(size)
  return size <= 65535
end
return SGangeTaskNormalResult
