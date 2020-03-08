local SMarriageNormalResult = class("SMarriageNormalResult")
SMarriageNormalResult.TYPEID = 12599816
SMarriageNormalResult.MARRY_REQ_NOT_SINGLE = 0
SMarriageNormalResult.MARRY_REQ_SOMEONE_IN_CEREMONY = 1
SMarriageNormalResult.AGREE_OR_CANCEL_MARRIAGE_ITEM_NOT_ENOUGH = 20
SMarriageNormalResult.AGREE_OR_CANCEL_MARRIAGE_MONEY_NOT_ENOUGH = 21
SMarriageNormalResult.AGREE_OR_CANCEL_MARRIAGE_SOMEONE_IN_CEREMONY = 22
SMarriageNormalResult.DIVORCE_REQUST_SILVER_NOT_ENOUGH = 40
SMarriageNormalResult.SEND_FRIEND_GIFT_FRIEND_NOT_MARRY = 60
SMarriageNormalResult.SEND_FRIEND_GIFT_FRIEND_MARRY_TIME_TOO_LONG = 61
SMarriageNormalResult.SEND_FRIEND_GIFT_FRIEND_ALREADY_SEND = 62
SMarriageNormalResult.TRANSFOR_MARRIAGE_MARRY_TIME_TOO_LONG = 80
SMarriageNormalResult.TRANSFOR_MARRIAGE_NOT_IN_BIG_WORLD = 81
SMarriageNormalResult.FORCE_DIVORCE_SOMEONE_ALREADY_DO_THIS = 100
SMarriageNormalResult.MARRIAGE_PARADE_NOT_NORMAL_STATE = 120
SMarriageNormalResult.MARRIAGE_PARADE_SOMEONE_IN_PARADE = 121
function SMarriageNormalResult:ctor(result, args)
  self.id = 12599816
  self.result = result or nil
  self.args = args or {}
end
function SMarriageNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SMarriageNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SMarriageNormalResult:sizepolicy(size)
  return size <= 65535
end
return SMarriageNormalResult
