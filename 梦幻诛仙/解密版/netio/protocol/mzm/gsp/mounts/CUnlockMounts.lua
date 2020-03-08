local CUnlockMounts = class("CUnlockMounts")
CUnlockMounts.TYPEID = 12606210
function CUnlockMounts:ctor(item_uuid)
  self.id = 12606210
  self.item_uuid = item_uuid or nil
end
function CUnlockMounts:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUnlockMounts:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUnlockMounts:sizepolicy(size)
  return size <= 65535
end
return CUnlockMounts
