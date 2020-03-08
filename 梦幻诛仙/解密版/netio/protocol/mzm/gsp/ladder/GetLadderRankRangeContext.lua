local OctetsStream = require("netio.OctetsStream")
local GetLadderRankRangeContext = class("GetLadderRankRangeContext")
GetLadderRankRangeContext.OPER_TYPE_CLIENT_REQ = 0
GetLadderRankRangeContext.OPER_TYPE_SEND_RANK_AWARD = 1
function GetLadderRankRangeContext:ctor(oper_type, count, content)
  self.oper_type = oper_type or nil
  self.count = count or nil
  self.content = content or nil
end
function GetLadderRankRangeContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalInt32(self.count)
  os:marshalOctets(self.content)
end
function GetLadderRankRangeContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetLadderRankRangeContext
