local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GoalPanelNodeBase = import(".GoalPanelNodeBase")
local PersonalGoalNode = Lplus.Extend(GoalPanelNodeBase, MODULE_NAME)
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local PetInterface = require("Main.Pet.Interface")
local Vector = require("Types.Vector")
local def = PersonalGoalNode.define
def.override().OnShow = function(self)
  self:UpdateUI()
  self:ResetPosition()
  Event.RegisterEventWithContext(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfPersonalsGoalChanged, PersonalGoalNode.OnScheduleOfPersonalsGoalChanged, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfPersonalsGoalChanged, PersonalGoalNode.OnScheduleOfPersonalsGoalChanged)
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateGoals()
end
def.method().UpdateTitle = function(self)
  local round = GangDungeonModule.Instance():GetClampedPersonalGoalRound()
  local maxRound = GangDungeonUtils.GetConstant("PersonGoalCount")
  self:SetTitle(textRes.GangDungeon[21]:format(round, maxRound))
end
def.method().UpdateGoals = function(self)
  local goals = GangDungeonModule.Instance():GetPersonalGoals() or {}
  local hasFinished = GangDungeonModule.Instance():HasPersonalGoalAllRoundFinished()
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
    viewGoal.hasFinished = hasFinished
    table.insert(viewGoals, viewGoal)
  end
  self:FillList(viewGoals)
end
def.method("table").OnScheduleOfPersonalsGoalChanged = function(self)
  self:UpdateTitle()
  self:UpdateGoals()
end
return PersonalGoalNode.Commit()
