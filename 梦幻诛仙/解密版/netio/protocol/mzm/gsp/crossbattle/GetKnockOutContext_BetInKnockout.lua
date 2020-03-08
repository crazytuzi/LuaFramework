local OctetsStream = require("netio.OctetsStream")
local GetKnockOutContext_BetInKnockout = class("GetKnockOutContext_BetInKnockout")
function GetKnockOutContext_BetInKnockout:ctor(role_id, stage, fight_index, bet_corps_id, sortid)
  self.role_id = role_id or nil
  self.stage = stage or nil
  self.fight_index = fight_index or nil
  self.bet_corps_id = bet_corps_id or nil
  self.sortid = sortid or nil
end
function GetKnockOutContext_BetInKnockout:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.fight_index)
  os:marshalInt64(self.bet_corps_id)
  os:marshalInt32(self.sortid)
end
function GetKnockOutContext_BetInKnockout:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.stage = os:unmarshalInt32()
  self.fight_index = os:unmarshalInt32()
  self.bet_corps_id = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
end
return GetKnockOutContext_BetInKnockout
