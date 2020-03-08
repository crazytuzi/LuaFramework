local CGetChildLocation = class("CGetChildLocation")
CGetChildLocation.TYPEID = 12609430
function CGetChildLocation:ctor(child_id)
  self.id = 12609430
  self.child_id = child_id or nil
end
function CGetChildLocation:marshal(os)
  os:marshalInt64(self.child_id)
end
function CGetChildLocation:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CGetChildLocation:sizepolicy(size)
  return size <= 65535
end
return CGetChildLocation
