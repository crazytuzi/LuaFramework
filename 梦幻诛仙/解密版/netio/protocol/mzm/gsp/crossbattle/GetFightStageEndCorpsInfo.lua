local OctetsStream = require("netio.OctetsStream")
local GetFightStageEndCorpsInfo = class("GetFightStageEndCorpsInfo")
GetFightStageEndCorpsInfo.OPER_FINAL_HISTORY = 1
GetFightStageEndCorpsInfo.OPER_MAP_CHAMPION_STATUE = 2
function GetFightStageEndCorpsInfo:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function GetFightStageEndCorpsInfo:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function GetFightStageEndCorpsInfo:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetFightStageEndCorpsInfo
