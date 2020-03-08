local OctetsStream = require("netio.OctetsStream")
local BackGameActivityAwardInfo = class("BackGameActivityAwardInfo")
BackGameActivityAwardInfo.AVAILABLE = 0
BackGameActivityAwardInfo.NOT_AVAILABLE = 1
function BackGameActivityAwardInfo:ctor(back_game_award_available, back_game_award_tier_cfg_id)
  self.back_game_award_available = back_game_award_available or nil
  self.back_game_award_tier_cfg_id = back_game_award_tier_cfg_id or nil
end
function BackGameActivityAwardInfo:marshal(os)
  os:marshalInt32(self.back_game_award_available)
  os:marshalInt32(self.back_game_award_tier_cfg_id)
end
function BackGameActivityAwardInfo:unmarshal(os)
  self.back_game_award_available = os:unmarshalInt32()
  self.back_game_award_tier_cfg_id = os:unmarshalInt32()
end
return BackGameActivityAwardInfo
