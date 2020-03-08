local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SoaringModule = Lplus.Extend(ModuleBase, "SoaringModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local TaskDeliveryByGraph = require("Main.task.TaskDeliveryByGraph")
local NPCInterface = require("Main.npc.NPCInterface")
local ModuleData = require("Main.Soaring.data.ModuleData")
local SoaringData = require("Main.Soaring.data.SoaringData")
local TaskGangChallenge = require("Main.Soaring.proxy.TaskGangChallenge")
local TaskRunningXuanGong = require("Main.Soaring.proxy.TaskRunningXuanGong")
local TaskTianCaiDiBao = require("Main.Soaring.proxy.TaskTianCaiDiBao")
local TaskZhuXianJianZhen = require("Main.Soaring.proxy.TaskZhuXianJianZhen")
local TaskWayOfCoatard = require("Main.Soaring.proxy.TaskWayOfCoatard")
local TaskQingYunAsked = require("Main.Soaring.proxy.TaskQingYunAsked")
local TaskAncientSeal = require("Main.Soaring.proxy.TaskAncientSeal")
local TaskYaoHunXianJi = require("Main.Soaring.proxy.TaskYaoHunXianJi")
local TaskYZXGMgr = require("Main.Soaring.TaskYZXGMgr")
local def = SoaringModule.define
local instance
local G_bFeatureOpen = false
local G_iActId = 0
local G_tblSubTasks = {}
local G_arrSubtasks = {}
local G_arrNPCIds = {}
local G_comFx, G_inComFx
local G_bHasPlayedEffect = false
def.field("table")._moduleCfgData = nil
def.field("table")._soaringCfgData = nil
def.field("number")._doingTaskId = 0
def.const("number").ACTFINISH_UI_DURATION = 5
def.const("number").TALK_DURATION = 8
def.const("number").MAX_TRY_NPC_TIME = 5
def.const("number").TRY_TALK_TIMEOUT = 0.5
local warn = function(...)
end
def.static("=>", SoaringModule).Instance = function()
  if instance == nil then
    instance = SoaringModule()
  end
  return instance
end
def.method().InitSubtaskData = function(self)
  SoaringModule.LoadSoaringModuleCfgData()
  self._soaringCfgData = SoaringData.Instance(self:GetActivityId())
  TaskGangChallenge.RegisterTaskClass()
  TaskQingYunAsked.RegisterTaskClass()
  TaskRunningXuanGong.RegisterTaskClass()
  TaskYaoHunXianJi.RegisterTaskClass()
  TaskWayOfCoatard.RegisterTaskClass()
  TaskZhuXianJianZhen.RegisterTaskClass()
  TaskAncientSeal.RegisterTaskClass()
  TaskTianCaiDiBao.RegisterTaskClass()
end
def.override().Init = function(self)
  self:InitSubtaskData()
  TaskYZXGMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SSynFightActivitySchedule", TaskGangChallenge.OnSSynFightActivitySchedule)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendFightActivityFail", TaskGangChallenge.OnSAttendFightActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitItemActivityFail", TaskAncientSeal.OnSAttendCommitItemActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitItemActivityFail", TaskTianCaiDiBao.OnSAttendCommitItemActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitItemActivitySuccess", TaskAncientSeal.OnSAttendCommitItemActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitItemActivitySuccess", TaskTianCaiDiBao.OnSAttendCommitItemActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitPetActivityFail", TaskYaoHunXianJi.OnSAttendCommitPetActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendCommitPetActivitySuccess", TaskYaoHunXianJi.OnSAttendCommitPetActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendZhuXianJianZhenActivityFail", TaskZhuXianJianZhen.OnSAttendZhuXianJianZhenActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SCommitItemInZhuXianJianZhenActivityFail", TaskZhuXianJianZhen.OnSCommitItemInZhuXianJianZhenActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SCommitItemInZhuXianJianZhenActivitySuccess", TaskZhuXianJianZhen.OnSCommitItemInZhuXianJianZhenActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SSynZhuXianJianZhenActivityStageInfo", TaskZhuXianJianZhen.OnSSynZhuXianJianZhenActivityStageInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SLeaveZhuXianJianZhenActivityMapFail", TaskZhuXianJianZhen.OnSLeaveZhuXianJianZhenActivityMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendTaskActivityFail", TaskWayOfCoatard.OnSAttendTaskActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendTaskActivitySuccess", TaskWayOfCoatard.OnSAttendTaskActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendQingYunZhiActivityFail", TaskQingYunAsked.OnSAttendQingYunZhiActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SAttendQingYunZhiActivitySuccess", TaskQingYunAsked.OnSAttendQingYunZhiActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SReportPlayFeiShengEffectFail", SoaringModule.OnSReportPlayFeiShengEffectFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SSynPlayFeiShengEffectInfo", SoaringModule.OnSSynPlayFeiShengEffectInfo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, SoaringModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, SoaringModule.OnNPCService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, SoaringModule.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SoaringModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, TaskZhuXianJianZhen.OnMapChange)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, SoaringModule.OnMapChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, TaskZhuXianJianZhen.OnCrossDay)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, TaskZhuXianJianZhen.OnCrossDay)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, TaskGangChallenge.OnCrossDay)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, TaskGangChallenge.OnCrossDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskZhuXianJianZhen.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskGangChallenge.OnResetFightActivitySchedule)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SoaringModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, SoaringModule.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, SoaringModule.OnServeLvChange)
  Event.RegisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.DISPLAY_MAP_EFF, SoaringModule.OnDisplayMapEffect)
  local taskGraphId = self._soaringCfgData:GetTaskGraphId()
  TaskDeliveryByGraph.RegisteTaskGraph(taskGraphId, SoaringModule.OnSoaringTaskGraph)
  ModuleBase.Init(self)
end
def.static("number", "table").RegisterTaskClass = function(actId, Class)
  G_tblSubTasks[actId] = Class
  table.insert(G_arrSubtasks, actId)
end
def.static("number", "=>", "table").GetTaskClassByActId = function(actId)
  if actId == nil then
    return nil
  end
  return G_tblSubTasks[actId]
end
def.static("=>", "table").GetSubtaskArray = function()
  return G_arrSubtasks
end
def.static("=>", "table").GetArrayNPCIds = function()
  if G_arrNPCIds == nil or #G_arrNPCIds == 0 then
    local arrActIds = SoaringModule.GetSubtaskArray()
    local countSubtask = SoaringModule.Instance():GetSubtaskCount()
    for i = 1, countSubtask do
      local actId = arrActIds[i]
      local ClassTask = SoaringModule.GetTaskClassByActId(actId)
      local actCfgData = ClassTask.FastGetCfgData(actId)
      table.insert(G_arrNPCIds, actCfgData.npc_id)
    end
  end
  return G_arrNPCIds
end
def.static("=>", "table").GetTblOfAllSubtasks = function()
  return G_tblSubTasks
end
def.static("number", "=>", "boolean").GetActivityCompletedByActId = function(actId)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityInfo = activityInterface:GetActivityInfo(actId)
  local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
  if activityInfo ~= nil and activityInfo.count >= actCfgInfo.limitCount then
    return true
  end
  return false
end
def.static("=>", "boolean").IsSoaringActComplete = function()
  local soaringActId = SoaringModule.Instance():GetActivityId()
  local bActCompleted = SoaringModule.GetActivityCompletedByActId(soaringActId)
  return bActCompleted
end
def.method("=>", "number").GetSubtaskCount = function(self)
  return self._soaringCfgData:CountSubtask()
end
def.method("=>", "number").GetActivityId = function()
  if G_iActId == 0 then
    SoaringModule.LoadSoaringModuleCfgData()
  end
  return G_iActId
end
def.method("=>", "table").GetActivityCfg = function(self)
  return self._soaringCfgData
end
def.static().LoadSoaringModuleCfgData = function()
  local module_id = Feature.TYPE_FEI_SHENG_99
  local self = SoaringModule.Instance()
  self._moduleCfgData = ModuleData.Instance()
  G_iActId = self._moduleCfgData:GetActivityCfgIdByModuleId(module_id)
end
def.static("=>", "boolean").GetFeatureOpen = function()
  return G_bFeatureOpen
end
def.static("boolean").SetFeatureOpen = function(bOpen)
  G_bFeatureOpen = bOpen
  SoaringModule.UpdateActivityInterface(bOpen)
end
def.static("table", "table").OnActivityTodo = function(p, context)
  if not SoaringModule.GetFeatureOpen() then
    return
  end
  local self = SoaringModule.Instance()
  if p[1] == self:GetActivityId() then
    local soaringCfgData = self:GetActivityCfg()
    local mapId = soaringCfgData:GetMapId()
    local pos = soaringCfgData:GetTaskMapTransferCoordinate()
    local targetPos = require("netio.protocol.mzm.gsp.map.Location").new()
    targetPos.x = pos.x
    targetPos.y = pos.y
    gmodule.moduleMgr:GetModule(ModuleId.HERO):EnterMap(mapId, targetPos)
    SoaringModule.ShowUISoaring()
  else
    local TaskClass = SoaringModule.GetTaskClassByActId(p[1])
    if TaskClass ~= nil then
      TaskClass.Instance():OnTodoTask()
    end
  end
end
def.static("table", "table").OnNPCService = function(tbl, context)
  if not SoaringModule.GetFeatureOpen() then
    return
  end
  local srvcId = tbl[1]
  local npcId = tbl[2]
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  for _, v in pairs(tblSubtasks) do
    local bDealed = v.Instance():OnDoTask(npcId, srvcId)
    if bDealed then
      break
    end
  end
end
def.static("=>", "boolean").CanJoinActivity = function()
  if not SoaringModule.IsLevelEnough() then
    local soaringCfg = SoaringModule.Instance():GetActivityCfg()
    Toast(string.format(textRes.Soaring[1], soaringCfg:GetMinLevel()))
    return false
  end
  if not SoaringModule.IsServerLvEnough() then
    Toast(textRes.Soaring[2])
    return false
  end
  return true
end
local SHOWUI_DELAY = 2
def.static("table", "table").OnActivityInfoChanged = function(p, context)
  if not SoaringModule.GetFeatureOpen() then
    return
  end
  if not SoaringModule.IsServerLvEnough() or not SoaringModule.IsLevelEnough() then
    return
  end
  local actId = p[1]
  local soaringActId = SoaringModule.Instance():GetActivityId()
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  local souringCfg = SoaringModule.Instance():GetActivityCfg()
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  local bIsInSoaringMap = curMapId == souringCfg:GetMapId()
  local countCompleteSubtask = SoaringModule.CountCompletedSubtask()
  for _, v in pairs(tblSubtasks) do
    if v.ACTIVITY_ID == actId then
      if SoaringModule.GetActivityCompletedByActId(actId) then
        v.Instance():DisplayActFinishUI()
        v.SetActInfoChange(true)
        if bIsInSoaringMap then
          v.Instance():UpdateNPCState()
          v.Instance():DisplayMapEffect()
        end
      end
      break
    end
  end
  if actId == soaringActId then
    local bActCompleted = SoaringModule.GetActivityCompletedByActId(soaringActId)
    if bActCompleted and countCompleteSubtask == SoaringModule.Instance():GetSubtaskCount() then
      if not bIsInSoaringMap then
        SoaringModule.SaveSoaringState(false)
        return
      end
      SoaringModule.PlaySoaringCompleteEff()
      SoaringModule.SaveSoaringState(true)
      return
    end
  end
  if countCompleteSubtask == SoaringModule.Instance():GetSubtaskCount() then
    if not bIsInSoaringMap then
      SoaringModule.SaveSoaringState(false)
      return
    end
    SoaringModule.PlaySoaringCompleteEff()
    SoaringModule.SaveSoaringState(true)
  end
end
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local feishengEffectStat = "feishengEffectStat"
def.static("boolean").SaveSoaringState = function(bHasDisplayed)
  if bHasDisplayed then
    local actId = SoaringModule.Instance():GetActivityId()
    SoaringModule.SendReportPlayEffect(actId)
  end
end
def.static("=>", "boolean").ReadSoaringState = function()
  return G_bHasPlayedEffect
end
def.static().PlaySoaringCompleteEff = function()
  SoaringModule.ShowUISoaring()
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  for _, v in pairs(tblSubtasks) do
    v.Instance():UpdateNPCState()
  end
end
local GUIFxMan = require("Fx.GUIFxMan")
def.static("table", "table").OnDisplayMapEffect = function(p, context)
  _G.GameUtil.AddGlobalTimer(1, true, function()
    SoaringModule.RemoveMapEffect(G_inComFx or 0)
    SoaringModule.DisplayActCompleteEffect()
    local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
    for _, v in pairs(tblSubtasks) do
      v.Instance():RemoveMapEffect()
    end
    local souringCfg = SoaringModule.Instance():GetActivityCfg()
    local UIEffectId = souringCfg:GetActCompleteUIEffect()
    local effectPath = _G.GetEffectRes(UIEffectId)
    local effectName = "feishengUIeffect"
    GUIFxMan.Instance():Play(effectPath.path, effectName, 0, 0, 2, true)
  end)
end
def.static("=>", "number").CountCompletedSubtask = function()
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  local count = 0
  for _, v in pairs(tblSubtasks) do
    if SoaringModule.GetActivityCompletedByActId(v.ACTIVITY_ID) then
      count = count + 1
    end
  end
  return count
end
def.static("table", "table").OnMapChange = function(p, context)
  local mapId = p[1]
  local oldMapId = p[2]
  local souringCfg = SoaringModule.Instance():GetActivityCfg()
  local cfgMapId = souringCfg:GetMapId()
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  if mapId == cfgMapId then
    local actCfgId = souringCfg:GetActivityId()
    local bActCompleted = SoaringModule.GetActivityCompletedByActId(actCfgId)
    for _, v in pairs(tblSubtasks) do
      v.Instance():UpdateNPCState()
    end
    if bActCompleted then
      local bHasDisplayed = SoaringModule.ReadSoaringState()
      if not bHasDisplayed then
        for _, v in pairs(tblSubtasks) do
          v.Instance():DisplayMapEffect()
        end
        SoaringModule.DisplayActImcompleteEffect()
        SoaringModule.PlaySoaringCompleteEff()
        SoaringModule.SaveSoaringState(true)
      end
      return
    else
      SoaringModule.DisplayActImcompleteEffect()
    end
    for _, v in pairs(tblSubtasks) do
      v.Instance():DisplayMapEffect()
    end
  elseif oldMapId == cfgMapId then
    SoaringModule.RemoveMapEffect(G_inComFx or 0)
    SoaringModule.RemoveMapEffect(G_comFx or 0)
    for _, v in pairs(tblSubtasks) do
      v.Instance():RemoveMapEffect()
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p, context)
  if not SoaringModule.GetFeatureOpen() then
    return
  end
  SoaringModule.RemoveMapEffect(G_inComFx or 0)
  SoaringModule.RemoveMapEffect(G_comFx or 0)
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  for _, v in pairs(tblSubtasks) do
    v.Instance():RemoveMapEffect()
  end
end
def.static().DisplayActCompleteEffect = function()
  local soaringCfg = SoaringModule.Instance():GetActivityCfg()
  local effectInfo = soaringCfg:GetEffectInfo()
  if G_comFx ~= nil and G_comFx ~= 0 then
    SoaringModule.RemoveMapEffect(G_comFx)
    G_comFx = 0
  end
  G_comFx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.static().DisplayActImcompleteEffect = function()
  local soaringCfg = SoaringModule.Instance():GetActivityCfg()
  local effectInfo = soaringCfg:GetActImcompleteInfo()
  if G_inComFx ~= nil and G_inComFx ~= 0 then
    SoaringModule.RemoveMapEffect(G_inComFx)
    G_inComFx = 0
  end
  G_inComFx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.static("number", "number", "number", "=>", "number").PlayMapEffect = function(effectId, x, y)
  local eff = GetEffectRes(effectId)
  local fx = _G.MapEffect_RequireRes(x, y, 1, {
    eff.path
  })
  return fx
end
def.static("number").RemoveMapEffect = function(toRmvFx)
  if toRmvFx == 0 then
    return
  end
  _G.MapEffect_ReleaseRes(toRmvFx)
  toRmvFx = 0
end
def.static("number", "string", "number", "table").ShowTalk = function(npcid, talkContent, triedTime, subTask)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local timeOut = SoaringModule.TRY_TALK_TIMEOUT
  local NPCEntity = pubroleModule:GetNpc(npcid)
  if NPCEntity == nil then
    GameUtil.AddGlobalTimer(timeOut, true, function()
      triedTime = triedTime + timeOut
      if triedTime > SoaringModule.MAX_TRY_NPC_TIME then
        return
      end
      SoaringModule.ShowTalk(npcid, talkContent, triedTime, subTask)
    end)
  else
    local function cb()
      NPCEntity:Talk(talkContent, SoaringModule.TALK_DURATION)
      subTask.SetActInfoChange(false)
    end
    if NPCEntity:IsInLoading() then
      NPCEntity:AddOnLoadCallback("show_talk", cb)
    else
      cb()
    end
  end
end
def.static("=>", "boolean").IsLevelEnough = function()
  local myProp = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  local soaringCfg = SoaringModule.Instance():GetActivityCfg()
  return myProp.level >= soaringCfg:GetMinLevel()
end
def.static("=>", "boolean").IsServerLvEnough = function()
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local curSrvLv = serverLevelData.level
  local soaringCfg = SoaringModule.Instance():GetActivityCfg()
  local cfgSrvLv = soaringCfg:GetSeverLevel()
  return curSrvLv >= cfgSrvLv
end
def.static("number", "number").OnSoaringTaskGraph = function(taskId, graphId)
  SoaringModule.ShowUISoaring()
end
def.static().ShowUISoaring = function()
  local UISoaring = require("Main.Soaring.ui.UISoaring")
  local objUISoaring = UISoaring.Instance()
  objUISoaring:ShowPanel()
end
def.static("number").SendReportPlayEffect = function(actId)
  warn(">>>>Send CReportPlayFeiShengEffect req<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CReportPlayFeiShengEffect").new(actId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSReportPlayFeiShengEffectFail = function(p)
end
def.static("table").OnSSynPlayFeiShengEffectInfo = function(p)
  local actId = SoaringModule.Instance():GetActivityId()
  local res = p.effect_info[actId]
  if res == nil or res == 0 then
    G_bHasPlayedEffect = false
  elseif res == 1 then
    G_bHasPlayedEffect = true
  end
end
def.static("boolean").UpdateActivityInterface = function(bFeatureOpen)
  if not SoaringModule.IsServerLvEnough() then
    bFeatureOpen = false
  end
  local activityInterface = ActivityInterface.Instance()
  local activityId = SoaringModule.Instance():GetActivityId()
  if bFeatureOpen then
    activityInterface:removeCustomCloseActivity(activityId)
  else
    activityInterface:addCustomCloseActivity(activityId)
  end
  SoaringModule.UpdateSubtaskActivityInterface(bFeatureOpen)
end
def.static("boolean").UpdateSubtaskActivityInterface = function(bFeatureOpen)
  local activityInterface = ActivityInterface.Instance()
  local tblSubtasks = SoaringModule.GetTblOfAllSubtasks()
  for _, Class in pairs(tblSubtasks) do
    if bFeatureOpen then
      activityInterface:removeCustomCloseActivity(Class.ACTIVITY_ID)
    else
      activityInterface:addCustomCloseActivity(Class.ACTIVITY_ID)
    end
  end
end
def.static("table", "table").OnServeLvChange = function(p, context)
  local bIsSrvLvEnough = SoaringModule.IsServerLvEnough()
  local bIsFeatureOpen = SoaringModule.GetFeatureOpen()
  if bIsSrvLvEnough and bIsFeatureOpen then
    SoaringModule.UpdateActivityInterface(bIsFeatureOpen)
  end
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_FEI_SHENG_99)
  SoaringModule.SetFeatureOpen(bFeatureOpen)
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p.feature == Feature.TYPE_FEI_SHENG_99 then
    local featureOpenModule = FeatureOpenListModule.Instance()
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_FEI_SHENG_99)
    SoaringModule.SetFeatureOpen(bFeatureOpen)
  end
end
return SoaringModule.Commit()
