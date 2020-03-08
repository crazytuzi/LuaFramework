local OctetsStream = require("netio.OctetsStream")
local MoveStep = class("MoveStep")
function MoveStep:ctor(resourceNo, targetPos)
  self.resourceNo = resourceNo or nil
  self.targetPos = targetPos or nil
end
function MoveStep:marshal(os)
  os:marshalInt32(self.resourceNo)
  os:marshalInt32(self.targetPos)
end
function MoveStep:unmarshal(os)
  self.resourceNo = os:unmarshalInt32()
  self.targetPos = os:unmarshalInt32()
end
return MoveStep
