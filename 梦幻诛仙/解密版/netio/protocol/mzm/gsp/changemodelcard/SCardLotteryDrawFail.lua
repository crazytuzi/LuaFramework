local SCardLotteryDrawFail = class("SCardLotteryDrawFail")
SCardLotteryDrawFail.TYPEID = 12624389
SCardLotteryDrawFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCardLotteryDrawFail.INVALID_TYPE = -2
SCardLotteryDrawFail.SCORE_NOT_ENOUGH = -3
SCardLotteryDrawFail.GRID_NOT_ENOUGH = -4
SCardLotteryDrawFail.LAST_AWARD_NOT_RECEIVED = -5
function SCardLotteryDrawFail:ctor(error_code)
  self.id = 12624389
  self.error_code = error_code or nil
end
function SCardLotteryDrawFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCardLotteryDrawFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCardLotteryDrawFail:sizepolicy(size)
  return size <= 65535
end
return SCardLotteryDrawFail
