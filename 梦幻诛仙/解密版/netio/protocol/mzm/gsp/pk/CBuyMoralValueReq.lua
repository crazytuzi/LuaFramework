local CBuyMoralValueReq = class("CBuyMoralValueReq")
CBuyMoralValueReq.TYPEID = 12619784
function CBuyMoralValueReq:ctor(quantity, money_num)
  self.id = 12619784
  self.quantity = quantity or nil
  self.money_num = money_num or nil
end
function CBuyMoralValueReq:marshal(os)
  os:marshalInt32(self.quantity)
  os:marshalInt64(self.money_num)
end
function CBuyMoralValueReq:unmarshal(os)
  self.quantity = os:unmarshalInt32()
  self.money_num = os:unmarshalInt64()
end
function CBuyMoralValueReq:sizepolicy(size)
  return size <= 65535
end
return CBuyMoralValueReq
