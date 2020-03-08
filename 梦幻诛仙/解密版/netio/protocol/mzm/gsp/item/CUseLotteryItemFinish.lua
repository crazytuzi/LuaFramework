local CUseLotteryItemFinish = class("CUseLotteryItemFinish")
CUseLotteryItemFinish.TYPEID = 12584801
function CUseLotteryItemFinish:ctor()
  self.id = 12584801
end
function CUseLotteryItemFinish:marshal(os)
end
function CUseLotteryItemFinish:unmarshal(os)
end
function CUseLotteryItemFinish:sizepolicy(size)
  return size <= 65535
end
return CUseLotteryItemFinish
