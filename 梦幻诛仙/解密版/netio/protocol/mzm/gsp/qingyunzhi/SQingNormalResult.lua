local SQingNormalResult = class("SQingNormalResult")
SQingNormalResult.TYPEID = 12590340
SQingNormalResult.CAN_NOT_CHALLANGE__LOCK = 1
SQingNormalResult.CAN_NOT_CHALLANGE__MEMBER_LOCK = 2
SQingNormalResult.CAN_NOT_CHALLANGE__NOT_LEADER = 3
SQingNormalResult.CAN_NOT_CHALLANGE__NOT_TEAM = 4
function SQingNormalResult:ctor(result, args)
  self.id = 12590340
  self.result = result or nil
  self.args = args or {}
end
function SQingNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SQingNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SQingNormalResult:sizepolicy(size)
  return size <= 65535
end
return SQingNormalResult
