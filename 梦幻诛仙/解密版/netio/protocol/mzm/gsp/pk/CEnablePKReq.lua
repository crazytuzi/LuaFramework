local CEnablePKReq = class("CEnablePKReq")
CEnablePKReq.TYPEID = 12619785
function CEnablePKReq:ctor(money_num)
  self.id = 12619785
  self.money_num = money_num or nil
end
function CEnablePKReq:marshal(os)
  os:marshalInt64(self.money_num)
end
function CEnablePKReq:unmarshal(os)
  self.money_num = os:unmarshalInt64()
end
function CEnablePKReq:sizepolicy(size)
  return size <= 65535
end
return CEnablePKReq
