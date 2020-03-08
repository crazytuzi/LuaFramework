local SQingYuanNormalFail = class("SQingYuanNormalFail")
SQingYuanNormalFail.TYPEID = 12602887
SQingYuanNormalFail.MEMBER_QING_YUAN_SIZE_MAX = 1
SQingYuanNormalFail.NOT_HAS_THE_QING_YUAN = 2
SQingYuanNormalFail.TEAM_MEMBER_SIZE_ERROR = 3
SQingYuanNormalFail.ROLE_LEVEL_NOT_MATCH = 4
SQingYuanNormalFail.FRIEND_VALUE_NOT_MATCH = 5
SQingYuanNormalFail.ALEARDY_QING_YUAN_RELATION = 6
SQingYuanNormalFail.CAN_NOT_BE_MARRIAGE_RELATION = 7
SQingYuanNormalFail.TEAM_MEMBER_STATUS_NOT_RIGHT = 8
SQingYuanNormalFail.TEAM_MEMBER_STATUS_CHANGES = 9
function SQingYuanNormalFail:ctor(result, params)
  self.id = 12602887
  self.result = result or nil
  self.params = params or {}
end
function SQingYuanNormalFail:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SQingYuanNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SQingYuanNormalFail:sizepolicy(size)
  return size <= 65535
end
return SQingYuanNormalFail
