local OctetsStream = require("netio.OctetsStream")
local RemovePointRaceContext = class("RemovePointRaceContext")
RemovePointRaceContext.REMOVE_POINT_RACE_DATA = 1
function RemovePointRaceContext:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function RemovePointRaceContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function RemovePointRaceContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return RemovePointRaceContext
