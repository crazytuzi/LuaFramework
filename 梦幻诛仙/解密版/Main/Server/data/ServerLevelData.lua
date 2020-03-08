local Lplus = require("Lplus")
local ServerLevelData = Lplus.Class("ServerLevelData")
local def = ServerLevelData.define
def.field("number").level = 0
def.field("userdata").startTime = nil
def.field("userdata").upgradeTime = nil
def.field("boolean").reachMaxLevel = false
def.field("number").serverOpenTime = 0
def.method("table").RawSet = function(self, data)
  self.level = data.level
  self.startTime = data.startTime
  self.upgradeTime = data.upgradeTime or Int64.new(0)
  self.reachMaxLevel = data.ismaxlevel == 1 and true or false
end
return ServerLevelData.Commit()
