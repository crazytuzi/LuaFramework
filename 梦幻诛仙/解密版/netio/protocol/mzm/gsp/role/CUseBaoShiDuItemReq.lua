local CUseBaoShiDuItemReq = class("CUseBaoShiDuItemReq")
CUseBaoShiDuItemReq.TYPEID = 12586016
function CUseBaoShiDuItemReq:ctor(itemKey)
  self.id = 12586016
  self.itemKey = itemKey or nil
end
function CUseBaoShiDuItemReq:marshal(os)
  os:marshalInt32(self.itemKey)
end
function CUseBaoShiDuItemReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
end
function CUseBaoShiDuItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseBaoShiDuItemReq
