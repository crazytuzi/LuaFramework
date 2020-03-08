local OctetsStream = require("netio.OctetsStream")
local FightAgainstInfo = class("FightAgainstInfo")
function FightAgainstInfo:ctor(corps_a_id, corps_a_state, corps_b_id, corps_b_state, cal_fight_result, record_id)
  self.corps_a_id = corps_a_id or nil
  self.corps_a_state = corps_a_state or nil
  self.corps_b_id = corps_b_id or nil
  self.corps_b_state = corps_b_state or nil
  self.cal_fight_result = cal_fight_result or nil
  self.record_id = record_id or nil
end
function FightAgainstInfo:marshal(os)
  os:marshalInt64(self.corps_a_id)
  os:marshalInt32(self.corps_a_state)
  os:marshalInt64(self.corps_b_id)
  os:marshalInt32(self.corps_b_state)
  os:marshalInt32(self.cal_fight_result)
  os:marshalInt64(self.record_id)
end
function FightAgainstInfo:unmarshal(os)
  self.corps_a_id = os:unmarshalInt64()
  self.corps_a_state = os:unmarshalInt32()
  self.corps_b_id = os:unmarshalInt64()
  self.corps_b_state = os:unmarshalInt32()
  self.cal_fight_result = os:unmarshalInt32()
  self.record_id = os:unmarshalInt64()
end
return FightAgainstInfo
