local OctetsStream = require("netio.OctetsStream")
local OuterInfo = class("OuterInfo")
function OuterInfo:ctor(index, accumulateTurnCount, ticketCount)
  self.index = index or nil
  self.accumulateTurnCount = accumulateTurnCount or nil
  self.ticketCount = ticketCount or nil
end
function OuterInfo:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.accumulateTurnCount)
  os:marshalInt32(self.ticketCount)
end
function OuterInfo:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.accumulateTurnCount = os:unmarshalInt32()
  self.ticketCount = os:unmarshalInt32()
end
return OuterInfo
