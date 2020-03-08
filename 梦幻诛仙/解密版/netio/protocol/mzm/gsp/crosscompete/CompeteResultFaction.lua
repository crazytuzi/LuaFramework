local OctetsStream = require("netio.OctetsStream")
local CompeteResultFaction = class("CompeteResultFaction")
CompeteResultFaction.SELF_SERVER_FALSE = 0
CompeteResultFaction.SELF_SERVER_TRUE = 1
function CompeteResultFaction:ctor(factionid, name, self_server)
  self.factionid = factionid or nil
  self.name = name or nil
  self.self_server = self_server or nil
end
function CompeteResultFaction:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalString(self.name)
  os:marshalInt32(self.self_server)
end
function CompeteResultFaction:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.self_server = os:unmarshalInt32()
end
return CompeteResultFaction
