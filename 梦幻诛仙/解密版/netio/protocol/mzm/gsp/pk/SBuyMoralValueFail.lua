local SBuyMoralValueFail = class("SBuyMoralValueFail")
SBuyMoralValueFail.TYPEID = 12619777
SBuyMoralValueFail.MORAL_VALUE_FULL = 1
SBuyMoralValueFail.INSUFFICIENT_MONEY = 2
SBuyMoralValueFail.MONEY_NUM_NOT_MATCHED = 3
function SBuyMoralValueFail:ctor(retcode)
  self.id = 12619777
  self.retcode = retcode or nil
end
function SBuyMoralValueFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SBuyMoralValueFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SBuyMoralValueFail:sizepolicy(size)
  return size <= 65535
end
return SBuyMoralValueFail
