local Lplus = require("Lplus")
local BattleBaseInfo = Lplus.Class("BattleBaseInfo")
local def = BattleBaseInfo.define
def.field("table").scores = nil
def.static("=>", BattleBaseInfo).new = function()
  local recorder = BattleBaseInfo()
  recorder.scores = {}
  return recorder
end
def.method("number", "table").SetBaseInfo = function(self, teamId, baseInfo)
  self.scores[teamId] = {
    score = baseInfo.totalSource
  }
end
def.method("number", "=>", "table").GetBaseInfo = function(self, teamId)
  return self.scores[teamId]
end
return BattleBaseInfo.Commit()
