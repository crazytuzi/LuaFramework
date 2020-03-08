local SBountyNormalResult = class("SBountyNormalResult")
SBountyNormalResult.TYPEID = 12584194
SBountyNormalResult.GET_BTASK__SUC = 1
SBountyNormalResult.GET_BTASK__ERROR_IN_TEAM = 2
SBountyNormalResult.GET_BTASK__ERROR_TO_LIMITE = 3
SBountyNormalResult.FLUSH_BTASK__REPEAT = 10
SBountyNormalResult.FLUSH_BTASK__MAX = 11
function SBountyNormalResult:ctor(result, args)
  self.id = 12584194
  self.result = result or nil
  self.args = args or {}
end
function SBountyNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SBountyNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SBountyNormalResult:sizepolicy(size)
  return size <= 65535
end
return SBountyNormalResult
