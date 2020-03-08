local CUseExchangeItemReq = class("CUseExchangeItemReq")
CUseExchangeItemReq.TYPEID = 12618241
function CUseExchangeItemReq:ctor(item_key, use_all_items)
  self.id = 12618241
  self.item_key = item_key or nil
  self.use_all_items = use_all_items or nil
end
function CUseExchangeItemReq:marshal(os)
  os:marshalInt32(self.item_key)
  os:marshalInt32(self.use_all_items)
end
function CUseExchangeItemReq:unmarshal(os)
  self.item_key = os:unmarshalInt32()
  self.use_all_items = os:unmarshalInt32()
end
function CUseExchangeItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseExchangeItemReq
