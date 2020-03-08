local OctetsStream = require("netio.OctetsStream")
local SingleInfo = class("SingleInfo")
function SingleInfo:ctor(instanceCfgid, curProcess, finishTimes, highProcess, sign)
  self.instanceCfgid = instanceCfgid or nil
  self.curProcess = curProcess or nil
  self.finishTimes = finishTimes or nil
  self.highProcess = highProcess or nil
  self.sign = sign or nil
end
function SingleInfo:marshal(os)
  os:marshalInt32(self.instanceCfgid)
  os:marshalInt32(self.curProcess)
  os:marshalInt32(self.finishTimes)
  os:marshalInt32(self.highProcess)
  os:marshalInt32(self.sign)
end
function SingleInfo:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
  self.curProcess = os:unmarshalInt32()
  self.finishTimes = os:unmarshalInt32()
  self.highProcess = os:unmarshalInt32()
  self.sign = os:unmarshalInt32()
end
return SingleInfo
