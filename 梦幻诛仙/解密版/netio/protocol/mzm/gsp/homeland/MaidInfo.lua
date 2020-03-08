local OctetsStream = require("netio.OctetsStream")
local MaidInfo = class("MaidInfo")
function MaidInfo:ctor(maidId, name)
  self.maidId = maidId or nil
  self.name = name or nil
end
function MaidInfo:marshal(os)
  os:marshalInt32(self.maidId)
  os:marshalOctets(self.name)
end
function MaidInfo:unmarshal(os)
  self.maidId = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
end
return MaidInfo
