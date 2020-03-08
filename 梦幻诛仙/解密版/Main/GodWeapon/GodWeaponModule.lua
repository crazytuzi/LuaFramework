local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local GodWeaponModule = Lplus.Extend(ModuleBase, "GodWeaponModule")
local instance
local def = GodWeaponModule.define
def.static("=>", GodWeaponModule).Instance = function()
  if instance == nil then
    instance = GodWeaponModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.GodWeapon.BreakOutMgr").Instance():Init()
  require("Main.GodWeapon.JewelMgr").Instance():Init()
  require("Main.GodWeapon.DecorationMgr").Instance():Init()
  require("Main.GodWeapon.JewelTransMgr").Instance():Init()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GODWEAPON_CLICK, GodWeaponModule.OnMainUIBtnClick)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GodWeaponModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, GodWeaponModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, GodWeaponModule.onSynServerLevel)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, GodWeaponModule.onTaskInfoChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_FinishTask, GodWeaponModule.OnTaskFinished)
  Event.RegisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.USE_ITEM_LEVEL_UP, GodWeaponModule.OnUseItemLevelUp)
  Event.RegisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.USE_ITEM_STAGE_UP, GodWeaponModule.OnUseItemStageUp)
end
def.static("table", "table").OnMainUIBtnClick = function(p, c)
  GodWeaponModule.LaunchGodWeapon()
end
def.static("table", "table").OnUseItemStageUp = function(p, c)
  warn("[GodWeaponModule:OnUseItemStageUp] On Use Item StageUp.")
  GodWeaponModule.LaunchGodWeapon()
end
def.static("table", "table").OnUseItemLevelUp = function(p, c)
  warn("[GodWeaponModule:OnUseItemLevelUp] On Use Item LevelUp.")
  GodWeaponModule.LaunchGodWeapon()
end
def.static().LaunchGodWeapon = function()
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not GodWeaponModule.Instance():IsOpen(true) then
    return
  end
  local taskId = GodWeaponModule.GetGodWeaponTaskId()
  local graphID = constant.CSuperEquipmentConsts.GUIDE_TASK_MAP_ID
  if taskId == 0 then
    require("Main.GodWeapon.ui.UIGodWeaponBasic").Instance():ShowPanel(1)
  else
    Toast(textRes.GodWeapon.BreakOut.GODWEAPON_TASK)
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, graphID})
  end
end
def.static("=>", "number").GetGodWeaponTaskId = function()
  local TaskInterface = require("Main.task.TaskInterface")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local taskGraphId = constant.CSuperEquipmentConsts.GUIDE_TASK_MAP_ID
  local taskInfos = TaskInterface.Instance():GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == taskGraphId and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        return taskId
      end
    end
  end
  return 0
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_SUPER_EQUIPMENT then
    warn("[GodWeaponModule:OnFunctionOpenChange] DispatchEvent GOD_WEAPON_FEATURE_CHANGE on idip TYPE_SUPER_EQUIPMENT change.")
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
  end
end
def.static("table", "table").OnHeroLevelUp = function(param, context)
  local lastLevel = param.lastLevel
  local curlevel = param.level
  if lastLevel and lastLevel < constant.CSuperEquipmentConsts.OPEN_ROLE_LEVEL and curlevel and curlevel >= constant.CSuperEquipmentConsts.OPEN_ROLE_LEVEL then
    warn("[GodWeaponModule:OnHeroLevelUp] DispatchEvent GOD_WEAPON_FEATURE_CHANGE, lastLevel&curlevel:", lastLevel, curlevel)
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
  end
end
def.static("table", "table").onSynServerLevel = function(param, context)
  warn("[GodWeaponModule:onSynServerLevel] DispatchEvent GOD_WEAPON_FEATURE_CHANGE on sync server level.")
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
end
def.static("table", "table").onTaskInfoChanged = function(param, context)
  if param then
    local taskID = param[1]
    local graphID = param[2]
    if taskID == constant.CSuperEquipmentConsts.GUIDE_TASK_ID and graphID == constant.CSuperEquipmentConsts.GUIDE_TASK_MAP_ID then
      warn("[GodWeaponModule:onTaskInfoChanged] godweapon task change!")
      Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, nil)
    end
  end
end
def.static("table", "table").OnTaskFinished = function(param, context)
  local taskID = param[1]
  local graphID = param[2]
  if taskID == constant.CSuperEquipmentConsts.GUIDE_TASK_ID and graphID == constant.CSuperEquipmentConsts.GUIDE_TASK_MAP_ID then
    warn("[GodWeaponModule:OnTaskFinished] godweapon task finished!")
    require("Main.GodWeapon.ui.UIGodWeaponBasic").Instance():ShowPanel(1)
  end
end
def.method("=>", "boolean").NeedReddot = function(self)
  if not self:IsOpen(false) then
    return false
  else
    local taskId = GodWeaponModule.GetGodWeaponTaskId()
    local graphID = constant.CSuperEquipmentConsts.GUIDE_TASK_MAP_ID
    if taskId == 0 then
      return false
    else
      return true
    end
  end
end
def.method("=>", "boolean").IsFunctionOpen = function(self)
  return self:IsOpen(false)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  elseif false == self:IsConditionSatisfied(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SUPER_EQUIPMENT) then
    result = false
    if bToast then
      Toast(textRes.GodWeapon.BreakOut.FEATRUE_IDIP_NOT_OPEN)
    end
  end
  return result
end
def.method("boolean", "=>", "boolean").IsConditionSatisfied = function(self, bToast)
  local result = true
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local serverLevel = serverLevelData.level
  if serverLevel < constant.CSuperEquipmentConsts.OPEN_SERVER_LEVEL then
    if bToast then
      Toast(string.format(textRes.GodWeapon.BreakOut.FEATRUE_CLOSE_LOW_SERVER_LEVEL, constant.CSuperEquipmentConsts.OPEN_SERVER_LEVEL))
    end
    return false
  end
  if _G.GetHeroProp().level < constant.CSuperEquipmentConsts.OPEN_ROLE_LEVEL then
    if bToast then
      Toast(string.format(textRes.GodWeapon.BreakOut.FEATRUE_CLOSE_LOW_ROLE_LEVEL, constant.CSuperEquipmentConsts.OPEN_ROLE_LEVEL))
    end
    return false
  end
  return result
end
return GodWeaponModule.Commit()
