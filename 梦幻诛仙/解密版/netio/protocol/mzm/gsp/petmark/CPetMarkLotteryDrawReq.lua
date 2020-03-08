local CPetMarkLotteryDrawReq = class("CPetMarkLotteryDrawReq")
CPetMarkLotteryDrawReq.TYPEID = 12628484
CPetMarkLotteryDrawReq.LOTTERY_TYPE1 = 1
CPetMarkLotteryDrawReq.LOTTERY_TYPE2 = 2
CPetMarkLotteryDrawReq.ONE_LOTTERY = 1
CPetMarkLotteryDrawReq.TEN_LOTTERY = 10
function CPetMarkLotteryDrawReq:ctor(lottery_type, lottery_num)
  self.id = 12628484
  self.lottery_type = lottery_type or nil
  self.lottery_num = lottery_num or nil
end
function CPetMarkLotteryDrawReq:marshal(os)
  os:marshalInt32(self.lottery_type)
  os:marshalInt32(self.lottery_num)
end
function CPetMarkLotteryDrawReq:unmarshal(os)
  self.lottery_type = os:unmarshalInt32()
  self.lottery_num = os:unmarshalInt32()
end
function CPetMarkLotteryDrawReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkLotteryDrawReq
