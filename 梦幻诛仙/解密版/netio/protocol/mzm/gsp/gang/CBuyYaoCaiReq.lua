local CBuyYaoCaiReq = class("CBuyYaoCaiReq")
CBuyYaoCaiReq.TYPEID = 12589916
function CBuyYaoCaiReq:ctor(itemId)
  self.id = 12589916
  self.itemId = itemId or nil
end
function CBuyYaoCaiReq:marshal(os)
  os:marshalInt32(self.itemId)
end
function CBuyYaoCaiReq:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function CBuyYaoCaiReq:sizepolicy(size)
  return size <= 65535
end
return CBuyYaoCaiReq
