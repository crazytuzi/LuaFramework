local OctetsStream = require("netio.OctetsStream")
local GetLadderRoleRankContext = class("GetLadderRoleRankContext")
GetLadderRoleRankContext.OPER_TYPE_SELF_REQ = 0
function GetLadderRoleRankContext:ctor(oper_type, count, content)
  self.oper_type = oper_type or nil
  self.count = count or nil
  self.content = content or nil
end
function GetLadderRoleRankContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalInt32(self.count)
  os:marshalOctets(self.content)
end
function GetLadderRoleRankContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetLadderRoleRankContext
