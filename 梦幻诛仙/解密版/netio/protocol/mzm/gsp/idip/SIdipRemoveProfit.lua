local SIdipRemoveProfit = class("SIdipRemoveProfit")
SIdipRemoveProfit.TYPEID = 12601093
function SIdipRemoveProfit:ctor()
  self.id = 12601093
end
function SIdipRemoveProfit:marshal(os)
end
function SIdipRemoveProfit:unmarshal(os)
end
function SIdipRemoveProfit:sizepolicy(size)
  return size <= 65535
end
return SIdipRemoveProfit
