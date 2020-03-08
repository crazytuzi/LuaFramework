local CGetMoneyReq = class("CGetMoneyReq")
CGetMoneyReq.TYPEID = 12584963
function CGetMoneyReq:ctor(shoppingid, itemid)
  self.id = 12584963
  self.shoppingid = shoppingid or nil
  self.itemid = itemid or nil
end
function CGetMoneyReq:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.itemid)
end
function CGetMoneyReq:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
end
function CGetMoneyReq:sizepolicy(size)
  return size <= 65535
end
return CGetMoneyReq
