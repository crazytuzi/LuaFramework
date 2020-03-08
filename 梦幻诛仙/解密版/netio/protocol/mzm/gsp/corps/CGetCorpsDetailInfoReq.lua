local CGetCorpsDetailInfoReq = class("CGetCorpsDetailInfoReq")
CGetCorpsDetailInfoReq.TYPEID = 12617516
function CGetCorpsDetailInfoReq:ctor(corpsId)
  self.id = 12617516
  self.corpsId = corpsId or nil
end
function CGetCorpsDetailInfoReq:marshal(os)
  os:marshalInt64(self.corpsId)
end
function CGetCorpsDetailInfoReq:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
end
function CGetCorpsDetailInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetCorpsDetailInfoReq
