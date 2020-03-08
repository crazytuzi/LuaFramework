local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Achievement = Lplus.Class(CUR_CLASS_NAME)
local GrowUtils = import("..GrowUtils")
local Operation = import("..Operations.Operation")
local GoalType = require("consts.mzm.gsp.grow.confbean.GoalType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = Achievement.define
def.field("number").id = 0
def.field("number").state = 0
def.field("number").type = 0
def.field("number").unlockLevel = 0
def.field("string").name = ""
def.field("string").description = ""
def.field("number").iconId = 0
def.field("number").rank = 0
def.field("number").clientOperId = 0
def.field("table").parameters = nil
def.field(Operation).operation = nil
def.field("boolean")._IS_DATA_INITED_ = false
def.method("number").Init = function(self, id)
  self.id = id
end
def.virtual().InitData = function(self)
  if self._IS_DATA_INITED_ then
    return
  end
  local cfg = GrowUtils.GetGrowAchievementCfg(self.id)
  if cfg == nil then
    return
  end
  self.unlockLevel = self:GetUnlockLevel(cfg)
  self.type = cfg.guideType
  self.iconId = cfg.iconId
  self.parameters = cfg.parameters
  self.rank = cfg.rank or 0
  self.clientOperId = cfg.clientOperId
  local parameterStrs = {}
  local ParametersFactory = import(".Parameters.ParametersFactory", CUR_CLASS_NAME)
  for i, v in ipairs(cfg.parameters) do
    local parameter = ParametersFactory.CreateParameter(v.type)
    table.insert(parameterStrs, parameter:ToString(v.parameter))
  end
  for i = 1, 5 do
    table.insert(parameterStrs, "[no value]")
  end
  self.name = string.format(cfg.title, unpack(parameterStrs))
  self.description = string.format(cfg.goalDes, unpack(parameterStrs))
  self._IS_DATA_INITED_ = true
end
def.method("table", "=>", "number").GetUnlockLevel = function(self, cfg)
  local level = 1
  if cfg.goalType == GoalType.ACTIVITY_JOIN then
    local activityId = cfg.parameters[1].parameter
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    level = not activityCfg or activityCfg.levelMin or level
  else
    level = cfg.openLevel
  end
  if not (level > 0) or not level then
    level = 1
  end
  return level
end
def.virtual("=>", "boolean").Go = function(self)
  local GoalGuideType = require("consts.mzm.gsp.grow.confbean.GoalGuideType")
  local heroLevel = _G.GetHeroProp().level
  if heroLevel < self.unlockLevel and self.type ~= GoalGuideType.PATH_FINDING_MAIN then
    Toast(string.format(textRes.Grow.Achievement[2], self.unlockLevel))
    return false
  end
  return GrowUtils.ApplyOperation(self.clientOperId)
end
return Achievement.Commit()
