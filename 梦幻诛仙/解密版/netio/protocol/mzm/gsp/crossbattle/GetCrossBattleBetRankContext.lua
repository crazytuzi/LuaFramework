local OctetsStream = require("netio.OctetsStream")
local GetCrossBattleBetRankContext = class("GetCrossBattleBetRankContext")
GetCrossBattleBetRankContext.OPER_TYPE_CLIENT_REQ = 0
GetCrossBattleBetRankContext.OPER_TYPE_RANK_AWARD = 1
function GetCrossBattleBetRankContext:ctor(oper_type, count, extra_info)
  self.oper_type = oper_type or nil
  self.count = count or nil
  self.extra_info = extra_info or nil
end
function GetCrossBattleBetRankContext:marshal(os)
  os:marshalUInt8(self.oper_type)
  os:marshalUInt8(self.count)
  os:marshalOctets(self.extra_info)
end
function GetCrossBattleBetRankContext:unmarshal(os)
  self.oper_type = os:unmarshalUInt8()
  self.count = os:unmarshalUInt8()
  self.extra_info = os:unmarshalOctets()
end
return GetCrossBattleBetRankContext
