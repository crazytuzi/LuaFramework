local CQueryShopingListReq = class("CQueryShopingListReq")
CQueryShopingListReq.TYPEID = 12584988
function CQueryShopingListReq:ctor(subtype, param)
  self.id = 12584988
  self.subtype = subtype or nil
  self.param = param or nil
end
function CQueryShopingListReq:marshal(os)
  os:marshalInt32(self.subtype)
  os:marshalInt32(self.param)
end
function CQueryShopingListReq:unmarshal(os)
  self.subtype = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
end
function CQueryShopingListReq:sizepolicy(size)
  return size <= 65535
end
return CQueryShopingListReq
