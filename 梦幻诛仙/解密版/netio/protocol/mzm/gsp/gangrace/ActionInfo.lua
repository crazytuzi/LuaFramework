local OctetsStream = require("netio.OctetsStream")
local ActionInfo = class("ActionInfo")
function ActionInfo:ctor(actionCode, moveStep)
  self.actionCode = actionCode or nil
  self.moveStep = moveStep or nil
end
function ActionInfo:marshal(os)
  os:marshalInt32(self.actionCode)
  os:marshalInt32(self.moveStep)
end
function ActionInfo:unmarshal(os)
  self.actionCode = os:unmarshalInt32()
  self.moveStep = os:unmarshalInt32()
end
return ActionInfo
