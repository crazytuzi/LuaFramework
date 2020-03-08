local RedgiftData = require("netio.protocol.mzm.gsp.activity.RedgiftData")
local SGetRedgiftActivityRewardRes = class("SGetRedgiftActivityRewardRes")
SGetRedgiftActivityRewardRes.TYPEID = 12587589
SGetRedgiftActivityRewardRes.SUCCESS = 0
SGetRedgiftActivityRewardRes.FAIL = 1
SGetRedgiftActivityRewardRes.LIMIT = 10
function SGetRedgiftActivityRewardRes:ctor(result, cfgId, rewardInfo)
  self.id = 12587589
  self.result = result or nil
  self.cfgId = cfgId or nil
  self.rewardInfo = rewardInfo or RedgiftData.new()
end
function SGetRedgiftActivityRewardRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.cfgId)
  self.rewardInfo:marshal(os)
end
function SGetRedgiftActivityRewardRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.cfgId = os:unmarshalInt32()
  self.rewardInfo = RedgiftData.new()
  self.rewardInfo:unmarshal(os)
end
function SGetRedgiftActivityRewardRes:sizepolicy(size)
  return size <= 65535
end
return SGetRedgiftActivityRewardRes
