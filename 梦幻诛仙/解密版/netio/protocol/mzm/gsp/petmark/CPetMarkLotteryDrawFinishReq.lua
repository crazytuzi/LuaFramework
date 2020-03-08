local CPetMarkLotteryDrawFinishReq = class("CPetMarkLotteryDrawFinishReq")
CPetMarkLotteryDrawFinishReq.TYPEID = 12628490
function CPetMarkLotteryDrawFinishReq:ctor()
  self.id = 12628490
end
function CPetMarkLotteryDrawFinishReq:marshal(os)
end
function CPetMarkLotteryDrawFinishReq:unmarshal(os)
end
function CPetMarkLotteryDrawFinishReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkLotteryDrawFinishReq
