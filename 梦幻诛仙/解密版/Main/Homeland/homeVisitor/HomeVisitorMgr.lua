local MODULE_NAME = (...)
local Lplus = require("Lplus")
local HomeVisitorMgr = Lplus.Class(MODULE_NAME)
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local HomeVisitorUtils = require("Main.Homeland.homeVisitor.HomeVisitorUtils")
local MysteryVisitorType = require("consts.mzm.gsp.homeland.confbean.MysteryVisitorType")
local HomelandModule = require("Main.Homeland.HomelandModule")
local TaskInterface = require("Main.task.TaskInterface")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local def = HomeVisitorMgr.define
local instance
local G_iCurCfgId = 0
def.field("boolean").bFeatureOpen = false
def.static("=>", HomeVisitorMgr).Instance = function()
  if instance == nil then
    instance = HomeVisitorMgr()
  end
  return instance
end
def.method().Init = function(self)
  HomeVisitorMgr.RegisterCustomTaskNpcIds()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SAttendMysteryVisitorSuccess", HomeVisitorMgr.OnSAttendMysteryVisitorSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SAttendMysteryVisitorFail", HomeVisitorMgr.OnSAttendMysteryVisitorFail)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, HomeVisitorMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CfgIdChange, HomeVisitorMgr.OnCfgIdChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, HomeVisitorMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, HomeVisitorMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOMELAND, HomeVisitorMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, HomeVisitorMgr.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, HomeVisitorMgr.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, HomeVisitorMgr.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, HomeVisitorMgr.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Build_Homeland_Success, HomeVisitorMgr.OnSuccessBuildHome)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, HomeVisitorMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, HomeVisitorMgr.OnFeatureOpenChange)
end
def.static("table", "table").OnNPCService = function(p, context)
  if not HomeVisitorMgr.Instance():IsFeatureOpen() then
    return
  end
  local srvcId = p[1] or 0
  local npcId = p[2] or 0
  if not HomelandModule.Instance():IsInSelfHomeland() then
    return
  end
  local npcEntity = require("Main.Map.entity.MysteryVisitorEntity")
  local cfg_id = G_iCurCfgId
  local gameInfo = HomeVisitorUtils.GetGameCfgById(cfg_id)
  if gameInfo == nil then
    return
  end
  local cfgData
  if gameInfo.type == MysteryVisitorType.DANCE then
    cfgData = HomeVisitorUtils.GetDanceCfgById(gameInfo.id)
    if cfgData.npc_service_id == srvcId then
      HomeVisitorMgr.Dancer(cfgData)
    end
  elseif gameInfo.type == MysteryVisitorType.MUSIC_GAME then
    cfgData = HomeVisitorUtils.GetMusicCfgById(gameInfo.id)
    if cfgData.npc_service_id == srvcId then
      HomeVisitorMgr.SendCAttendMysteryVisitorReq(G_iCurCfgId)
    end
  end
end
local G_dstActionId
local DlgAction = require("Main.Chat.ui.DlgAction")
def.static("table").Dancer = function(dancerCfg)
  local countAction = 8
  local rand = math.random(1, countAction)
  local dstActionId = dancerCfg.action_ids[rand]
  G_dstActionId = dstActionId
  local actionName = DlgAction.Instance():GetAllActionCfg()[dstActionId].name
  local content = textRes.Homeland.MysteryVisitor[2]:format(actionName)
  CommonConfirmDlg.ShowConfirm(textRes.Homeland.MysteryVisitor[1], content, function(select)
    if select == 1 then
      Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PLAYED_ACTION, HomeVisitorMgr.OnPlayedAction)
      DlgAction.Instance():ShowDlg()
    end
  end, nil)
end
def.static("number").PlayActionCallback = function(doneActionId)
  if not HomeVisitorMgr.Instance():IsFeatureOpen() or not HomelandModule.Instance():IsInSelfHomeland() then
    return
  end
  if G_dstActionId ~= nil and G_dstActionId == doneActionId then
    Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PLAYED_ACTION, HomeVisitorMgr.OnPlayedAction)
    HomeVisitorMgr.SendCAttendMysteryVisitorReq(G_iCurCfgId)
    G_dstActionId = -1
  end
end
def.static("=>", "boolean").IsActActive = function()
  if not HomeVisitorMgr.Instance():IsFeatureOpen() then
    return false
  end
  if not HomelandModule.Instance():HaveHome() then
    return false
  end
  return HomeVisitorMgr.checkActivityIsActive()
end
def.static("=>", "boolean").checkActivityIsActive = function()
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local actId = constant.CMysteryVisitorConsts.ACTIVITY_CFG_ID
  local activityInfo = activityInterface:GetActivityInfo(actId)
  local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
  local bIsComplete = false
  if activityInfo ~= nil and activityInfo.count >= actCfgInfo.limitCount then
    bIsComplete = true
  else
    bIsComplete = false
  end
  local bActStart = activityInterface:isActivityOpend(actId)
  return not bIsComplete and bActStart
end
def.static().RegisterCustomTaskNpcIds = function()
  HomeVisitorMgr.doRegisterCustomTaskNpcId(true)
end
def.static().UnregisterCustomTaskNpcIds = function()
  HomeVisitorMgr.doRegisterCustomTaskNpcId(false)
end
def.static("boolean").doRegisterCustomTaskNpcId = function(bToDo)
  local npc_infos = HomeVisitorUtils.GetNPCInfos()
  if npc_infos == nil then
    return
  end
  local taskInterface = TaskInterface.Instance()
  for npc_lib_id, npcData in pairs(npc_infos) do
    if bToDo then
      taskInterface:registerCustomTaskNpcIdFn(npc_lib_id, HomeVisitorMgr.GetCustomeTaskNpcId)
    else
      taskInterface:registerCustomTaskNpcIdFn(npc_lib_id, nil)
    end
  end
end
def.static("number", "=>", "number").GetCustomeTaskNpcId = function(clsId)
  local home_map_id = require("Main.Homeland.HomelandUtils").GetMyCourtyardMapId()
  if home_map_id == 0 then
    warn(">>>>Get home_map_id error")
    return 0
  end
  local npc_infos = HomeVisitorUtils.GetNPCInfos()
  local npcData = npc_infos[clsId]
  if npcData == nil then
    return 0
  end
  return npcData[home_map_id] or 0
end
def.static("boolean").SetFeatureOpen = function(bOpen)
  HomeVisitorMgr.Instance().bFeatureOpen = bOpen
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MYSTERY_VISITOR)
  return bOpen
end
def.static("boolean").ShowTaskNPC = function(bShow)
  local npc_infos = HomeVisitorUtils.GetNPCInfos()
  if npc_infos == nil then
    return
  end
  local taskInterface = TaskInterface.Instance()
  for npc_lib_id, npcData in pairs(npc_infos) do
    for map_id, npc_id in pairs(npcData) do
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npc_id, show = bShow})
    end
  end
end
def.static("table", "table").OnPlayedAction = function(p, context)
  HomeVisitorMgr.PlayActionCallback(p[1].id)
end
def.static("table", "table").OnActivityStart = function(p, context)
  if not HomeVisitorMgr.Instance():IsFeatureOpen() then
    return
  end
  local actId = p[1] or 0
  if actId == constant.CMysteryVisitorConsts.ACTIVITY_CFG_ID then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MysteryVisitorActChange, nil)
  end
end
def.static("table", "table").OnCfgIdChange = function(p, context)
  G_iCurCfgId = p[1] or 0
end
def.static("table", "table").OnActivityInfoChanged = function(p, context)
  if p[1] ~= constant.CMysteryVisitorConsts.ACTIVITY_CFG_ID then
    return
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MysteryVisitorActChange, nil)
end
def.static("table", "table").OnSuccessBuildHome = function(p, context)
  local bAct = HomeVisitorMgr.checkActivityIsActive()
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MysteryVisitorActChange, {bAct})
end
def.static("table", "table").OnMapChange = function(p, c)
  if not HomeVisitorMgr.Instance():IsFeatureOpen() then
    return
  end
  if not HomelandModule.Instance():IsInCourtyardMap() then
    return
  elseif HomelandModule.Instance():IsInSelfHomeland() then
    HomeVisitorMgr.ShowTaskNPC(true)
    if HomeVisitorMgr.IsActActive() then
      Toast(textRes.Homeland.MysteryVisitor[3])
    end
  else
    HomeVisitorMgr.ShowTaskNPC(false)
  end
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MYSTERY_VISITOR)
  HomeVisitorMgr.SetFeatureOpen(bFeatureOpen)
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p.feature == Feature.TYPE_MYSTERY_VISITOR then
    local featureOpenModule = FeatureOpenListModule.Instance()
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MYSTERY_VISITOR)
    HomeVisitorMgr.SetFeatureOpen(bFeatureOpen)
    HomeVisitorMgr.OnActivityInfoChanged({
      constant.CMysteryVisitorConsts.ACTIVITY_CFG_ID
    }, nil)
  end
end
def.static("number").SendCAttendMysteryVisitorReq = function(cfg_id)
  warn(">>>>SendCAttendMysteryVisitorReq<<<<")
  local p = require("netio.protocol.mzm.gsp.homeland.CAttendMysteryVisitorReq").new(cfg_id)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendMysteryVisitorSuccess = function(p)
  warn(">>>>SAttendMysteryVisitorSuccess<<<<")
  local cfg_id = p.mystery_visitor_cfg_id
  warn(">>>>cfg_id = " .. cfg_id)
end
def.static("table").OnSAttendMysteryVisitorFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>AWARD_FAIL<<<<")
  end
end
return HomeVisitorMgr.Commit()
