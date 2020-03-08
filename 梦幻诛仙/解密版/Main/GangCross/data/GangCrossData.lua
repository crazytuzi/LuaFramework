local Lplus = require("Lplus")
local Json = require("Utility.json")
local GangCrossData = Lplus.Class("GangCrossData")
local def = GangCrossData.define
local instance
def.const("table").BattleState = {
  NORMAL = 1,
  PREPAIR = 2,
  FIGHT = 3
}
def.field("userdata").gangId = nil
def.field("number").gangTitle = 0
def.field("number").competeIndex = 0
def.field("table").fightInfo = nil
def.field("table").resultWinLoss = nil
def.field("boolean").CrossGangBattleState = false
def.field("number").gangCrossState = 1
def.field("boolean").isMatchState = false
def.static("=>", GangCrossData).Instance = function()
  if not instance then
    instance = GangCrossData()
  end
  return instance
end
def.method().InitData = function(self)
end
def.method().OnReset = function(self)
  self.gangId = nil
  self.fightInfo = nil
  self.competeIndex = 0
  self.resultWinLoss = nil
  self.CrossGangBattleState = false
end
def.method("=>", "boolean").getCrossGangBattleState = function(self)
  return self.CrossGangBattleState
end
def.method("boolean").setCrossGangBattleState = function(self, state)
  self.CrossGangBattleState = state
end
def.method("=>", "boolean").HasGang = function(self)
  return self.gangId ~= nil
end
def.method("=>", "userdata").GetGangId = function(self)
  return self.gangId
end
def.method("userdata").SetGangId = function(self, gangId)
  self.gangId = gangId
end
def.method("=>", "number").GetGangTitle = function(self)
  return self.gangTitle
end
def.method("number").SetGangTitle = function(self, gangTitle)
  self.gangTitle = gangTitle
end
def.method("=>", "number").GetCompeteIndex = function(self)
  return self.competeIndex
end
def.method("number").SetCompeteIndex = function(self, index)
  self.competeIndex = index
end
def.method("=>", "table").GetResultWinLoss = function(self)
  return self.resultWinLoss
end
def.method("table").SetResultWinLoss = function(self, resultWinLoss)
  self.resultWinLoss = resultWinLoss
end
def.method("=>", "table").GetRoleFightInfo = function(self)
  return self.fightInfo or {}
end
def.method("table").SetRoleFightInfo = function(self, fightInfo)
  self.fightInfo = fightInfo
end
def.method("=>", "number").GetGangCrossState = function(self)
  return self.gangCrossState
end
def.method("number").SetGangCrossState = function(self, state)
  self.gangCrossState = state
end
def.method("=>", "boolean").IsMatchState = function(self)
  return self.isMatchState
end
def.method("boolean").SetMatchState = function(self, state)
  self.isMatchState = state
end
return GangCrossData.Commit()
