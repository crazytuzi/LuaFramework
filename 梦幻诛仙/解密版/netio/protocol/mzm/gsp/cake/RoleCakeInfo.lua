local OctetsStream = require("netio.OctetsStream")
local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
local RoleCakeInfo = class("RoleCakeInfo")
function RoleCakeInfo:ctor(curTurn, collectNum, cakeInfo, cookSelfCount, cookOtherCount, effectFactionId)
  self.curTurn = curTurn or nil
  self.collectNum = collectNum or nil
  self.cakeInfo = cakeInfo or CakeDetailInfo.new()
  self.cookSelfCount = cookSelfCount or nil
  self.cookOtherCount = cookOtherCount or nil
  self.effectFactionId = effectFactionId or nil
end
function RoleCakeInfo:marshal(os)
  os:marshalInt32(self.curTurn)
  os:marshalInt32(self.collectNum)
  self.cakeInfo:marshal(os)
  os:marshalInt32(self.cookSelfCount)
  os:marshalInt32(self.cookOtherCount)
  os:marshalInt64(self.effectFactionId)
end
function RoleCakeInfo:unmarshal(os)
  self.curTurn = os:unmarshalInt32()
  self.collectNum = os:unmarshalInt32()
  self.cakeInfo = CakeDetailInfo.new()
  self.cakeInfo:unmarshal(os)
  self.cookSelfCount = os:unmarshalInt32()
  self.cookOtherCount = os:unmarshalInt32()
  self.effectFactionId = os:unmarshalInt64()
end
return RoleCakeInfo
