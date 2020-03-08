local SUseRidderItemRes = class("SUseRidderItemRes")
SUseRidderItemRes.TYPEID = 788261
function SUseRidderItemRes:ctor(ridderid)
  self.id = 788261
  self.ridderid = ridderid or nil
end
function SUseRidderItemRes:marshal(os)
  os:marshalInt32(self.ridderid)
end
function SUseRidderItemRes:unmarshal(os)
  self.ridderid = os:unmarshalInt32()
end
function SUseRidderItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseRidderItemRes
