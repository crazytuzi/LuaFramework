local OctetsStream = require("netio.OctetsStream")
local CrossMatchProcessInfo = class("CrossMatchProcessInfo")
function CrossMatchProcessInfo:ctor(roleid, process)
  self.roleid = roleid or nil
  self.process = process or nil
end
function CrossMatchProcessInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.process)
end
function CrossMatchProcessInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.process = os:unmarshalInt32()
end
return CrossMatchProcessInfo
