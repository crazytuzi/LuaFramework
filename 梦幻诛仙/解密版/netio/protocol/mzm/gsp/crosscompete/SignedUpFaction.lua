local OctetsStream = require("netio.OctetsStream")
local SignedUpFaction = class("SignedUpFaction")
function SignedUpFaction:ctor(factionid, faction_name, faction_displayid, leaderid, leader_name)
  self.factionid = factionid or nil
  self.faction_name = faction_name or nil
  self.faction_displayid = faction_displayid or nil
  self.leaderid = leaderid or nil
  self.leader_name = leader_name or nil
end
function SignedUpFaction:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalString(self.faction_name)
  os:marshalInt64(self.faction_displayid)
  os:marshalInt64(self.leaderid)
  os:marshalString(self.leader_name)
end
function SignedUpFaction:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.faction_name = os:unmarshalString()
  self.faction_displayid = os:unmarshalInt64()
  self.leaderid = os:unmarshalInt64()
  self.leader_name = os:unmarshalString()
end
return SignedUpFaction
