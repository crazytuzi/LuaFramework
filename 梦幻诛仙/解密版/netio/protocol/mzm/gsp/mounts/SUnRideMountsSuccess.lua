local SUnRideMountsSuccess = class("SUnRideMountsSuccess")
SUnRideMountsSuccess.TYPEID = 12606226
function SUnRideMountsSuccess:ctor(mounts_id)
  self.id = 12606226
  self.mounts_id = mounts_id or nil
end
function SUnRideMountsSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
end
function SUnRideMountsSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
end
function SUnRideMountsSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnRideMountsSuccess
