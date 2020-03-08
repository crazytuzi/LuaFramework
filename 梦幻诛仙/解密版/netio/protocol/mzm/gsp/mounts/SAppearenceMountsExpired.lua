local SAppearenceMountsExpired = class("SAppearenceMountsExpired")
SAppearenceMountsExpired.TYPEID = 12606232
function SAppearenceMountsExpired:ctor(mounts_id)
  self.id = 12606232
  self.mounts_id = mounts_id or nil
end
function SAppearenceMountsExpired:marshal(os)
  os:marshalInt64(self.mounts_id)
end
function SAppearenceMountsExpired:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
end
function SAppearenceMountsExpired:sizepolicy(size)
  return size <= 65535
end
return SAppearenceMountsExpired
