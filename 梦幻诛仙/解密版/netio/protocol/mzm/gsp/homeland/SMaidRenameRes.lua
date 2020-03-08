local SMaidRenameRes = class("SMaidRenameRes")
SMaidRenameRes.TYPEID = 12605492
function SMaidRenameRes:ctor(maidUuid, name)
  self.id = 12605492
  self.maidUuid = maidUuid or nil
  self.name = name or nil
end
function SMaidRenameRes:marshal(os)
  os:marshalInt64(self.maidUuid)
  os:marshalOctets(self.name)
end
function SMaidRenameRes:unmarshal(os)
  self.maidUuid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
end
function SMaidRenameRes:sizepolicy(size)
  return size <= 65535
end
return SMaidRenameRes
