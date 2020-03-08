local OctetsStream = require("netio.OctetsStream")
local IndianaLog = class("IndianaLog")
function IndianaLog:ctor(turn, sortid, award_number, roleid, role_name)
  self.turn = turn or nil
  self.sortid = sortid or nil
  self.award_number = award_number or nil
  self.roleid = roleid or nil
  self.role_name = role_name or nil
end
function IndianaLog:marshal(os)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.award_number)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
end
function IndianaLog:unmarshal(os)
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.award_number = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
end
return IndianaLog
