local Lplus = require("Lplus")
local InteractData = require("Main.Shitu.interact.data.InteractData")
local InteractUtils = require("Main.Shitu.interact.InteractUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local InteractProtocols
local InteractMgr = Lplus.Class("InteractMgr")
local def = InteractMgr.define
local instance
def.static("=>", InteractMgr).Instance = function()
  if instance == nil then
    instance = InteractMgr()
  end
  return instance
end
def.method().Init = function(self)
  InteractProtocols = require("Main.Shitu.interact.InteractProtocols")
  InteractProtocols.RegisterProtocols()
  InteractData.Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, InteractMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, InteractMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_BTN_CLICK, InteractMgr._OnMasterTaskClicked)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, InteractMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, InteractMgr.OnRoleActiveChange)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, InteractMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsFeatrueTaskOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SHITU_TASK) then
    result = false
    if bToast then
      Toast(textRes.Shitu.Interact.FEATRUE_TASK_NOT_OPEN)
    end
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueActiveOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SHITU_ACTIVE_VALUE) then
    result = false
    if bToast then
      Toast(textRes.Shitu.Interact.FEATRUE_ACTIVE_NOT_OPEN)
    end
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueRecommandOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SHITU_RECOMMEND) then
    result = false
    if bToast then
      Toast(textRes.Shitu.Interact.FEATRUE_RECOMMAND_NOT_OPEN)
    end
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  if self:IsFeatrueTaskOpen(false) then
    return self:_HaveUnAssignedTask() or self:_HaveUnFinishedTask() or self:_HavePrenticeTaskAward()
  else
    return false
  end
end
def.method("=>", "boolean")._HaveUnAssignedTask = function(self)
  local ShituData = require("Main.Shitu.ShituData")
  local prenticeCount = ShituData.Instance():GetNowApprenticeCount()
  if prenticeCount > 0 then
    local result = false
    for idx = 1, prenticeCount do
      local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(idx)
      local masterTaskInfo = prenticeInfo and InteractData.Instance():GetMasterTaskInfo(prenticeInfo.roleId)
      if masterTaskInfo and masterTaskInfo:HaveUnAssignedTask() then
        result = true
        break
      end
    end
    return result
  else
    return false
  end
end
def.method("=>", "boolean")._HavePrenticeTaskAward = function(self)
  local ShituData = require("Main.Shitu.ShituData")
  local prenticeCount = ShituData.Instance():GetNowApprenticeCount()
  if prenticeCount > 0 then
    local result = false
    for idx = 1, prenticeCount do
      local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(idx)
      local masterTaskInfo = prenticeInfo and InteractData.Instance():GetMasterTaskInfo(prenticeInfo.roleId)
      if masterTaskInfo and masterTaskInfo:HavePrenticeTaskAward() then
        result = true
        break
      end
    end
    return result
  else
    return false
  end
end
def.method("=>", "boolean")._HaveUnFinishedTask = function(self)
  local result = false
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  if masterTaskInfo then
    result = masterTaskInfo:HaveUnFinishedTask()
  end
  return result
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  InteractData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_SHITU_TASK then
    if false == param.open then
    else
    end
  elseif param.feature == ModuleFunSwitchInfo.TYPE_SHITU_ACTIVE_VALUE then
    if false == param.open then
    else
    end
  else
    if param.feature ~= ModuleFunSwitchInfo.TYPE_SHITU_RECOMMEND or false == param.open then
    else
    end
  end
end
def.static("table", "table")._OnMasterTaskClicked = function(param, context)
  if InteractMgr.Instance():IsFeatrueTaskOpen(true) then
    local ShituData = require("Main.Shitu.ShituData")
    local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
    if ShituData.Instance():GetNowApprenticeCount() > 0 then
      InteractTaskPanel.Instance():ShowPanel(InteractTaskPanel.NodeId.Master)
    else
      InteractTaskPanel.Instance():ShowPanel(InteractTaskPanel.NodeId.Prentice)
    end
  end
end
def.static("table", "table").OnNewDay = function(param, context)
  if InteractMgr.Instance():IsFeatrueTaskOpen(false) then
    InteractData.Instance():OnNewDay(param, context)
    InteractProtocols.SendCGetShiTuTaskInfoReq()
    InteractProtocols.SendCGetShiTuActiveInfoReq()
  end
end
def.static("table", "table").OnRoleActiveChange = function(param, context)
  if InteractMgr.Instance():IsFeatrueActiveOpen(false) then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityInterface = ActivityInterface.Instance()
    InteractData.Instance():SynShiTuActiveUpdate(_G.GetMyRoleID(), activityInterface._currentTotalActive)
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, nil)
  else
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
InteractMgr.Commit()
return InteractMgr
