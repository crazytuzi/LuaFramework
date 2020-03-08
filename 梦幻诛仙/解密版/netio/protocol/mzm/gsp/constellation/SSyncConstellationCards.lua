local ConstellationCards = require("netio.protocol.mzm.gsp.constellation.ConstellationCards")
local SSyncConstellationCards = class("SSyncConstellationCards")
SSyncConstellationCards.TYPEID = 12612107
function SSyncConstellationCards:ctor(cards, choose_index)
  self.id = 12612107
  self.cards = cards or ConstellationCards.new()
  self.choose_index = choose_index or nil
end
function SSyncConstellationCards:marshal(os)
  self.cards:marshal(os)
  os:marshalInt32(self.choose_index)
end
function SSyncConstellationCards:unmarshal(os)
  self.cards = ConstellationCards.new()
  self.cards:unmarshal(os)
  self.choose_index = os:unmarshalInt32()
end
function SSyncConstellationCards:sizepolicy(size)
  return size <= 65535
end
return SSyncConstellationCards
