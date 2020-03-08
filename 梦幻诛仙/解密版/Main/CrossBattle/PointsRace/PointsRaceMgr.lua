local Lplus = require("Lplus")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local PointsRaceProtocols
local PointsRaceMgr = Lplus.Class("PointsRaceMgr")
local def = PointsRaceMgr.define
local instance
def.static("=>", PointsRaceMgr).Instance = function()
  if instance == nil then
    instance = PointsRaceMgr()
  end
  return instance
end
def.const("table").StageEnum = {
  CLOSED = 0,
  PREPARE = 1,
  MATCHING = 2,
  STOP_MATCH = 3,
  RETURN = 4
}
def.field("userdata")._promoteEffect = nil
def.field("number")._effectTimerID = 0
def.method().Init = function(self)
  PointsRaceProtocols = require("Main.CrossBattle.PointsRace.PointsRaceProtocols")
  PointsRaceData.Instance():Init()
  PointsRaceProtocols.RegisterProtocols()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PointsRaceMgr._OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PointsRaceMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PointsRaceMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PointsRaceMgr._OnNPCService)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Stage_Click, PointsRaceMgr._OnStageClicked)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, PointsRaceMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PointsRaceMgr._OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PointsRaceMgr._OnEndFight)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.POINTS_RACE_STAGE_CHANGE, PointsRaceMgr._OnPointsRaceStageChange)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, PointsRaceMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsDrawOpen = function(self, bToast)
  local result = true
  local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
  if false == CrossBattleInterface.Instance():isCrossBattleOpen() then
    result = false
    if bToast then
      Toast(textRes.PointsRace.FEATRUE_IDIP_NOT_OPEN)
    end
  elseif false == _G.IsFeatureOpen(PointsRaceUtils.GetDrawSwitchId()) then
    result = false
    if bToast then
      Toast(textRes.PointsRace.FEATRUE_IDIP_DRAW_NOT_OPEN)
    end
  end
  return result
end
def.method("boolean", "=>", "boolean").IsRaceOpen = function(self, bToast)
  local result = true
  local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
  if false == CrossBattleInterface.Instance():isCrossBattleOpen() then
    result = false
    if bToast then
      Toast(textRes.PointsRace.FEATRUE_IDIP_NOT_OPEN)
    end
  elseif false == _G.IsFeatureOpen(PointsRaceUtils.GetPointsRaceSwitchId()) then
    result = false
    if bToast then
      Toast(textRes.PointsRace.FEATRUE_IDIP_RACE_NOT_OPEN)
    end
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return false
end
def.static("table", "table")._OnEnterWorld = function(param, context)
  PointsRaceMgr._UpdateUIs()
  local pointsRaceMapId = PointsRaceUtils.GetPointsRaceMapId()
  if gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId() == pointsRaceMapId then
    PointsRaceMgr._SetCrossBattleState(true)
  end
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  PointsRaceMgr.Instance():_DestroyPromoteEffect()
  PointsRaceMgr.Instance():_ClearEffectTimer()
  PointsRaceData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature ~= ModuleFunSwitchInfo.TYPE_CROSS_BATTLE_SEASON_1 or false == param.open then
  else
  end
end
def.static("table", "table")._OnNPCService = function(param, context)
  local serviceId = param[1]
  local npcId = param[2]
  if npcId == PointsRaceUtils.GetQuitNPCId() and serviceId == PointsRaceUtils.GetQuitServiceId() then
    PointsRaceMgr._OnNPCServiceQuit()
  else
  end
end
def.static()._OnNPCServiceQuit = function()
  if PointsRaceUtils.IsInPointsRaceMap() then
    local TeamData = require("Main.Team.TeamData")
    if TeamData.Instance():MeIsCaptain() then
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PointsRace.RACE_LEAVE_TITLE, textRes.PointsRace.RACE_LEAVE_CONFIRM, function(id, tag)
        if id == 1 then
          PointsRaceProtocols.SendCLeaveArena()
        end
      end, nil)
    else
      Toast(textRes.PointsRace.QUIT_FAIL_NOT_CAPTAIN)
    end
  else
    warn("[ERROR][PointsRaceMgr:_OnNPCServiceQuit] quit failed. not in crossbattle map.")
  end
end
def.static("table", "table")._OnStageClicked = function(param, context)
  local stage = param[1]
  local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleActivityStage")
  if stage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE then
    PointsRaceMgr._OnDrawStage()
  elseif stage == CrossBattleActivityStage.STAGE_ZONE_POINT then
    PointsRaceMgr._OnPointsRaceStage()
  end
end
def.static()._OnDrawStage = function()
  if not PointsRaceUtils.CanDraw(true) then
    return
  end
  if CorpsInterface.HasCorps() and CorpsInterface.IsCorpsLeader() then
    PointsRaceProtocols.SendCDraw()
  else
    Toast(textRes.PointsRace.DRAW_FAIL_NOT_CAPTAIN)
  end
end
def.static()._OnPointsRaceStage = function()
  if not PointsRaceUtils.CanRace(true) then
    return
  end
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  local conditionDesc = {
    textRes.PointsRace.ENTER_CONDITIONS[1],
    textRes.PointsRace.ENTER_CONDITIONS[2],
    textRes.PointsRace.ENTER_CONDITIONS[3],
    textRes.PointsRace.ENTER_CONDITIONS[4]
  }
  local initStatus = {
    false,
    false,
    false,
    false
  }
  CrossBattleConditionCheckPanel.Instance():ShowPanel(conditionDesc, initStatus)
  CrossBattleConditionCheckPanel.Instance():SetConfirmCallback(function()
    PointsRaceProtocols.SendCEnterArena()
  end, false)
  PointsRaceProtocols.SendCCheckEnterConditions()
end
def.static("table", "table").OnChangeMap = function(params, context)
  local curMapId = params[1]
  local oldMapId = params[2]
  local pointsRaceMapId = PointsRaceUtils.GetPointsRaceMapId()
  if curMapId == pointsRaceMapId then
    PointsRaceMgr._UpdateUIs()
    PointsRaceMgr._SetCrossBattleState(true)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.Cross_Battle_Enter_POINTS_RACE, nil)
  elseif oldMapId == pointsRaceMapId and curMapId ~= pointsRaceMapId then
    PointsRaceMgr._UpdateUIs()
    PointsRaceMgr._SetCrossBattleState(false)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.Cross_Battle_Leave_POINTS_RACE, nil)
  end
end
def.static("boolean")._SetCrossBattleState = function(set)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
    warn("[PointsRaceMgr:_SetCrossBattleState] Set RoleState.CROSS_BATTLE:", set)
    if set then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.CROSS_BATTLE)
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.CROSS_BATTLE)
    end
  else
    warn("[ERROR][PointsRaceMgr:_SetCrossBattleState] set state fail, myRole nil!")
  end
end
def.static("table", "table")._OnEnterFight = function(p1, p2)
  PointsRaceMgr._UpdateUIs()
end
def.static("table", "table")._OnEndFight = function(p1, p2)
  PointsRaceMgr._UpdateUIs()
  if PointsRaceUtils.IsInPointsRaceMap() then
    local curStage = PointsRaceData.Instance():GetCurStage()
    if curStage == PointsRaceMgr.StageEnum.MATCHING or curStage == PointsRaceMgr.StageEnum.STOP_MATCH then
      if p1.Result then
        Toast(string.format(textRes.PointsRace.RACE_WIN, PointsRaceUtils.GetWinPoint()))
      else
        Toast(textRes.PointsRace.RACE_LOSE)
      end
      warn("[PointsRaceMgr:_OnEndFight] UpdateNextMatchTime On LEAVE_FIGHT.")
      PointsRaceData.Instance():UpdateNextMatchTime()
    else
      warn("[ERROR][PointsRaceMgr:_OnEndFight] wrong state:", curStage)
    end
  end
end
def.static("table", "table")._OnPointsRaceStageChange = function(p1, p2)
  PointsRaceMgr._UpdateUIs()
end
def.static()._UpdateUIs = function()
  GameUtil.AddGlobalTimer(0, true, function()
    PointsRaceMgr._DoUpdateUIs()
  end)
end
def.static()._DoUpdateUIs = function()
  local PointsRaceMainPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceMainPanel")
  local PointsRaceMatchingPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceMatchingPanel")
  if PointsRaceUtils.IsInPointsRaceMap() then
    if not _G.PlayerIsInFight() then
      local curStage = PointsRaceData.Instance():GetCurStage()
      if curStage == PointsRaceMgr.StageEnum.PREPARE or curStage == PointsRaceMgr.StageEnum.MATCHING or curStage == PointsRaceMgr.StageEnum.STOP_MATCH then
        warn("[PointsRaceMgr:_UpdateUIs] show PointsRaceMainPanel on stage:", curStage)
        PointsRaceMainPanel.ShowPanel()
      else
        warn("[PointsRaceMgr:_UpdateUIs] hide PointsRaceMainPanel on stage:", curStage)
        if PointsRaceMainPanel.Instance():IsShow() then
          PointsRaceMainPanel.Instance():DestroyPanel()
        end
      end
      if curStage == PointsRaceMgr.StageEnum.MATCHING then
        warn("[PointsRaceMgr:_UpdateUIs] show PointsRaceMatchingPanel on stage:", curStage)
        PointsRaceMatchingPanel.ShowPanel()
      else
        warn("[PointsRaceMgr:_UpdateUIs] hide PointsRaceMatchingPanel on stage:", curStage)
        if PointsRaceMatchingPanel.Instance():IsShow() then
          PointsRaceMatchingPanel.Instance():DestroyPanel()
        end
      end
    else
      warn("[PointsRaceMgr:_UpdateUIs] in fight, hide PointsRaceMainPanel and PointsRaceMatchingPanel.")
      PointsRaceMatchingPanel.Instance():DestroyPanel()
    end
  else
    PointsRaceMainPanel.Instance():DestroyPanel()
    PointsRaceMatchingPanel.Instance():DestroyPanel()
  end
end
def.method().PlayPromoteEffect = function(self)
  local effectParent = require("Main.MainUI.ui.MainUIPanel").Instance().m_panel
  if effectParent then
    if nil == self._promoteEffect then
      local effectCfg = GetEffectRes(PointsRaceUtils.GetPromoteEffectId())
      if effectCfg then
        self._promoteEffect = require("Fx.GUIFxMan").Instance():PlayAsChild(effectParent, effectCfg.path, 0, 0, -1, false)
      else
        warn("[ERROR][PointsRaceMgr:PlayPromoteEffect] effectCfg nil for effectid:", PointsRaceUtils.GetPromoteEffectId())
      end
    end
    if self._promoteEffect then
      self:_ClearEffectTimer()
      local effectDuration = 5
      self._effectTimerID = GameUtil.AddGlobalTimer(effectDuration, true, function()
        self:_DestroyPromoteEffect()
      end)
    end
  else
    warn("[ERROR][PointsRaceMgr:PlayPromoteEffect] effectParent nil, play failed.")
  end
end
def.method()._DestroyPromoteEffect = function(self)
  if self._promoteEffect then
    self._promoteEffect:Destroy()
    self._promoteEffect = nil
  end
end
def.method()._ClearEffectTimer = function(self)
  if self._effectTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._effectTimerID)
    self._effectTimerID = 0
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
PointsRaceMgr.Commit()
return PointsRaceMgr
