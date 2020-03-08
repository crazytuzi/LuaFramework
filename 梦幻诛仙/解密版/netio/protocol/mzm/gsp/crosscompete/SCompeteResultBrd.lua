local CompeteResultFaction = require("netio.protocol.mzm.gsp.crosscompete.CompeteResultFaction")
local SCompeteResultBrd = class("SCompeteResultBrd")
SCompeteResultBrd.TYPEID = 12616746
function SCompeteResultBrd:ctor(win_faction, lose_faction)
  self.id = 12616746
  self.win_faction = win_faction or CompeteResultFaction.new()
  self.lose_faction = lose_faction or CompeteResultFaction.new()
end
function SCompeteResultBrd:marshal(os)
  self.win_faction:marshal(os)
  self.lose_faction:marshal(os)
end
function SCompeteResultBrd:unmarshal(os)
  self.win_faction = CompeteResultFaction.new()
  self.win_faction:unmarshal(os)
  self.lose_faction = CompeteResultFaction.new()
  self.lose_faction:unmarshal(os)
end
function SCompeteResultBrd:sizepolicy(size)
  return size <= 65535
end
return SCompeteResultBrd
