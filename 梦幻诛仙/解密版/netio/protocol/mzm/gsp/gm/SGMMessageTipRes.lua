local SGMMessageTipRes = class("SGMMessageTipRes")
SGMMessageTipRes.TYPEID = 12585735
SGMMessageTipRes.ACTIVITY_ALREADY_IN_STAGE_0 = 1
SGMMessageTipRes.ACTIVITY_NOT_FINISH = 2
SGMMessageTipRes.ACTIVITY_STAGE_NOT_ALLOW = 3
SGMMessageTipRes.ACTIVITY_STAGE_NOW = 4
SGMMessageTipRes.ACTIVITY_ID_ERROR = 5
SGMMessageTipRes.CMD_MULTI_AWARD_ITEM_PARAM_WRONG = 11
SGMMessageTipRes.CMD_UNSTATUS_FAIL = 20
SGMMessageTipRes.ONLINE_NUM = 30
SGMMessageTipRes.CMD_GET_ACTIVITY_STATE = 40
SGMMessageTipRes.CMD_COMMON_TIPS = 2147483647
function SGMMessageTipRes:ctor(result, args)
  self.id = 12585735
  self.result = result or nil
  self.args = args or {}
end
function SGMMessageTipRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SGMMessageTipRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SGMMessageTipRes:sizepolicy(size)
  return size <= 65535
end
return SGMMessageTipRes
