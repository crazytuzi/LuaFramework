local CFlopLotteryExit = class("CFlopLotteryExit")
CFlopLotteryExit.TYPEID = 12618501
function CFlopLotteryExit:ctor(uid)
  self.id = 12618501
  self.uid = uid or nil
end
function CFlopLotteryExit:marshal(os)
  os:marshalInt64(self.uid)
end
function CFlopLotteryExit:unmarshal(os)
  self.uid = os:unmarshalInt64()
end
function CFlopLotteryExit:sizepolicy(size)
  return size <= 65535
end
return CFlopLotteryExit
