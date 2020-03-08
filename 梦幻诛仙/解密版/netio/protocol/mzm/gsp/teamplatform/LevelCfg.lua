local OctetsStream = require("netio.OctetsStream")
local LevelCfg = class("LevelCfg")
function LevelCfg:ctor(levelLow, levelHigh)
  self.levelLow = levelLow or nil
  self.levelHigh = levelHigh or nil
end
function LevelCfg:marshal(os)
  os:marshalInt32(self.levelLow)
  os:marshalInt32(self.levelHigh)
end
function LevelCfg:unmarshal(os)
  self.levelLow = os:unmarshalInt32()
  self.levelHigh = os:unmarshalInt32()
end
return LevelCfg
