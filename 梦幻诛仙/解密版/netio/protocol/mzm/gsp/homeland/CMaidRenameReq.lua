local CMaidRenameReq = class("CMaidRenameReq")
CMaidRenameReq.TYPEID = 12605450
function CMaidRenameReq:ctor(maidUuid, name)
  self.id = 12605450
  self.maidUuid = maidUuid or nil
  self.name = name or nil
end
function CMaidRenameReq:marshal(os)
  os:marshalInt64(self.maidUuid)
  os:marshalOctets(self.name)
end
function CMaidRenameReq:unmarshal(os)
  self.maidUuid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
end
function CMaidRenameReq:sizepolicy(size)
  return size <= 65535
end
return CMaidRenameReq
