local sworninfo = require("netio.protocol.mzm.gsp.sworn.sworninfo")
local SNewMemberConfirmSworn = class("SNewMemberConfirmSworn")
SNewMemberConfirmSworn.TYPEID = 12597805
function SNewMemberConfirmSworn:ctor(rolename, info)
  self.id = 12597805
  self.rolename = rolename or nil
  self.info = info or sworninfo.new()
end
function SNewMemberConfirmSworn:marshal(os)
  os:marshalString(self.rolename)
  self.info:marshal(os)
end
function SNewMemberConfirmSworn:unmarshal(os)
  self.rolename = os:unmarshalString()
  self.info = sworninfo.new()
  self.info:unmarshal(os)
end
function SNewMemberConfirmSworn:sizepolicy(size)
  return size <= 65535
end
return SNewMemberConfirmSworn
