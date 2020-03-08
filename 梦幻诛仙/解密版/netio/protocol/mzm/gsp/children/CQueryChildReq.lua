local CQueryChildReq = class("CQueryChildReq")
CQueryChildReq.TYPEID = 12609394
function CQueryChildReq:ctor(childId)
  self.id = 12609394
  self.childId = childId or nil
end
function CQueryChildReq:marshal(os)
  os:marshalInt64(self.childId)
end
function CQueryChildReq:unmarshal(os)
  self.childId = os:unmarshalInt64()
end
function CQueryChildReq:sizepolicy(size)
  return size <= 65535
end
return CQueryChildReq
