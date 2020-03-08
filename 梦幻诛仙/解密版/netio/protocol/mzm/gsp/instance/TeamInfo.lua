local OctetsStream = require("netio.OctetsStream")
local TeamInfo = class("TeamInfo")
function TeamInfo:ctor(instanceCfgid, toProcess, sign)
  self.instanceCfgid = instanceCfgid or nil
  self.toProcess = toProcess or nil
  self.sign = sign or nil
end
function TeamInfo:marshal(os)
  os:marshalInt32(self.instanceCfgid)
  os:marshalInt32(self.toProcess)
  os:marshalInt32(self.sign)
end
function TeamInfo:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
  self.toProcess = os:unmarshalInt32()
  self.sign = os:unmarshalInt32()
end
return TeamInfo
