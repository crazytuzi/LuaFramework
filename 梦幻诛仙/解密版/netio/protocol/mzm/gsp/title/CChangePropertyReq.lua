local CChangePropertyReq = class("CChangePropertyReq")
CChangePropertyReq.TYPEID = 12593929
function CChangePropertyReq:ctor(appellationId)
  self.id = 12593929
  self.appellationId = appellationId or nil
end
function CChangePropertyReq:marshal(os)
  os:marshalInt32(self.appellationId)
end
function CChangePropertyReq:unmarshal(os)
  self.appellationId = os:unmarshalInt32()
end
function CChangePropertyReq:sizepolicy(size)
  return size <= 65535
end
return CChangePropertyReq
