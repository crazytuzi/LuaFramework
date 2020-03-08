local SKickGroupMemberSuccessBrd = class("SKickGroupMemberSuccessBrd")
SKickGroupMemberSuccessBrd.TYPEID = 12605214
function SKickGroupMemberSuccessBrd:ctor(groupid, group_name, master_name, memberid, info_version)
  self.id = 12605214
  self.groupid = groupid or nil
  self.group_name = group_name or nil
  self.master_name = master_name or nil
  self.memberid = memberid or nil
  self.info_version = info_version or nil
end
function SKickGroupMemberSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.group_name)
  os:marshalOctets(self.master_name)
  os:marshalInt64(self.memberid)
  os:marshalInt64(self.info_version)
end
function SKickGroupMemberSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.group_name = os:unmarshalOctets()
  self.master_name = os:unmarshalOctets()
  self.memberid = os:unmarshalInt64()
  self.info_version = os:unmarshalInt64()
end
function SKickGroupMemberSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SKickGroupMemberSuccessBrd
