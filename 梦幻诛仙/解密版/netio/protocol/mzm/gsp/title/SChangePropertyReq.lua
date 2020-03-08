local SChangePropertyReq = class("SChangePropertyReq")
SChangePropertyReq.TYPEID = 12593921
function SChangePropertyReq:ctor(appellationId)
  self.id = 12593921
  self.appellationId = appellationId or nil
end
function SChangePropertyReq:marshal(os)
  os:marshalInt32(self.appellationId)
end
function SChangePropertyReq:unmarshal(os)
  self.appellationId = os:unmarshalInt32()
end
function SChangePropertyReq:sizepolicy(size)
  return size <= 65535
end
return SChangePropertyReq
