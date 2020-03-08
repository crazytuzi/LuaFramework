local Fight = require("netio.protocol.mzm.gsp.fight.Fight")
local SEnterFightBrd = class("SEnterFightBrd")
SEnterFightBrd.TYPEID = 12594189
function SEnterFightBrd:ctor(fight)
  self.id = 12594189
  self.fight = fight or Fight.new()
end
function SEnterFightBrd:marshal(os)
  self.fight:marshal(os)
end
function SEnterFightBrd:unmarshal(os)
  self.fight = Fight.new()
  self.fight:unmarshal(os)
end
function SEnterFightBrd:sizepolicy(size)
  return size <= 65535
end
return SEnterFightBrd
