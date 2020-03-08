local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local DailyGoalVDMgr = Lplus.Class(MODULE_NAME)
local DailyGoalMgr = import("..DailyGoalMgr")
local GrowUtils = import("..GrowUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
local def = DailyGoalVDMgr.define
local instance
def.static("=>", DailyGoalVDMgr).Instance = function()
  if instance == nil then
    instance = DailyGoalVDMgr()
  end
  return instance
end
def.method("=>", "table").GetDailyGoalsViewData = function(self)
  local goalsList = DailyGoalMgr.Instance():GetGoalsList()
  local viewData = {}
  for i, goal in ipairs(goalsList) do
    local v = self:DailyGoalToViewData(goal)
    table.insert(viewData, v)
  end
  return viewData
end
def.method("number", "=>", "table").GetDailyGoalViewData = function(self, goalId)
  local goal = DailyGoalMgr.Instance():GetGoal(goalId)
  return self:DailyGoalToViewData(goal)
end
def.method("table", "=>", "table").DailyGoalToViewData = function(self, goal)
  local GrowConsts = require("netio.protocol.mzm.gsp.grow.GrowConsts")
  local cfg = GrowUtils.GetDailyGoalCfg(goal.id)
  if cfg == nil then
    return nil
  end
  local itemList = {}
  goal.award = goal.award or {}
  local itemList = ItemUtils.GetAwardItemsFromAwardBean(goal.award)
  local viewData = {
    id = goal.id,
    rank = cfg.rank,
    name = string.format(cfg.goalDes, cfg.num),
    curValue = goal.progress,
    totalValue = cfg.num,
    isAwarded = goal.state == GrowConsts.ST_HAND_UP,
    isFinished = goal.state ~= GrowConsts.ST_ON_GOING,
    awardItemList = itemList
  }
  return viewData
end
return DailyGoalVDMgr.Commit()
