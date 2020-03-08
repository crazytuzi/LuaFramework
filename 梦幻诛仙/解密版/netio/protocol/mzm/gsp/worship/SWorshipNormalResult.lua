local SWorshipNormalResult = class("SWorshipNormalResult")
SWorshipNormalResult.TYPEID = 12612617
SWorshipNormalResult.WORSHIP_ERR__COUNT_EXHAUSTED = 1
function SWorshipNormalResult:ctor(result, args)
  self.id = 12612617
  self.result = result or nil
  self.args = args or {}
end
function SWorshipNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SWorshipNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SWorshipNormalResult:sizepolicy(size)
  return size <= 65535
end
return SWorshipNormalResult
