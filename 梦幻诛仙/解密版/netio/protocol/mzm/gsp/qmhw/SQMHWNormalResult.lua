local SQMHWNormalResult = class("SQMHWNormalResult")
SQMHWNormalResult.TYPEID = 12601860
SQMHWNormalResult.JOIN_QMHW_STATUS_WRONG = 1
function SQMHWNormalResult:ctor(result, args)
  self.id = 12601860
  self.result = result or nil
  self.args = args or {}
end
function SQMHWNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SQMHWNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SQMHWNormalResult:sizepolicy(size)
  return size <= 65535
end
return SQMHWNormalResult
