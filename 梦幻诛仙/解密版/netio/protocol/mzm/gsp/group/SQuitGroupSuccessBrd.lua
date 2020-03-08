local SQuitGroupSuccessBrd = class("SQuitGroupSuccessBrd")
SQuitGroupSuccessBrd.TYPEID = 12605199
function SQuitGroupSuccessBrd:ctor(groupid, memberid, info_version)
  self.id = 12605199
  self.groupid = groupid or nil
  self.memberid = memberid or nil
  self.info_version = info_version or nil
end
function SQuitGroupSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.memberid)
  os:marshalInt64(self.info_version)
end
function SQuitGroupSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
  self.info_version = os:unmarshalInt64()
end
function SQuitGroupSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SQuitGroupSuccessBrd
