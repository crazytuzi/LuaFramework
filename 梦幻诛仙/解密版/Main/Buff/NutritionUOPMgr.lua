local Lplus = require("Lplus")
local NutritionUOPMgr = Lplus.Class("NutritionUOPMgr")
local NutritionMgr = require("Main.Buff.NutritionMgr")
local ProtectionFactory = import(".UseOutProtections.ProtectionFactory")
local def = NutritionUOPMgr.define
local instance
def.static("=>", NutritionUOPMgr).Instance = function()
  if instance == nil then
    instance = NutritionUOPMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, NutritionUOPMgr.OnLeaveFight)
end
def.static("table", "table").OnLeaveFight = function(params, context)
  local isHeroDead = params.IsDead or false
  GameUtil.AddGlobalLateTimer(true, 0, function()
    local protection = instance:GetProtection(isHeroDead)
    if protection then
      protection:TakeProtections()
    end
  end)
end
def.method("boolean", "=>", "table").GetProtection = function(self, isHeroDead)
  if not isHeroDead then
    return nil
  end
  if NutritionMgr.Instance():GetCurNutrition() > 0 then
    return nil
  end
  if self:IsHeroOnHooking() then
    return ProtectionFactory.Instance():CreateProtection(ProtectionFactory.ProtectionType.OnHook)
  end
  if self:IsHeroHaveZhenYaoTask() then
    return ProtectionFactory.Instance():CreateProtection(ProtectionFactory.ProtectionType.ZhenYaoActivity)
  end
  return nil
end
def.method("=>", "boolean").IsHeroOnHooking = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local isInOnHookMap = require("Main.OnHook.OnHookData").IsOnHookMap(mapId)
  if isInOnHookMap then
    return true
  end
  return false
end
def.method("=>", "boolean").IsHeroHaveZhenYaoTask = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local aceptable = true
  local acepted = true
  local finished = false
  local value = taskInterface:HasTaskByGraphID(constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID, aceptable, acepted, finished)
  if value == false then
    local finished = true
    value = taskInterface:HasTaskByGraphID(constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID, aceptable, acepted, finished)
  end
  return value
end
return NutritionUOPMgr.Commit()
