local SSyncFactionPlayerScoreBrd = class("SSyncFactionPlayerScoreBrd")
SSyncFactionPlayerScoreBrd.TYPEID = 12616711
function SSyncFactionPlayerScoreBrd:ctor(factionid1, player_score1, factionid2, player_score2)
  self.id = 12616711
  self.factionid1 = factionid1 or nil
  self.player_score1 = player_score1 or nil
  self.factionid2 = factionid2 or nil
  self.player_score2 = player_score2 or nil
end
function SSyncFactionPlayerScoreBrd:marshal(os)
  os:marshalInt64(self.factionid1)
  os:marshalInt32(self.player_score1)
  os:marshalInt64(self.factionid2)
  os:marshalInt32(self.player_score2)
end
function SSyncFactionPlayerScoreBrd:unmarshal(os)
  self.factionid1 = os:unmarshalInt64()
  self.player_score1 = os:unmarshalInt32()
  self.factionid2 = os:unmarshalInt64()
  self.player_score2 = os:unmarshalInt32()
end
function SSyncFactionPlayerScoreBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncFactionPlayerScoreBrd
