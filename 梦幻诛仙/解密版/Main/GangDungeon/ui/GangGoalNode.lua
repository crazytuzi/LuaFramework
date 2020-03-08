local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GoalPanelNodeBase = import(".GoalPanelNodeBase")
local GangGoalNode = Lplus.Extend(GoalPanelNodeBase, MODULE_NAME)
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local PetInterface = require("Main.Pet.Interface")
local Vector = require("Types.Vector")
local def = GangGoalNode.define
def.override().OnShow = function(self)
  self:UpdateUI()
  self:ResetPosition()
  Event.RegisterEventWithContext(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfGangsGoalChanged, GangGoalNode.OnScheduleOfGangsGoalChanged, self)
  Event.RegisterEventWithContext(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.DungeonStageChanged, GangGoalNode.OnDungeonStageChanged, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfGangsGoalChanged, GangGoalNode.OnScheduleOfGangsGoalChanged)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.DungeonStageChanged, GangGoalNode.OnDungeonStageChanged)
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateGoals()
end
def.method().UpdateTitle = function(self)
  if self:IsChallengeBossStage() then
    self:SetTitle(textRes.GangDungeon[23])
  else
    self:SetTitle(textRes.GangDungeon[22])
  end
end
def.method().UpdateGoals = function(self)
  if self:IsChallengeBossStage() then
    self:UpdateBossGoals()
  else
    self:UpdateGangGoals()
  end
end
def.method().UpdateBossGoals = function(self)
  local goals = GangDungeonModule.Instance():GetBossGoals() or {}
  local viewGoals = {}
  for i, v in ipairs(goals) do
    local monsterId, num, total = v.monsterId, v.curNum, v.total
    local viewGoal = {cur = num}
    local monsterCfg = PetInterface.GetExplicitMonsterCfg(monsterId)
    if monsterCfg then
      viewGoal.name = monsterCfg.name
    else
      viewGoal.name = "$" .. monsterId
    end
    viewGoal.total = total
    table.insert(viewGoals, viewGoal)
  end
  self:FillList(viewGoals)
end
def.method().UpdateGangGoals = function(self)
  local goals = GangDungeonModule.Instance():GetGangGoals() or {}
  local viewGoals = {}
  for i, v in ipairs(goals) do
    local monsterId, num, total = v.monsterId, v.curNum, v.total
    local viewGoal = {cur = num}
    local monsterCfg = PetInterface.GetMonsterCfg(monsterId)
    if monsterCfg then
      viewGoal.name = monsterCfg.name
    else
      viewGoal.name = "$" .. monsterId
    end
    viewGoal.total = total
    table.insert(viewGoals, viewGoal)
  end
  self:FillList(viewGoals)
end
def.method("=>", "boolean").IsChallengeBossStage = function(self)
  local stage = GangDungeonModule.Instance():GetDungeonStage()
  return stage >= GangDungeonModule.DungeonStage.STG_KILL_BOSS
end
def.method("table").OnScheduleOfGangsGoalChanged = function(self)
  self:UpdateGoals()
end
def.method("table").OnDungeonStageChanged = function(self)
  self:UpdateUI()
end
return GangGoalNode.Commit()
