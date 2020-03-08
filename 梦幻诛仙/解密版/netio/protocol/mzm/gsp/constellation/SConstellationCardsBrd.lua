local ConstellationCards = require("netio.protocol.mzm.gsp.constellation.ConstellationCards")
local SConstellationCardsBrd = class("SConstellationCardsBrd")
SConstellationCardsBrd.TYPEID = 12612097
function SConstellationCardsBrd:ctor(cards)
  self.id = 12612097
  self.cards = cards or ConstellationCards.new()
end
function SConstellationCardsBrd:marshal(os)
  self.cards:marshal(os)
end
function SConstellationCardsBrd:unmarshal(os)
  self.cards = ConstellationCards.new()
  self.cards:unmarshal(os)
end
function SConstellationCardsBrd:sizepolicy(size)
  return size <= 65535
end
return SConstellationCardsBrd
