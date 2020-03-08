local CExchangeItemUseJifen = class("CExchangeItemUseJifen")
CExchangeItemUseJifen.TYPEID = 12585483
function CExchangeItemUseJifen:ctor(jifentype, itemid, count)
  self.id = 12585483
  self.jifentype = jifentype or nil
  self.itemid = itemid or nil
  self.count = count or nil
end
function CExchangeItemUseJifen:marshal(os)
  os:marshalInt32(self.jifentype)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
end
function CExchangeItemUseJifen:unmarshal(os)
  self.jifentype = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function CExchangeItemUseJifen:sizepolicy(size)
  return size <= 65535
end
return CExchangeItemUseJifen
