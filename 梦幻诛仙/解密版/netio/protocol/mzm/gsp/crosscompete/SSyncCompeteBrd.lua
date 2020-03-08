local CompeteFaction = require("netio.protocol.mzm.gsp.crosscompete.CompeteFaction")
local SSyncCompeteBrd = class("SSyncCompeteBrd")
SSyncCompeteBrd.TYPEID = 12616724
function SSyncCompeteBrd:ctor(faction1, faction2)
  self.id = 12616724
  self.faction1 = faction1 or CompeteFaction.new()
  self.faction2 = faction2 or CompeteFaction.new()
end
function SSyncCompeteBrd:marshal(os)
  self.faction1:marshal(os)
  self.faction2:marshal(os)
end
function SSyncCompeteBrd:unmarshal(os)
  self.faction1 = CompeteFaction.new()
  self.faction1:unmarshal(os)
  self.faction2 = CompeteFaction.new()
  self.faction2:unmarshal(os)
end
function SSyncCompeteBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncCompeteBrd
