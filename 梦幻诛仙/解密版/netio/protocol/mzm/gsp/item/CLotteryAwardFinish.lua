local CLotteryAwardFinish = class("CLotteryAwardFinish")
CLotteryAwardFinish.TYPEID = 12584802
function CLotteryAwardFinish:ctor()
  self.id = 12584802
end
function CLotteryAwardFinish:marshal(os)
end
function CLotteryAwardFinish:unmarshal(os)
end
function CLotteryAwardFinish:sizepolicy(size)
  return size <= 65535
end
return CLotteryAwardFinish
