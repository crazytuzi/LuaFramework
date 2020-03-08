local CGoldRefreshShopingListReq = class("CGoldRefreshShopingListReq")
CGoldRefreshShopingListReq.TYPEID = 12584972
function CGoldRefreshShopingListReq:ctor(subtype, param)
  self.id = 12584972
  self.subtype = subtype or nil
  self.param = param or nil
end
function CGoldRefreshShopingListReq:marshal(os)
  os:marshalInt32(self.subtype)
  os:marshalInt32(self.param)
end
function CGoldRefreshShopingListReq:unmarshal(os)
  self.subtype = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
end
function CGoldRefreshShopingListReq:sizepolicy(size)
  return size <= 65535
end
return CGoldRefreshShopingListReq
