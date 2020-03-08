local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local HallInfo = Lplus.Class(CUR_CLASS_NAME)
local def = HallInfo.define
def.field("number").round = 0
def.field("number").roleNum = 0
def.field("boolean").bPreparing = true
def.field("number").stageEndTime = 0
def.final("number", "number", "boolean", "number", "=>", HallInfo).New = function(round, roleNum, bPreparing, stageEndTime)
  local hallInfo = HallInfo()
  hallInfo:Update(round, roleNum, bPreparing, stageEndTime)
  return hallInfo
end
def.method("number", "number", "boolean", "number").Update = function(self, round, roleNum, bPreparing, stageEndTime)
  self.round = round
  self.roleNum = roleNum
  self.bPreparing = bPreparing
  self.stageEndTime = stageEndTime
  warn("[HallInfo:Update] round, roleNum, bPreparing, stageEndTime:", round, roleNum, bPreparing, os.date("%c", stageEndTime))
end
return HallInfo.Commit()
