local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_ReportFightResult = class("GetKnockOutContext_ReportFightResult")
function GetKnockOutContext_ReportFightResult:ctor(corps_id, corps_name, opponent_corps_id, opponent_corps_name, fight_stage, fight_index_id, corps_fight_result, repeat_times)
  self.corps_id = corps_id or nil
  self.corps_name = corps_name or nil
  self.opponent_corps_id = opponent_corps_id or nil
  self.opponent_corps_name = opponent_corps_name or nil
  self.fight_stage = fight_stage or nil
  self.fight_index_id = fight_index_id or nil
  self.corps_fight_result = corps_fight_result or nil
  self.repeat_times = repeat_times or nil
end
function GetKnockOutContext_ReportFightResult:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalOctets(self.corps_name)
  os:marshalInt64(self.opponent_corps_id)
  os:marshalOctets(self.opponent_corps_name)
  os:marshalInt32(self.fight_stage)
  os:marshalInt32(self.fight_index_id)
  os:marshalInt32(self.corps_fight_result)
  os:marshalInt32(self.repeat_times)
end
function GetKnockOutContext_ReportFightResult:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.corps_name = os:unmarshalOctets()
  self.opponent_corps_id = os:unmarshalInt64()
  self.opponent_corps_name = os:unmarshalOctets()
  self.fight_stage = os:unmarshalInt32()
  self.fight_index_id = os:unmarshalInt32()
  self.corps_fight_result = os:unmarshalInt32()
  self.repeat_times = os:unmarshalInt32()
end
return GetKnockOutContext_ReportFightResult
