local CCardLotteryDrawFinishReq = class("CCardLotteryDrawFinishReq")
CCardLotteryDrawFinishReq.TYPEID = 12624418
function CCardLotteryDrawFinishReq:ctor()
  self.id = 12624418
end
function CCardLotteryDrawFinishReq:marshal(os)
end
function CCardLotteryDrawFinishReq:unmarshal(os)
end
function CCardLotteryDrawFinishReq:sizepolicy(size)
  return size <= 65535
end
return CCardLotteryDrawFinishReq
