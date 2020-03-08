local OctetsStream = require("netio.OctetsStream")
local GroupKickInfo = class("GroupKickInfo")
function GroupKickInfo:ctor(group_name, master_name)
  self.group_name = group_name or nil
  self.master_name = master_name or nil
end
function GroupKickInfo:marshal(os)
  os:marshalOctets(self.group_name)
  os:marshalOctets(self.master_name)
end
function GroupKickInfo:unmarshal(os)
  self.group_name = os:unmarshalOctets()
  self.master_name = os:unmarshalOctets()
end
return GroupKickInfo
