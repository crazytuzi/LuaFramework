local OctetsStream = require("netio.OctetsStream")
local AgainstFaction = require("netio.protocol.mzm.gsp.crosscompete.AgainstFaction")
local Against = class("Against")
function Against:ctor(faction1, faction2, compete_index, winner)
  self.faction1 = faction1 or AgainstFaction.new()
  self.faction2 = faction2 or AgainstFaction.new()
  self.compete_index = compete_index or nil
  self.winner = winner or nil
end
function Against:marshal(os)
  self.faction1:marshal(os)
  self.faction2:marshal(os)
  os:marshalInt32(self.compete_index)
  os:marshalInt64(self.winner)
end
function Against:unmarshal(os)
  self.faction1 = AgainstFaction.new()
  self.faction1:unmarshal(os)
  self.faction2 = AgainstFaction.new()
  self.faction2:unmarshal(os)
  self.compete_index = os:unmarshalInt32()
  self.winner = os:unmarshalInt64()
end
return Against
