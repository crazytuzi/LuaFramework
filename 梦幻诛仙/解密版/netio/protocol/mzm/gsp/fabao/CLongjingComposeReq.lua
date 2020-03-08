local CLongjingComposeReq = class("CLongjingComposeReq")
CLongjingComposeReq.TYPEID = 12596032
function CLongjingComposeReq:ctor(itemid)
  self.id = 12596032
  self.itemid = itemid or nil
end
function CLongjingComposeReq:marshal(os)
  os:marshalInt32(self.itemid)
end
function CLongjingComposeReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
end
function CLongjingComposeReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingComposeReq
