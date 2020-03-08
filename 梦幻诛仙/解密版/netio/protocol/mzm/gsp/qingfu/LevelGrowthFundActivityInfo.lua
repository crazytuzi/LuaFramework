local OctetsStream = require("netio.OctetsStream")
local LevelGrowthFundActivityInfo = class("LevelGrowthFundActivityInfo")
function LevelGrowthFundActivityInfo:ctor(purchased, sortid)
  self.purchased = purchased or nil
  self.sortid = sortid or nil
end
function LevelGrowthFundActivityInfo:marshal(os)
  os:marshalUInt8(self.purchased)
  os:marshalInt32(self.sortid)
end
function LevelGrowthFundActivityInfo:unmarshal(os)
  self.purchased = os:unmarshalUInt8()
  self.sortid = os:unmarshalInt32()
end
return LevelGrowthFundActivityInfo
