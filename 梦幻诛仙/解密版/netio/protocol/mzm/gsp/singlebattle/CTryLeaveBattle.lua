local CTryLeaveBattle = class("CTryLeaveBattle")
CTryLeaveBattle.TYPEID = 12621578
function CTryLeaveBattle:ctor()
  self.id = 12621578
end
function CTryLeaveBattle:marshal(os)
end
function CTryLeaveBattle:unmarshal(os)
end
function CTryLeaveBattle:sizepolicy(size)
  return size <= 65535
end
return CTryLeaveBattle
