local CompeteFaction = require("netio.protocol.mzm.gsp.crosscompete.CompeteFaction")
local SSyncAgainst = class("SSyncAgainst")
SSyncAgainst.TYPEID = 12616708
function SSyncAgainst:ctor(self_faction, self_name, opponent_faction, opponent_name)
  self.id = 12616708
  self.self_faction = self_faction or CompeteFaction.new()
  self.self_name = self_name or nil
  self.opponent_faction = opponent_faction or CompeteFaction.new()
  self.opponent_name = opponent_name or nil
end
function SSyncAgainst:marshal(os)
  self.self_faction:marshal(os)
  os:marshalString(self.self_name)
  self.opponent_faction:marshal(os)
  os:marshalString(self.opponent_name)
end
function SSyncAgainst:unmarshal(os)
  self.self_faction = CompeteFaction.new()
  self.self_faction:unmarshal(os)
  self.self_name = os:unmarshalString()
  self.opponent_faction = CompeteFaction.new()
  self.opponent_faction:unmarshal(os)
  self.opponent_name = os:unmarshalString()
end
function SSyncAgainst:sizepolicy(size)
  return size <= 65535
end
return SSyncAgainst
