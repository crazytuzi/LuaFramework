local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_NotifyFightResult = class("GetKnockOutContext_NotifyFightResult")
function GetKnockOutContext_NotifyFightResult:ctor(role_id, corps_id, opponent_corps_id, knock_out_type, fight_stage, fight_index_id, win_or_lose, repeat_times)
  self.role_id = role_id or nil
  self.corps_id = corps_id or nil
  self.opponent_corps_id = opponent_corps_id or nil
  self.knock_out_type = knock_out_type or nil
  self.fight_stage = fight_stage or nil
  self.fight_index_id = fight_index_id or nil
  self.win_or_lose = win_or_lose or nil
  self.repeat_times = repeat_times or nil
end
function GetKnockOutContext_NotifyFightResult:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt64(self.corps_id)
  os:marshalInt64(self.opponent_corps_id)
  os:marshalInt32(self.knock_out_type)
  os:marshalInt32(self.fight_stage)
  os:marshalInt32(self.fight_index_id)
  os:marshalInt32(self.win_or_lose)
  os:marshalInt32(self.repeat_times)
end
function GetKnockOutContext_NotifyFightResult:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.corps_id = os:unmarshalInt64()
  self.opponent_corps_id = os:unmarshalInt64()
  self.knock_out_type = os:unmarshalInt32()
  self.fight_stage = os:unmarshalInt32()
  self.fight_index_id = os:unmarshalInt32()
  self.win_or_lose = os:unmarshalInt32()
  self.repeat_times = os:unmarshalInt32()
end
return GetKnockOutContext_NotifyFightResult
