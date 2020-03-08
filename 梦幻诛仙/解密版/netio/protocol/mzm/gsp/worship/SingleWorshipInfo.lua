local OctetsStream = require("netio.OctetsStream")
local SingleWorshipInfo = class("SingleWorshipInfo")
function SingleWorshipInfo:ctor(roleId, worshipId, contentIndex)
  self.roleId = roleId or nil
  self.worshipId = worshipId or nil
  self.contentIndex = contentIndex or nil
end
function SingleWorshipInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.worshipId)
  os:marshalInt32(self.contentIndex)
end
function SingleWorshipInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.worshipId = os:unmarshalInt32()
  self.contentIndex = os:unmarshalInt32()
end
return SingleWorshipInfo
