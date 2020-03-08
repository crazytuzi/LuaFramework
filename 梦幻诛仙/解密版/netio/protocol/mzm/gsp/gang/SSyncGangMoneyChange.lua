local SSyncGangMoneyChange = class("SSyncGangMoneyChange")
SSyncGangMoneyChange.TYPEID = 12589833
function SSyncGangMoneyChange:ctor(gangMoney)
  self.id = 12589833
  self.gangMoney = gangMoney or nil
end
function SSyncGangMoneyChange:marshal(os)
  os:marshalInt32(self.gangMoney)
end
function SSyncGangMoneyChange:unmarshal(os)
  self.gangMoney = os:unmarshalInt32()
end
function SSyncGangMoneyChange:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMoneyChange
