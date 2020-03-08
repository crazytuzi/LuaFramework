local CRideMounts = class("CRideMounts")
CRideMounts.TYPEID = 12606236
function CRideMounts:ctor(mounts_id)
  self.id = 12606236
  self.mounts_id = mounts_id or nil
end
function CRideMounts:marshal(os)
  os:marshalInt64(self.mounts_id)
end
function CRideMounts:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
end
function CRideMounts:sizepolicy(size)
  return size <= 65535
end
return CRideMounts
