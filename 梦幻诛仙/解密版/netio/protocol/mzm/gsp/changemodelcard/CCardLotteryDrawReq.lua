local CCardLotteryDrawReq = class("CCardLotteryDrawReq")
CCardLotteryDrawReq.TYPEID = 12624392
CCardLotteryDrawReq.ONE_LOTTERY = 1
CCardLotteryDrawReq.TEN_LOTTERY = 10
function CCardLotteryDrawReq:ctor(lottery_type)
  self.id = 12624392
  self.lottery_type = lottery_type or nil
end
function CCardLotteryDrawReq:marshal(os)
  os:marshalInt32(self.lottery_type)
end
function CCardLotteryDrawReq:unmarshal(os)
  self.lottery_type = os:unmarshalInt32()
end
function CCardLotteryDrawReq:sizepolicy(size)
  return size <= 65535
end
return CCardLotteryDrawReq
