local CFreeRefreshShopingListReq = class("CFreeRefreshShopingListReq")
CFreeRefreshShopingListReq.TYPEID = 12584970
function CFreeRefreshShopingListReq:ctor(subtype, param)
  self.id = 12584970
  self.subtype = subtype or nil
  self.param = param or nil
end
function CFreeRefreshShopingListReq:marshal(os)
  os:marshalInt32(self.subtype)
  os:marshalInt32(self.param)
end
function CFreeRefreshShopingListReq:unmarshal(os)
  self.subtype = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
end
function CFreeRefreshShopingListReq:sizepolicy(size)
  return size <= 65535
end
return CFreeRefreshShopingListReq
