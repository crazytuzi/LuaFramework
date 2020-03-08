local SRenameGroupFail = class("SRenameGroupFail")
SRenameGroupFail.TYPEID = 12605203
SRenameGroupFail.GROUP_NOT_EXIST = 1
SRenameGroupFail.ROLE_NOT_MASTER = 2
SRenameGroupFail.GROUP_NAME_ILLEGAL = 3
SRenameGroupFail.SAME_GROUP_NAME = 4
function SRenameGroupFail:ctor(res)
  self.id = 12605203
  self.res = res or nil
end
function SRenameGroupFail:marshal(os)
  os:marshalInt32(self.res)
end
function SRenameGroupFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SRenameGroupFail:sizepolicy(size)
  return size <= 65535
end
return SRenameGroupFail
