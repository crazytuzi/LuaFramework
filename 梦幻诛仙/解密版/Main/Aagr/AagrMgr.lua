local Lplus = require("Lplus")
local AagrData = require("Main.Aagr.data.AagrData")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AagrModule = require("Main.Aagr.AagrModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AagrProtocols = require("Main.Aagr.AagrProtocols")
local ArenaCountdownMgr = require("Main.Aagr.mgr.ArenaCountdownMgr")
local ArenaCircleMgr = require("Main.Aagr.mgr.ArenaCircleMgr")
local ArenaBallMgr = require("Main.Aagr.mgr.ArenaBallMgr")
local HeroModelMgr = require("Main.Aagr.mgr.HeroModelMgr")
local AagrUtils = require("Main.Aagr.AagrUtils")
local AagrMgr = Lplus.Class("AagrMgr")
local def = AagrMgr.define
local instance
def.static("=>", AagrMgr).Instance = function()
  if instance == nil then
    instance = AagrMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, AagrMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AagrMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AagrMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AagrMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, AagrMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, AagrMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, AagrMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, AagrMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, AagrMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_HALL, AagrMgr.OnEnterHallMap)
  Event.RegisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_HALL, AagrMgr.OnLeaveHallMap)
  Event.RegisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, AagrMgr.OnEnterArenaMap)
  Event.RegisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, AagrMgr.OnLeaveArenaMap)
end
def.static("table", "table").OnFeatureOpenInit = function(param, context)
  warn("[AagrMgr:OnFeatureOpenInit] OnFeatureOpenInit.")
  AagrMgr.UpdateActivityOpenState()
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_BALL_BATTLE then
    local bOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BALL_BATTLE)
    if not bOpen then
      if AagrData.Instance():IsInHall() then
        Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_HALL, nil)
      end
      if AagrData.Instance():IsInArena() then
        Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, nil)
      end
    end
    AagrData.Instance():OnFunctionOpenChange(bOpen)
    AagrMgr.UpdateActivityOpenState()
    AagrMgr.TryShowEntrance()
  end
end
def.static().TryShowEntrance = function()
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  local activityId = AagrData.Instance():GetCurActivityId()
  if activityId > 0 and AagrUtils.IsInTimeInterval(activityId) and not AagrData.Instance():IsInArena() and not AagrData.Instance():IsInHall() then
    warn("[AagrMgr:TryShowEntrance] Show LimitActivityTip on openchange:", activityId)
    require("Main.activity.ui.limitActivityTip").Instance():ShowDlg(activityId)
  end
end
def.static().UpdateActivityOpenState = function()
  local activityCfgs = AagrData.Instance():GetActivityCfgs()
  if activityCfgs then
    local bOpen = AagrModule.Instance():IsOpen(false)
    for activityId, aagrCfg in pairs(activityCfgs) do
      if bOpen then
        ActivityInterface.Instance():removeCustomCloseActivity(activityId)
      else
        ActivityInterface.Instance():addCustomCloseActivity(activityId)
      end
    end
    AagrData.Instance():UpdateCurrentActivity(true)
    ArenaBallMgr.Instance():OnOpenChange(bOpen)
    ArenaCountdownMgr.Instance():OnOpenChange(bOpen)
    ArenaCircleMgr.Instance():OnOpenChange(bOpen)
    HeroModelMgr.Instance():OnOpenChange(bOpen)
  end
end
def.static("table", "table").OnEnterWorld = function(param, context)
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  AagrData.Instance():OnEnterWorld(param, context)
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  AagrData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnHeroLevelUp = function(param, context)
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  AagrData.Instance():UpdateCurrentActivity(true)
  AagrMgr.TryShowEntrance()
end
def.static("table", "table").OnActivityTodo = function(param, context)
  local activityId = param[1]
  if activityId ~= AagrData.Instance():GetCurActivityId() or not AagrModule.Instance():IsOpen(true) then
    return
  end
  local npcId = AagrData.Instance():GetEntranceNPCId()
  if npcId > 0 then
    warn("[AagrMgr:OnActivityTodo] DispatchEvent Activity_GotoNPC for EntranceNPCId:", npcId)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  else
    warn("[ERROR][AagrMgr:OnActivityTodo] find no EntranceNPCId for activityId:", activityId)
  end
end
def.static("table", "table").OnNPCService = function(param, context)
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  local srvcId = param[1]
  local npcId = param[2]
  if AagrData.Instance():GetCurActivityId() > 0 then
    if npcId == AagrData.Instance():GetEntranceNPCId() and srvcId == AagrData.Instance():GetEntranceServiceId() then
      warn("[AagrMgr:OnNPCService] on enter hall npc service:", npcId, srvcId)
      AagrProtocols.SendCEnterPrepareMapReq()
    elseif npcId == AagrData.Instance():GetHallNPCId() and srvcId == AagrData.Instance():GetHallServiceId() then
      warn("[AagrMgr:OnNPCService] on leave hall npc service:", npcId, srvcId)
      AagrProtocols.SendCLeavePrepareMapReq()
    end
  end
end
def.static("table", "table").OnNewDay = function(param, context)
  if not AagrModule.Instance():IsOpen(false) then
    return
  end
  warn("[AagrMgr:OnNewDay] OnNewDay.")
  AagrData.Instance():OnNewDay(param, context)
end
def.static("table", "table").OnChangeMap = function(params, context)
  local curMapId = params[1]
  local oldMapId = params[2]
  if not _G.IsEnteredWorld() or gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isReconnecting then
    AagrData.Instance():UpdateCurrentActivity(false)
  end
  if (not _G.IsEnteredWorld() or AagrModule.Instance():IsOpen(false)) and AagrData.Instance():GetCurActivityId() > 0 then
    warn(string.format("[AagrMgr:OnChangeMap] curMapId=%d, oldMapId=%d.", curMapId, oldMapId))
    local hallMapId = AagrData.Instance():GetHallMapId()
    if curMapId == hallMapId then
      warn("[AagrMgr:OnChangeMap] DispatchEvent AAGR_ENTER_HALL.")
      Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_HALL, nil)
    elseif oldMapId == hallMapId and curMapId ~= hallMapId then
      warn("[AagrMgr:OnChangeMap] DispatchEvent AAGR_LEAVE_HALL.")
      Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_HALL, nil)
    end
    local arenaMapId = AagrData.Instance():GetArenaMapId()
    if curMapId == arenaMapId then
      warn("[AagrMgr:OnChangeMap] DispatchEvent AAGR_ENTER_ARENA.")
      Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ENTER_ARENA, nil)
    elseif oldMapId == arenaMapId and curMapId ~= arenaMapId then
      warn("[AagrMgr:OnChangeMap] DispatchEvent AAGR_LEAVE_ARENA.")
      Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, nil)
    end
  end
end
def.static("table", "table").OnEnterHallMap = function(params, context)
  local AagrHallPanel = require("Main.Aagr.ui.AagrHallPanel")
  if not AagrHallPanel.Instance():IsShow() then
    AagrHallPanel.ShowPanel()
  end
end
def.static("table", "table").OnLeaveHallMap = function(params, context)
  local AagrHallPanel = require("Main.Aagr.ui.AagrHallPanel")
  AagrHallPanel.Instance():DestroyPanel()
end
def.static("table", "table").OnEnterArenaMap = function(params, context)
  AagrUtils.TryChangeOtherRoleVisibility(true)
  local AagrArenaPanel = require("Main.Aagr.ui.AagrArenaPanel")
  if not AagrArenaPanel.Instance():IsShow() then
    AagrArenaPanel.ShowPanel()
  end
end
def.static("table", "table").OnLeaveArenaMap = function(params, context)
  AagrUtils.TryChangeOtherRoleVisibility(false)
  AagrData.Instance():SyncArenaInfo(nil)
  local AagrArenaPanel = require("Main.Aagr.ui.AagrArenaPanel")
  AagrArenaPanel.Instance():DestroyPanel()
  local AagrDevourPanel = require("Main.Aagr.ui.AagrDevourPanel")
  AagrDevourPanel.Instance():DestroyPanel()
  local AagrFinishPanel = require("Main.Aagr.ui.AagrFinishPanel")
  AagrFinishPanel.Instance():DestroyPanel()
  local MainUIChat = require("Main.MainUI.ui.MainUIChat")
  if MainUIChat.Instance():IsShow() then
    MainUIChat.Instance():Expand()
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
def.static().TestShowEntrance = function()
  AagrData.Instance()._curActivityId = 350020035
  AagrMgr.TryShowEntrance()
end
local MAX_COUNTDOWN = 10
local curCountdown = 10
def.static().TestCountdownEffect = function()
  local activityCfg = AagrData.Instance():GetActivityCfg(350020035)
  local effectId = activityCfg.gamePrepareSfxId + MAX_COUNTDOWN - curCountdown
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    warn("[AagrMgr:TestCountdownEffect] countdown, effectId, path:", curCountdown, effectId, effectCfg.path)
    local GUIFxMan = require("Fx.GUIFxMan")
    local curEffect = GUIFxMan.Instance():Play(effectCfg.path, "", 0, 0, -1, false)
  else
    warn("[ERROR][AagrMgr:TestCountdownEffect] effectCfg nil for countdown, effectid:", curCountdown, effectId)
  end
  curCountdown = curCountdown - 1
  if curCountdown < 0 then
    curCountdown = MAX_COUNTDOWN
  end
end
local ballLevel = 5
def.static().TestModel = function()
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  AagrData.Instance()._curActivityId = 350020035
  local ballLevelCfg = AagrData.Instance():GetBallLevelCfg(ballLevel)
  if ballLevelCfg then
    if role.mModelId ~= ballLevelCfg.modelId then
      warn("[AagrMgr:TestModel] roleId, ballLevel, modelid, modelRatio:", Int64.tostring(role.roleId), ballLevel, ballLevelCfg.modelId, ballLevelCfg.modelRatio)
      role:DestroyModel()
      role.mModelId = ballLevelCfg.modelId
      role:LoadCurrentModel2()
    else
      return
    end
  else
    warn("[ERROR][AagrMgr:TestModel] ballLevelCfg nil for ballLevel:", ballLevel)
    return
  end
  local function onModelLoaded()
    role:SetScale(ballLevelCfg.modelRatio / 100)
    role:SetPate()
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("aagr_model", onModelLoaded)
  else
    onModelLoaded()
  end
end
local EFFECTS, NAMES
local index = 1
def.static().TestRoleEffect = function()
  if nil == EFFECTS then
    local GroundItemType = require("consts.mzm.gsp.ballbattle.confbean.GroundItemType")
    EFFECTS = {}
    NAMES = {}
    local activityCfg = AagrData.Instance():GetActivityCfg(350020035)
    table.insert(EFFECTS, activityCfg.playerDeathSfxId)
    table.insert(NAMES, "\229\155\162\229\173\144\230\173\187\228\186\161")
  end
  local AttachType = require("consts.mzm.gsp.skill.confbean.EffectGuaDian")
  if index > #EFFECTS then
    index = 1
  end
  local effectId = EFFECTS[index]
  local effectName = NAMES[index]
  local effectCfg = GetEffectRes(effectId)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if effectCfg then
    warn("[AagrMgr:TestRoleEffect] show for index, effectId, effectName:", index, effectId, effectName)
    AagrUtils.AddPlayerEffect(role, effectId)
  else
    warn("[ERROR][AagrMgr:TestRoleEffect] effectCfg nil for index, effectId, effectName:", index, effectId, effectName)
  end
  index = index + 1
end
def.static("table").TestGroundEffect = function(param)
  local ECFxMan = require("Fx.ECFxMan")
  local GroundItemType = require("consts.mzm.gsp.ballbattle.confbean.GroundItemType")
  local buffCfg = AagrData.Instance():GetMapEntityCfgByType(GroundItemType.FREEZE)
  local effectCfg = buffCfg and GetEffectRes(buffCfg.groundSfxId)
  if effectCfg then
    warn("[AagrMgr:TestGroundEffect] play buff ground effect, seconds:", effectCfg.path, buffCfg.groundSfxSeconds, param.x, param.y)
    local effect = ECFxMan.Instance():PlayEffectAt2DWorldPos(effectCfg.path, param.x, param.y)
  else
    warn("[ERROR][AagrMgr:TestGroundEffect] effectCfg nil for buffCfg.groundSfxId:", buffCfg.groundSfxId)
  end
