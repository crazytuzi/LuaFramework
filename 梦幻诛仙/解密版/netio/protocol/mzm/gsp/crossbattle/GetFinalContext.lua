local OctetsStream = require("netio.OctetsStream")
local GetFinalContext = class("GetFinalContext")
GetFinalContext.OPER_CHECK_PANEL_REQ = 0
GetFinalContext.OPER_GET_SPECIAL_FIGHT_ZONE_REQ = 1
GetFinalContext.OPER_CREATE_PREPARE_WORLD_REQ = 2
GetFinalContext.OPER_GET_STAGE_BET_INFO_REQ = 3
GetFinalContext.OPER_GET_FIGHT_ZONE_INFO_REQ = 4
function GetFinalContext:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function GetFinalContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function GetFinalContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetFinalContext
