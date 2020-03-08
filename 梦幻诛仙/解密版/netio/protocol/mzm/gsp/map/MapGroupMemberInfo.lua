local OctetsStream = require("netio.OctetsStream")
local MapGroupMemberInfo = class("MapGroupMemberInfo")
function MapGroupMemberInfo:ctor(roleid, model_info)
  self.roleid = roleid or nil
  self.model_info = model_info or nil
end
function MapGroupMemberInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.model_info)
end
function MapGroupMemberInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.model_info = os:unmarshalOctets()
end
return MapGroupMemberInfo
