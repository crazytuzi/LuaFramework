local CRemCommandReq = class("CRemCommandReq")
CRemCommandReq.TYPEID = 12594205
function CRemCommandReq:ctor(fighterid)
  self.id = 12594205
  self.fighterid = fighterid or nil
end
function CRemCommandReq:marshal(os)
  os:marshalInt32(self.fighterid)
end
function CRemCommandReq:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
end
function CRemCommandReq:sizepolicy(size)
  return size <= 65535
end
return CRemCommandReq
