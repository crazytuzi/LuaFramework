local OctetsStream = require("netio.OctetsStream")
local GroupJoinInfo = class("GroupJoinInfo")
function GroupJoinInfo:ctor(group_name, inviter_name)
  self.group_name = group_name or nil
  self.inviter_name = inviter_name or nil
end
function GroupJoinInfo:marshal(os)
  os:marshalOctets(self.group_name)
  os:marshalOctets(self.inviter_name)
end
function GroupJoinInfo:unmarshal(os)
  self.group_name = os:unmarshalOctets()
  self.inviter_name = os:unmarshalOctets()
end
return GroupJoinInfo
