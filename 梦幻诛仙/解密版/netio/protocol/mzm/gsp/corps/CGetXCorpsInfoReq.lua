local CGetXCorpsInfoReq = class("CGetXCorpsInfoReq")
CGetXCorpsInfoReq.TYPEID = 12617513
function CGetXCorpsInfoReq:ctor(corpsId)
  self.id = 12617513
  self.corpsId = corpsId or nil
end
function CGetXCorpsInfoReq:marshal(os)
  os:marshalInt64(self.corpsId)
end
function CGetXCorpsInfoReq:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
end
function CGetXCorpsInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetXCorpsInfoReq
