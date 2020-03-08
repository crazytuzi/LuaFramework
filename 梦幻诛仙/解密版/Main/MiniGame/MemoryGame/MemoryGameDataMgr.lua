local Lplus = require("Lplus")
local MemoryGameDataMgr = Lplus.Class("MemoryGameDataMgr")
local MemoryStatusData = require("Main.MiniGame.MemoryGame.data.MemoryStatusData")
local def = MemoryGameDataMgr.define
local instance
def.field("number").activityId = 0
def.field("number").memoryCompetitionCfgId = 0
def.field("table").memoryMap = nil
def.field("table").seekingHelpRoleIds = nil
def.field(MemoryStatusData).memoryStatus = nil
def.static("=>", MemoryGameDataMgr).Instance = function()
  if instance == nil then
    instance = MemoryGameDataMgr()
  end
  return instance
end
def.method("table").RawSetBaiscData = function(self, data)
  self.activityId = data.activity_cfg_id or self.activityId
  self.memoryCompetitionCfgId = data.memory_competition_cfg_id or self.memoryCompetitionCfgId
end
def.method("table").SetMemoryStartData = function(self, data)
  self:RawSetBaiscData(data)
  self.memoryMap = data.mapping_date
end
def.method("table").SetMemoryGameStatus = function(self, status)
  self:RawSetBaiscData(status)
  if self.memoryStatus == nil then
    self.memoryStatus = MemoryStatusData()
  end
  self.memoryStatus:RawSet(status)
end
def.method("=>", "number").GetCurGameCfgId = function(self)
  return self.memoryCompetitionCfgId
end
def.method("=>", "table").GetCurGameMemoryMap = function(self)
  return self.memoryMap
end
def.method("=>", "table").GetCurGameStatus = function(self)
  return self.memoryStatus
end
def.method("userdata").AddSeekingHelpRoleId = function(self, roleId)
  if self.seekingHelpRoleIds == nil then
    self.seekingHelpRoleIds = {}
  end
  self.seekingHelpRoleIds[roleId:tostring()] = true
end
def.method("userdata", "=>", "boolean").IsPlayerSeekingHelp = function(self, roleId)
  if self.seekingHelpRoleIds == nil then
    return false
  end
  return self.seekingHelpRoleIds[roleId:tostring()] == true
end
def.method().ClearRoundData = function(self)
  self.seekingHelpRoleIds = nil
end
def.method().Reset = function(self)
  self.activityId = 0
  self.memoryCompetitionCfgId = 0
  self.memoryMap = nil
  self.memoryStatus = nil
  self.seekingHelpRoleIds = nil
end
return MemoryGameDataMgr.Commit()
