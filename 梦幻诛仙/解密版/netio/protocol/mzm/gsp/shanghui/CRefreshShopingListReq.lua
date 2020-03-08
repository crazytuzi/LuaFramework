local CRefreshShopingListReq = class("CRefreshShopingListReq")
CRefreshShopingListReq.TYPEID = 12592642
function CRefreshShopingListReq:ctor(subType, index)
  self.id = 12592642
  self.subType = subType or nil
  self.index = index or nil
end
function CRefreshShopingListReq:marshal(os)
  os:marshalInt32(self.subType)
  os:marshalInt32(self.index)
end
function CRefreshShopingListReq:unmarshal(os)
  self.subType = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CRefreshShopingListReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshShopingListReq
