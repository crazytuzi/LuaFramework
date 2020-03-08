local OctetsStream = require("netio.OctetsStream")
local AgainstFaction = class("AgainstFaction")
function AgainstFaction:ctor(factionid, faction_name, faction_level, server_level, member_count)
  self.factionid = factionid or nil
  self.faction_name = faction_name or nil
  self.faction_level = faction_level or nil
  self.server_level = server_level or nil
  self.member_count = member_count or nil
end
function AgainstFaction:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalString(self.faction_name)
  os:marshalInt32(self.faction_level)
  os:marshalInt32(self.server_level)
  os:marshalInt32(self.member_count)
end
function AgainstFaction:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.faction_name = os:unmarshalString()
  self.faction_level = os:unmarshalInt32()
  self.server_level = os:unmarshalInt32()
  self.member_count = os:unmarshalInt32()
end
return AgainstFaction
