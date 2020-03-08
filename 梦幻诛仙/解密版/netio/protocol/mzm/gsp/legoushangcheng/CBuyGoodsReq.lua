local CBuyGoodsReq = class("CBuyGoodsReq")
CBuyGoodsReq.TYPEID = 12621314
function CBuyGoodsReq:ctor(cfgId)
  self.id = 12621314
  self.cfgId = cfgId or nil
end
function CBuyGoodsReq:marshal(os)
  os:marshalInt32(self.cfgId)
end
function CBuyGoodsReq:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
end
function CBuyGoodsReq:sizepolicy(size)
  return size <= 65535
end
return CBuyGoodsReq
