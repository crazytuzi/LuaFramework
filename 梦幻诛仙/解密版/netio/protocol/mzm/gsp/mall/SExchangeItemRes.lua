local SExchangeItemRes = class("SExchangeItemRes")
SExchangeItemRes.TYPEID = 12585479
function SExchangeItemRes:ctor(jifentype, itemid, num)
  self.id = 12585479
  self.jifentype = jifentype or nil
  self.itemid = itemid or nil
  self.num = num or nil
end
function SExchangeItemRes:marshal(os)
  os:marshalInt32(self.jifentype)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.num)
end
function SExchangeItemRes:unmarshal(os)
  self.jifentype = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SExchangeItemRes:sizepolicy(size)
  return size <= 65535
end
return SExchangeItemRes
