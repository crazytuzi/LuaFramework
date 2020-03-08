local OctetsStream = require("netio.OctetsStream")
local Fighter = require("netio.protocol.mzm.gsp.fight.Fighter")
local PlayChangeFighter = class("PlayChangeFighter")
function PlayChangeFighter:ctor(fighterid, changeFighterid, fighter)
  self.fighterid = fighterid or nil
  self.changeFighterid = changeFighterid or nil
  self.fighter = fighter or Fighter.new()
end
function PlayChangeFighter:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.changeFighterid)
  self.fighter:marshal(os)
end
function PlayChangeFighter:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.changeFighterid = os:unmarshalInt32()
  self.fighter = Fighter.new()
  self.fighter:unmarshal(os)
end
return PlayChangeFighter
