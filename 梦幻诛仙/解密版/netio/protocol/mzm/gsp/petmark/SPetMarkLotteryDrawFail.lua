local SPetMarkLotteryDrawFail = class("SPetMarkLotteryDrawFail")
SPetMarkLotteryDrawFail.TYPEID = 12628494
SPetMarkLotteryDrawFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkLotteryDrawFail.INVALID_TYPE = -2
SPetMarkLotteryDrawFail.SCORE_NOT_ENOUGH = -3
SPetMarkLotteryDrawFail.GRID_NOT_ENOUGH = -4
SPetMarkLotteryDrawFail.LAST_AWARD_NOT_RECEIVED = -5
function SPetMarkLotteryDrawFail:ctor(error_code)
  self.id = 12628494
  self.error_code = error_code or nil
end
function SPetMarkLotteryDrawFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkLotteryDrawFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkLotteryDrawFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkLotteryDrawFail
