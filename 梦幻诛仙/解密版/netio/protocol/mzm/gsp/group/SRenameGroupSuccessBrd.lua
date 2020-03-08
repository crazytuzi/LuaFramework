local SRenameGroupSuccessBrd = class("SRenameGroupSuccessBrd")
SRenameGroupSuccessBrd.TYPEID = 12605185
function SRenameGroupSuccessBrd:ctor(groupid, new_group_name, info_version)
  self.id = 12605185
  self.groupid = groupid or nil
  self.new_group_name = new_group_name or nil
  self.info_version = info_version or nil
end
function SRenameGroupSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.new_group_name)
  os:marshalInt64(self.info_version)
end
function SRenameGroupSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.new_group_name = os:unmarshalOctets()
  self.info_version = os:unmarshalInt64()
end
function SRenameGroupSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SRenameGroupSuccessBrd
