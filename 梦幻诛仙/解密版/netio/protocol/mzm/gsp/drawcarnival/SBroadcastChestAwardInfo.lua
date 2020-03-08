local AwardWinnerInfo = require("netio.protocol.mzm.gsp.drawcarnival.AwardWinnerInfo")
local SBroadcastChestAwardInfo = class("SBroadcastChestAwardInfo")
SBroadcastChestAwardInfo.TYPEID = 12630020
function SBroadcastChestAwardInfo:ctor(winner_info, orig_yuan_bao_count, yuan_bao_count)
  self.id = 12630020
  self.winner_info = winner_info or AwardWinnerInfo.new()
  self.orig_yuan_bao_count = orig_yuan_bao_count or nil
  self.yuan_bao_count = yuan_bao_count or nil
end
function SBroadcastChestAwardInfo:marshal(os)
  self.winner_info:marshal(os)
  os:marshalInt64(self.orig_yuan_bao_count)
  os:marshalInt64(self.yuan_bao_count)
end
function SBroadcastChestAwardInfo:unmarshal(os)
  self.winner_info = AwardWinnerInfo.new()
  self.winner_info:unmarshal(os)
  self.orig_yuan_bao_count = os:unmarshalInt64()
  self.yuan_bao_count = os:unmarshalInt64()
end
function SBroadcastChestAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SBroadcastChestAwardInfo
