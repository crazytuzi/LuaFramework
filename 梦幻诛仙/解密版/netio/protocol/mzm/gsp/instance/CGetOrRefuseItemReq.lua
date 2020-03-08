local CGetOrRefuseItemReq = class("CGetOrRefuseItemReq")
CGetOrRefuseItemReq.TYPEID = 12591372
CGetOrRefuseItemReq.GET = 0
CGetOrRefuseItemReq.REFUSE = 1
function CGetOrRefuseItemReq:ctor(awardUuid, itemid, operation)
  self.id = 12591372
  self.awardUuid = awardUuid or nil
  self.itemid = itemid or nil
  self.operation = operation or nil
end
function CGetOrRefuseItemReq:marshal(os)
  os:marshalInt64(self.awardUuid)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.operation)
end
function CGetOrRefuseItemReq:unmarshal(os)
  self.awardUuid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.operation = os:unmarshalInt32()
end
function CGetOrRefuseItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetOrRefuseItemReq
