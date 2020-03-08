local SMemberRenameBrd = class("SMemberRenameBrd")
SMemberRenameBrd.TYPEID = 12605205
function SMemberRenameBrd:ctor(groupid, memberid, name, info_version)
  self.id = 12605205
  self.groupid = groupid or nil
  self.memberid = memberid or nil
  self.name = name or nil
  self.info_version = info_version or nil
end
function SMemberRenameBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.memberid)
  os:marshalOctets(self.name)
  os:marshalInt64(self.info_version)
end
function SMemberRenameBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.info_version = os:unmarshalInt64()
end
function SMemberRenameBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberRenameBrd
