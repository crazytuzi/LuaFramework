local CRenameGroupReq = class("CRenameGroupReq")
CRenameGroupReq.TYPEID = 12605189
function CRenameGroupReq:ctor(groupid, new_group_name)
  self.id = 12605189
  self.groupid = groupid or nil
  self.new_group_name = new_group_name or nil
end
function CRenameGroupReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.new_group_name)
end
function CRenameGroupReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.new_group_name = os:unmarshalOctets()
end
function CRenameGroupReq:sizepolicy(size)
  return size <= 65535
end
return CRenameGroupReq
