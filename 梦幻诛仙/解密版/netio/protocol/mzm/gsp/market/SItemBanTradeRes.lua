local SItemBanTradeRes = class("SItemBanTradeRes")
SItemBanTradeRes.TYPEID = 12601455
function SItemBanTradeRes:ctor(itemid, state)
  self.id = 12601455
  self.itemid = itemid or nil
  self.state = state or nil
end
function SItemBanTradeRes:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.state)
end
function SItemBanTradeRes:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
function SItemBanTradeRes:sizepolicy(size)
  return size <= 65535
end
return SItemBanTradeRes
