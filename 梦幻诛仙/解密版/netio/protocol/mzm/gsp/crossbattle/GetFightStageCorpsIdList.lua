local OctetsStream = require("netio.OctetsStream")
local GetFightStageCorpsIdList = class("GetFightStageCorpsIdList")
GetFightStageCorpsIdList.OPER_NOTIFY_KNOCK_OUT_CORPS_ID = 1
GetFightStageCorpsIdList.OPER_AWARD = 2
function GetFightStageCorpsIdList:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function GetFightStageCorpsIdList:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function GetFightStageCorpsIdList:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetFightStageCorpsIdList
