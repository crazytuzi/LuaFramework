local SRideMountsSuccess = class("SRideMountsSuccess")
SRideMountsSuccess.TYPEID = 12606209
function SRideMountsSuccess:ctor(mounts_id)
  self.id = 12606209
  self.mounts_id = mounts_id or nil
end
function SRideMountsSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
end
function SRideMountsSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
end
function SRideMountsSuccess:sizepolicy(size)
  return size <= 65535
end
return SRideMountsSuccess
