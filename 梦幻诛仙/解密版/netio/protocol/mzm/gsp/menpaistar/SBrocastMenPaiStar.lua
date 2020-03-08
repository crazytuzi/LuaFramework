local MenPaiStarChampionInfo = require("netio.protocol.mzm.gsp.menpaistar.MenPaiStarChampionInfo")
local SBrocastMenPaiStar = class("SBrocastMenPaiStar")
SBrocastMenPaiStar.TYPEID = 12612364
function SBrocastMenPaiStar:ctor(champion)
  self.id = 12612364
  self.champion = champion or MenPaiStarChampionInfo.new()
end
function SBrocastMenPaiStar:marshal(os)
  self.champion:marshal(os)
end
function SBrocastMenPaiStar:unmarshal(os)
  self.champion = MenPaiStarChampionInfo.new()
  self.champion:unmarshal(os)
end
function SBrocastMenPaiStar:sizepolicy(size)
  return size <= 65535
end
return SBrocastMenPaiStar
