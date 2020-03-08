local OctetsStream = require("netio.OctetsStream")
local CompeteFaction = class("CompeteFaction")
function CompeteFaction:ctor(factionid, pk_score, player_score, player_number, mercenary_score)
  self.factionid = factionid or nil
  self.pk_score = pk_score or nil
  self.player_score = player_score or nil
  self.player_number = player_number or nil
  self.mercenary_score = mercenary_score or nil
end
function CompeteFaction:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalInt32(self.pk_score)
  os:marshalInt32(self.player_score)
  os:marshalInt32(self.player_number)
  os:marshalInt32(self.mercenary_score)
end
function CompeteFaction:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.pk_score = os:unmarshalInt32()
  self.player_score = os:unmarshalInt32()
  self.player_number = os:unmarshalInt32()
  self.mercenary_score = os:unmarshalInt32()
end
return CompeteFaction
