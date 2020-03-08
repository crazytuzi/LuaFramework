local SExchangeUseItemRes = class("SExchangeUseItemRes")
SExchangeUseItemRes.TYPEID = 12584765
function SExchangeUseItemRes:ctor(exchangecfgid, exchangecount, itemid, num)
  self.id = 12584765
  self.exchangecfgid = exchangecfgid or nil
  self.exchangecount = exchangecount or nil
  self.itemid = itemid or nil
  self.num = num or nil
end
function SExchangeUseItemRes:marshal(os)
  os:marshalInt32(self.exchangecfgid)
  os:marshalInt32(self.exchangecount)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.num)
end
function SExchangeUseItemRes:unmarshal(os)
  self.exchangecfgid = os:unmarshalInt32()
  self.exchangecount = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SExchangeUseItemRes:sizepolicy(size)
  return size <= 65535
end
return SExchangeUseItemRes
