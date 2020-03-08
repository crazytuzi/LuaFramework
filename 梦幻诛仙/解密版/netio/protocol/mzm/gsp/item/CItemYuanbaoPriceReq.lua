local CItemYuanbaoPriceReq = class("CItemYuanbaoPriceReq")
CItemYuanbaoPriceReq.TYPEID = 12584732
function CItemYuanbaoPriceReq:ctor(itemid)
  self.id = 12584732
  self.itemid = itemid or nil
end
function CItemYuanbaoPriceReq:marshal(os)
  os:marshalInt32(self.itemid)
end
function CItemYuanbaoPriceReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
end
function CItemYuanbaoPriceReq:sizepolicy(size)
  return size <= 65535
end
return CItemYuanbaoPriceReq