end
def.static().TestAlphaScale = function()
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role then
    warn("[AagrMgr:TestAlphaScale] before role.m_IsAlpha:", role.m_IsAlpha)
    role.checkAlpha = false
    role:SetAlpha(0.5)
    warn("[AagrMgr:TestAlphaScale] after role.m_IsAlpha:", role.m_IsAlpha)
  end
end
def.static().TestMax = function()
  local p = {}
  p.role_id = _G.GetMyRoleID()
  p.level_reset_time = _G.GetServerTime() + 10
  AagrProtocols.OnSNotifyMaxLevelEvent(p)
end
local bHigher = true
def.static().TestWarning = function()
  local activityCfg = AagrData.Instance():GetActivityCfg(350020035)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  warn("RESPATH.EMOJIATLAS", RESPATH.EMOJIATLAS)
  local talkStr = "<img src='Arts/Image/Atlas/Compressed/Emoji.prefab.u3dext:0201' width=32 height=32 fps=5>"
  if bHigher then
    role:Talk(talkStr, activityCfg.alertDisappearSeconds)
  else
    role:Talk(talkStr, activityCfg.alertDisappearSeconds)
  end
  bHigher = not bHigher
end
def.static("table").TestKill = function(param)
  local ECFxMan = require("Fx.ECFxMan")
  AagrData.Instance()._curActivityId = 350020035
  local activityCfg = AagrData.Instance():GetCurActivityCfg()
  local effectCfg = activityCfg and GetEffectRes(activityCfg.playerCollisionSfxId)
  if effectCfg then
    warn("[AagrMgr:TestKill] play kill effect:", effectCfg.path)
    ECFxMan.Instance():PlayEffectAt2DWorldPos(effectCfg.path, param.x, param.y)
  else
    warn("[ERROR][AagrMgr:TestKill] activityCfg or playerCollisionSfxId effectCfg nil:", activityCfg, effectCfg)
  end
end
def.static().TestCooldown = function()
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  local maxDuration = 55
  local endTime = _G.GetServerTime() + 5
  if role then
    role:ShowBallCooldownPate(endTime, maxDuration)
  end
end
local countdown = 10
def.static().TestCountdown = function()
  local activityCfg = AagrData.Instance():GetActivityCfg(350020035)
  local effectId = activityCfg.gamePrepareSfxId + 10 - countdown
  ArenaCountdownMgr.Instance():_DoShow(countdown, effectId, nil)
  countdown = countdown - 1
  if countdown < 1 then
    countdown = 10
  end
end
local bShow = false
def.static().TestChat = function()
  local MainUIChat = require("Main.MainUI.ui.MainUIChat")
  bShow = not bShow
  if bShow then
    MainUIChat.Instance():Expand()
  else
    MainUIChat.Instance():Shrink()
  end
end
local zoneModel
local circleIdx = 0
def.static().TestCircle = function()
  if _G.IsNil(zoneModel) then
    local MapUtility = require("Main.Map.MapUtility")
    local SafeZoneModel = require("Main.Aagr.model.SafeZoneModel")
    local activityCfg = AagrData.Instance():GetActivityCfg(350020035)
    local circleCfg = activityCfg and AagrData.Instance():GetCircleCfg(activityCfg.circleCfgId)
    local mapCfg = MapUtility.GetMapCfg(gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId())
    zoneModel = SafeZoneModel.new(circleCfg, circleIdx, mapCfg)
    warn("[AagrMgr:TestCircle] create SafeZoneModel:", circleCfg, circleIdx, mapCfg)
    if not _G.IsNil(zoneModel) then
      zoneModel:LoadZone(function(ret)
        warn("[AagrMgr:TestCircle] load SafeZoneModel success.")
        if ret then
          zoneModel:UpdateZone(circleIdx)
        end
      end)
    else
      warn("[ERROR][AagrMgr:TestCircle] create SafeZoneModel fail.")
    end
  elseif not zoneModel:IsInLoading() then
    warn("[AagrMgr:TestCircle] UpdateZone:", circleIdx)
    circleIdx = circleIdx + 1
    if circleIdx > 3 then
      circleIdx = 0
    end
    zoneModel:UpdateZone(circleIdx)
  else
    warn("[ERROR][AagrMgr:TestCircle] NONE.")
  end
end
AagrMgr.Commit()
return AagrMgr
