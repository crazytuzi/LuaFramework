local OctetsStream = require("netio.OctetsStream")
local CakeDetailInfo = class("CakeDetailInfo")
CakeDetailInfo.STAGE_MAKE_ING = 1
CakeDetailInfo.STAGE_FREE = 2
function CakeDetailInfo:ctor(curTurn, cakeId, state, cookStartTime)
  self.curTurn = curTurn or nil
  self.cakeId = cakeId or nil
  self.state = state or nil
  self.cookStartTime = cookStartTime or nil
end
function CakeDetailInfo:marshal(os)
  os:marshalInt32(self.curTurn)
  os:marshalInt32(self.cakeId)
  os:marshalInt32(self.state)
  os:marshalInt64(self.cookStartTime)
end
function CakeDetailInfo:unmarshal(os)
  self.curTurn = os:unmarshalInt32()
  self.cakeId = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.cookStartTime = os:unmarshalInt64()
end
return CakeDetailInfo
