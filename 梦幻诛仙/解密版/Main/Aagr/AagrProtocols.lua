local Lplus = require("Lplus")
local AagrData = require("Main.Aagr.data.AagrData")
local ArenaBallMgr = require("Main.Aagr.mgr.ArenaBallMgr")
local ArenaCircleMgr = require("Main.Aagr.mgr.ArenaCircleMgr")
local ArenaCountdownMgr = require("Main.Aagr.mgr.ArenaCountdownMgr")
local PlayerStateEnum = require("netio.protocol.mzm.gsp.ballbattle.PlayerStateEnum")
local GroundItemType = require("consts.mzm.gsp.ballbattle.confbean.GroundItemType")
local ECFxMan = require("Fx.ECFxMan")
local AagrUtils = require("Main.Aagr.AagrUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local AagrProtocols = Lplus.Class("AagrProtocols")
local def = AagrProtocols.define
local EFFECT_DURATION = 3
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SSyncActivityStatus", AagrProtocols.OnSSyncActivityStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyInsufficientPlayerNumber", AagrProtocols.OnSNotifyInsufficientPlayerNumber)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SEnterPrepareMapSuccess", AagrProtocols.OnSEnterPrepareMapSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SEnterPrepareMapFail", AagrProtocols.OnSEnterPrepareMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SLeavePrepareMapSuccess", AagrProtocols.OnSLeavePrepareMapSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SLeavePrepareMapFail", AagrProtocols.OnSLeavePrepareMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SLeaveGameMapSuccess", AagrProtocols.OnSLeaveGameMapSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SLeaveGameMapFail", AagrProtocols.OnSLeaveGameMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SSyncGameStatus", AagrProtocols.OnSSyncGameStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SSyncPlayerScoreInfo", AagrProtocols.OnSSyncPlayerScoreInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyGameEnded", AagrProtocols.OnSNotifyGameEnded)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyCircleReduceEvent", AagrProtocols.OnSNotifyCircleReduceEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyKillEvent", AagrProtocols.OnSNotifyKillEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyMaxLevelEvent", AagrProtocols.OnSNotifyMaxLevelEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyBuffEvent", AagrProtocols.OnSNotifyBuffEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SNotifyNearbyEnemy", AagrProtocols.OnSNotifyNearbyEnemy)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ballbattle.SBallBattlePlayerStatus", AagrProtocols.OnSBallBattlePlayerStatus)
end
def.static("table").OnSSyncActivityStatus = function(p)
  warn("[AagrProtocols:OnSSyncActivityStatus] On SSyncActivityStatus.")
  AagrData.Instance():SyncHallInfo(p.status)
end
def.static("table").OnSNotifyInsufficientPlayerNumber = function(p)
  warn("[AagrProtocols:OnSNotifyInsufficientPlayerNumber] On SNotifyInsufficientPlayerNumber.")
  Toast(textRes.Aagr.MATCH_FAIL_LACK_PLAYER)
end
def.static().SendCEnterPrepareMapReq = function()
  warn("[AagrProtocols:SendCEnterPrepareMapReq] Send CEnterPrepareMapReq.")
  local p = require("netio.protocol.mzm.gsp.ballbattle.CEnterPrepareMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEnterPrepareMapSuccess = function(p)
  warn("[AagrProtocols:OnSEnterPrepareMapSuccess] On SEnterPrepareMapSuccess")
end
def.static("table").OnSEnterPrepareMapFail = function(p)
  warn("[AagrProtocols:OnSEnterPrepareMapFail] On SEnterPrepareMapFail! p.reason:", p.reason)
  local errString = textRes.Aagr.SEnterPrepareMapFail[p.reason]
  if errString then
    Toast(errString)
  end
end
def.static().SendCLeavePrepareMapReq = function()
  warn("[AagrProtocols:SendCLeavePrepareMapReq] Send CLeavePrepareMapReq.")
  local p = require("netio.protocol.mzm.gsp.ballbattle.CLeavePrepareMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSLeavePrepareMapSuccess = function(p)
  warn("[AagrProtocols:OnSLeavePrepareMapSuccess] On SLeavePrepareMapSuccess.")
  AagrData.Instance():SyncHallInfo(nil)
end
def.static("table").OnSLeavePrepareMapFail = function(p)
  warn("[AagrProtocols:OnSLeavePrepareMapFail] On SLeavePrepareMapFail! p.reason:", p.reason)
  local errString = textRes.Aagr.SLeavePrepareMapFail[p.reason]
  if errString then
    Toast(errString)
  end
end
def.static().SendCLeaveGameMapReq = function()
  warn("[AagrProtocols:SendCLeaveGameMapReq] Send CLeaveGameMapReq.")
  local p = require("netio.protocol.mzm.gsp.ballbattle.CLeaveGameMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSLeaveGameMapSuccess = function(p)
  warn("[AagrProtocols:OnSLeaveGameMapSuccess] On SLeaveGameMapSuccess.")
  AagrData.Instance():SyncArenaInfo(nil)
end
def.static("table").OnSLeaveGameMapFail = function(p)
  warn("[AagrProtocols:OnSLeaveGameMapFail] On SLeaveGameMapFail! p.reason:", p.reason)
  local errString = textRes.Aagr.SLeaveGameMapFail[p.reason]
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSSyncGameStatus = function(p)
  warn("[AagrProtocols:OnSSyncGameStatus] On SSyncGameStatus.")
  AagrData.Instance():SyncArenaInfo(p.status)
  AagrUtils.TryChangeOtherRoleVisibility(true)
  ArenaCountdownMgr.Instance():OnSSyncGameStatus()
  ArenaCircleMgr.Instance():OnSSyncGameStatus()
  local bAlive = AagrData.Instance():IsHeroAlive()
  if not bAlive then
    AagrProtocols.TryShowLeaveArenaConfirm()
  end
end
def.static().TryShowLeaveArenaConfirm = function()
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrProtocols:TryShowLeaveArenaConfirm] show fail! not in arena.")
    return
  end
  if AagrData.Instance():GetAlivePlayerCount() <= 1 then
    warn("[ERROR][AagrProtocols:TryShowLeaveArenaConfirm] show fail! less than 1 player alive:", AagrData.Instance():GetAlivePlayerCount())
    return
  end
  warn("[AagrProtocols:TryShowLeaveArenaConfirm] show leave arena confirm on dead.")
  local content = string.format(textRes.Aagr.ARENA_DEAD_LEAVE_CONTENT, AagrData.Instance():GetBallMaxLife())
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Aagr.ARENA_DEAD_LEAVE_TITLE, content, textRes.Aagr.ARENA_DEAD_LEAVE_YES, textRes.Aagr.ARENA_DEAD_LEAVE_NO, 1, 10, function(id, tag)
    if id == 1 then
      AagrProtocols.SendCLeaveGameMapReq()
    end
  end, nil)
end
def.static("table").OnSSyncPlayerScoreInfo = function(p)
  warn("[AagrProtocols:OnSSyncPlayerScoreInfo] On SSyncPlayerScoreInfo.")
  local bAliveBefore = AagrData.Instance():IsHeroAlive()
  local heroScoreBefore = AagrData.Instance():GetPlayerScore(_G.GetMyRoleID())
  AagrData.Instance():SyncArenaPlayerInfos(p.player_score_infos)
  if AagrData.Instance():IsInArena() then
    local bAliveAfter = AagrData.Instance():IsHeroAlive()
    if bAliveBefore and not bAliveAfter then
      AagrProtocols.TryShowLeaveArenaConfirm()
    end
    local heroScoreAfter = AagrData.Instance():GetPlayerScore(_G.GetMyRoleID())
    local scoreDiff = heroScoreAfter - heroScoreBefore
    if scoreDiff > 0 then
      Toast(string.format(textRes.Aagr.ARENA_ADD_SCORE, scoreDiff))
    end
  else
    warn("[ERROR][AagrProtocols:OnSSyncPlayerScoreInfo] not in arena.")
  end
end
def.static("table").OnSNotifyGameEnded = function(p)
  warn("[AagrProtocols:OnSNotifyGameEnded] Game Ended.")
  AagrData.Instance():SyncArenaPlayerInfos(p.player_score_infos)
  local AagrFinishPanel = require("Main.Aagr.ui.AagrFinishPanel")
  AagrFinishPanel.ShowPanel()
end
def.static("table").OnSNotifyCircleReduceEvent = function(p)
  warn("[AagrProtocols:OnSNotifyCircleReduceEvent] circleIdx:", p.circle_number)
  AagrData.Instance():SyncCircle(p.circle_number)
  ArenaCircleMgr.Instance():OnSNotifyCircleReduceEvent()
end
def.static("table").OnSNotifyKillEvent = function(p)
  warn("[AagrProtocols:OnSNotifyKillEvent] On SNotifyKillEvent.")
  if AagrData.Instance():IsInArena() then
    if p.killer_role_id and Int64.gt(p.killer_role_id, 0) then
      local AagrDevourPanel = require("Main.Aagr.ui.AagrDevourPanel")
      AagrDevourPanel.ShowDevour(p)
      local activityCfg = AagrData.Instance():GetCurActivityCfg()
      local effectCfg = activityCfg and GetEffectRes(activityCfg.playerCollisionSfxId)
      if effectCfg then
        warn("[AagrProtocols:OnSNotifyKillEvent] play kill effect:", activityCfg.playerCollisionSfxId)
        ECFxMan.Instance():PlayEffectAt2DWorldPos(effectCfg.path, p.position_x, p.position_y)
      else
        warn("[ERROR][AagrProtocols:OnSNotifyKillEvent] activityCfg or playerCollisionSfxId effectCfg nil:", activityCfg, effectCfg)
      end
    else
      warn("[AagrProtocols:OnSNotifyKillEvent] role killed by circle:", Int64.tostring(p.killed_role_id))
      do
        local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(p.killed_role_id)
        if not _G.IsNil(role) then
          local function onModelLoaded()
            if not _G.IsNil(role) then
              role:Die()
              local activityCfg = AagrData.Instance():GetCurActivityCfg()
              local effectId = activityCfg and activityCfg.playerDeathSfxId or 0
              AagrUtils.AddPlayerEffect(role, effectId)
            end
          end
          if role:IsInLoading() then
            role:AddOnLoadCallback("aagr_dead", onModelLoaded)
          else
            onModelLoaded()
          end
        end
      end
    end
  else
    warn("[ERROR][AagrProtocols:OnSNotifyKillEvent] not in arena.")
  end
end
def.static("table").OnSNotifyMaxLevelEvent = function(p)
  warn("[AagrProtocols:OnSNotifyMaxLevelEvent] p.role_id:", p.role_id and Int64.tostring(p.role_id))
  ArenaBallMgr.Instance():OnSNotifyMaxLevelEvent(p)
  if AagrData.Instance():IsInArena() then
    local playerName = AagrData.Instance():GetPlayerName(p.role_id)
    if playerName then
      Toast(string.format(textRes.Aagr.ARENA_MAX_BALL, playerName))
    end
    local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(p.role_id)
    local maxDuration = AagrData.Instance():GetBallMaxDuration()
    warn("[AagrProtocols:OnSNotifyMaxLevelEvent] role, endTime, curTime, duration:", role, os.date("%c", p.level_reset_time), os.date("%c", _G.GetServerTime()), maxDuration)
    if role and p.level_reset_time < _G.GetServerTime() and maxDuration > 0 then
      role:ShowBallCooldownPate(p.level_reset_time, maxDuration)
    end
  else
    warn("[ERROR][AagrProtocols:OnSNotifyMaxLevelEvent] not in arena.")
  end
end
def.static("table").OnSNotifyBuffEvent = function(p)
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrProtocols:OnSNotifyBuffEvent] not in arena.")
    return
  end
  warn("[AagrProtocols:OnSNotifyBuffEvent] On SNotifyBuffEvent. type:", p.buff_type)
  if p.buff_type ~= GroundItemType.GENE then
    do
      local buffCfg = AagrData.Instance():GetMapEntityCfgByType(p.buff_type)
      if nil == buffCfg then
        warn("[ERROR][AagrProtocols:OnSNotifyBuffEvent] buffCfg nil for p.buff_type:", p.buff_type)
        return
      end
      local playerName = AagrData.Instance():GetPlayerName(p.role_id)
      if playerName then
        Toast(string.format(textRes.Aagr.ARENA_TRIGGER_BUFF, playerName, buffCfg.name))
      end
      if buffCfg.groundSfxId > 0 then
        local effectCfg = buffCfg and GetEffectRes(buffCfg.groundSfxId)
        if effectCfg then
          warn("[AagrProtocols:OnSNotifyBuffEvent] play buff ground effect, seconds:", p.buff_type, buffCfg.groundSfxId, buffCfg.groundSfxSeconds)
          do
            local effect = ECFxMan.Instance():PlayEffectAt2DWorldPos(effectCfg.path, p.position_x, p.position_y)
            GameUtil.AddGlobalTimer(buffCfg.groundSfxSeconds, true, function()
              if not _G.IsNil(effect) then
                warn("[AagrProtocols:OnSNotifyBuffEvent] remove buff ground effect:", p.buff_type, buffCfg.groundSfxId)
                ECFxMan.Instance():Stop(effect)
              end
            end)
          end
        else
          warn("[ERROR][AagrProtocols:OnSNotifyBuffEvent] effectCfg nil for buffCfg.groundSfxId:", buffCfg.groundSfxId)
        end
      end
    end
  end
end
def.static("table").OnSNotifyNearbyEnemy = function(p)
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrProtocols:OnSNotifyNearbyEnemy] not in arena.")
    return
  end
  if nil == p.role_id then
    warn("[ERROR][AagrProtocols:OnSNotifyNearbyEnemy] p.role_id nil.")
    return
  end
  local activityCfg = AagrData.Instance():GetCurActivityCfg()
  if nil == activityCfg then
    warn("[ERROR][AagrProtocols:OnSNotifyNearbyEnemy] current activityCfg nil.")
    return
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(p.role_id)
  if role then
    warn("[AagrProtocols:OnSNotifyNearbyEnemy] warning on p.role_id, p.is_level_higher:", Int64.tostring(p.role_id), p.is_level_higher)
    if 0 ~= p.is_level_higher then
      role:Talk(activityCfg.alertContentFromHigherLevel, activityCfg.alertDisappearSeconds)
    else
      role:Talk(activityCfg.alertContentFromLowerLevel, activityCfg.alertDisappearSeconds)
    end
  else
    warn("[ERROR][AagrProtocols:OnSNotifyNearbyEnemy] role nil for roleId:", Int64.tostring(p.role_id))
  end
end
def.static("table", "table").OnSBallBattlePlayerStatus = function(role, p)
  if role == nil then
    warn("[ERROR][AagrProtocols:OnSBallBattlePlayerStatus] role nil!")
    return
  end
  if p == nil then
    warn("[ERROR][AagrProtocols:OnSBallBattlePlayerStatus] p nil!")
    return
  end
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrProtocols:OnSBallBattlePlayerStatus] not in arena.")
    return
  end
  local activityCfg = AagrData.Instance():GetCurActivityCfg()
  if nil == activityCfg then
    warn("[ERROR][AagrProtocols:OnSBallBattlePlayerStatus] current activityCfg nil.")
    return
  end
  local oldBallInfo = ArenaBallMgr.Instance():GetBallInfo(role.roleId)
  local oldStates = oldBallInfo and oldBallInfo:GetStates() or nil
  local oldLevel = oldBallInfo and oldBallInfo:GetLevel() or 0
  local bOldMax = oldBallInfo and oldBallInfo:CheckState(PlayerStateEnum.MAX_LEVEL) or false
  ArenaBallMgr.Instance():OnSBallBattlePlayerStatus(role, p)
  local ballInfo = ArenaBallMgr.Instance():GetBallInfo(role.roleId)
  if ballInfo == nil then
    warn("[ERROR][AagrProtocols:OnSBallBattlePlayerStatus] ballInfo nil for roleId:", Int64.tostring(role.roleId))
    return
  else
    warn("[AagrProtocols:OnSBallBattlePlayerStatus] roleId:", role.roleId and Int64.tostring(role.roleId))
  end
  AagrProtocols._ProcessModel(role, ballInfo)
  AagrProtocols._ProcessName(role, ballInfo, activityCfg)
  AagrProtocols._ProcessMax(role, ballInfo, activityCfg, bOldMax)
  AagrProtocols._ProcessBuff(role, ballInfo, oldStates)
  AagrProtocols._ProcessLevelChange(role, ballInfo, activityCfg, oldLevel)
  AagrProtocols._ProcessDead(role, ballInfo, oldStates)
end
def.static("table", "table")._ProcessModel = function(role, ballInfo)
  role:SetTouchable(false)
  local ballLevelCfg = AagrData.Instance():GetBallLevelCfg(ballInfo:GetLevel())
  if ballLevelCfg then
    warn("[AagrProtocols:_ProcessModel] roleId, ballLevel, modelid, modelRatio:", Int64.tostring(role.roleId), ballInfo:GetLevel(), ballLevelCfg.modelId, ballLevelCfg.modelRatio)
    if role.mModelId ~= ballLevelCfg.modelId then
      role:DestroyModel()
      role.mModelId = ballLevelCfg.modelId
      role:LoadCurrentModel2()
    end
  else
    warn("[ERROR][AagrProtocols:_ProcessModel] ballLevelCfg nil for ballLevel:", ballInfo:GetLevel())
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
def.static("table", "table", "table")._ProcessName = function(role, ballInfo, activityCfg)
  local colorId
  local bProtect = ballInfo:CheckState(PlayerStateEnum.PROTECT)
  if bProtect then
    colorId = activityCfg.protectedNameColorId
  else
    colorId = activityCfg.notProtectedStateNameColorId
  end
  local nameColor = GetColorData(colorId)
  if not AagrUtils.IsSameColor(nameColor, role.m_uNameColor) then
    warn("[AagrProtocols:_ProcessName] role bProtect, colorId:", Int64.tostring(role.roleId), bProtect, colorId)
    role:SetName("", nameColor)
  end
end
def.static("table", "table", "table", "boolean")._ProcessMax = function(role, ballInfo, activityCfg, bOldMax)
  local bMax = ballInfo:CheckState(PlayerStateEnum.MAX_LEVEL)
  local function onModelLoaded()
    if bMax then
      warn("[AagrProtocols:_ProcessMax] show role max state:", Int64.tostring(role.roleId))
      local maxDuration = AagrData.Instance():GetBallMaxDuration()
      local maxEndTime = ballInfo.coolTime
      if maxEndTime > _G.GetServerTime() and maxDuration > 0 then
        role:ShowBallCooldownPate(maxEndTime, maxDuration)
      else
        warn("[ERROR][AagrProtocols:_ProcessMax] show fail! maxEndTime, _G.GetServerTime(), maxDuration>0:", os.date("%c", maxEndTime), os.date("%c", _G.GetServerTime()), maxDuration)
      end
      AagrUtils.AddPlayerEffect(role, activityCfg.playerBerserkSfxId)
    else
      warn("[AagrProtocols:_ProcessName] hide role max state:", Int64.tostring(role.roleId))
      if role:IsBallCooldowning() then
        role:DestroyBallCooldownPate()
      end
      AagrUtils.RemovePlayerEffect(role, activityCfg.playerBerserkSfxId)
    end
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("aagr_max", onModelLoaded)
  else
    onModelLoaded()
  end
end
def.static("table", "table", "table")._ProcessBuff = function(role, ballInfo, oldStates)
  local curSpeedState = ballInfo:CheckState(PlayerStateEnum.BUFF_SPEED)
  local buffCfg = AagrData.Instance():GetMapEntityCfgByType(GroundItemType.SPEED)
  local effectId = buffCfg and buffCfg.playerSfxId or 0
  if curSpeedState then
    warn("[AagrProtocols:_ProcessBuff] show role BUFF_SPEED effect:", Int64.tostring(role.roleId), effectId)
    AagrUtils.AddPlayerEffect(role, effectId)
  else
    warn("[AagrProtocols:_ProcessBuff] hide role BUFF_SPEED effect:", Int64.tostring(role.roleId), effectId)
    AagrUtils.RemovePlayerEffect(role, effectId)
  end
  local curFreezeState = ballInfo:CheckState(PlayerStateEnum.BUFF_FREEZE)
  local buffCfg = AagrData.Instance():GetMapEntityCfgByType(GroundItemType.FREEZE)
  local effectId = buffCfg and buffCfg.playerSfxId or 0
  if curFreezeState then
    warn("[AagrProtocols:_ProcessBuff] show role BUFF_FREEZE effect:", Int64.tostring(role.roleId), effectId)
    AagrUtils.AddPlayerEffect(role, effectId)
  else
    warn("[AagrProtocols:_ProcessBuff] hide role BUFF_FREEZE effect:", Int64.tostring(role.roleId), effectId)
    AagrUtils.RemovePlayerEffect(role, effectId)
  end
  local curGhostState = ballInfo:CheckState(PlayerStateEnum.BUFF_GHOST)
  local function onModelLoaded()
    if curGhostState then
      local buffCfg = AagrData.Instance():GetMapEntityCfgByType(GroundItemType.GHOST)
      if buffCfg then
        warn("[AagrProtocols:_ProcessBuff] show role BUFF_GHOST effect:", Int64.tostring(role.roleId), buffCfg.arg)
        role.checkAlpha = false
        role:SetAlpha(buffCfg.arg / 100)
      else
        warn("[ERROR][AagrProtocols:_ProcessBuff] buffCfg nil for GroundItemType.GHOST.")
      end
    else
      warn("[AagrProtocols:_ProcessBuff] hide role BUFF_GHOST effect:", Int64.tostring(role.roleId))
      role.checkAlpha = true
      role:CloseAlpha()
    end
  end
  if role:IsInLoading() then
    role:AddOnLoadCallback("aagr_buff_ghost", onModelLoaded)
  else
    onModelLoaded()
  end
end
def.static("table", "table", "table", "number")._ProcessLevelChange = function(role, ballInfo, activityCfg, oldLevel)
  if not Int64.eq(role.roleId, _G.GetMyRoleID()) then
    return
  end
  if oldLevel > 0 and oldLevel < ballInfo:GetLevel() then
    local effectCfg = GetEffectRes(activityCfg.playerLevelUpSfxId)
    if effectCfg then
      warn("[AagrProtocols:_ProcessLevelChange] show role levelup effect:", Int64.tostring(role.roleId), activityCfg.playerLevelUpSfxId)
      do
        local effect = GUIFxMan.Instance():Play(effectCfg.path, "", 0, 0, -1, false)
        GameUtil.AddGlobalTimer(EFFECT_DURATION, true, function()
          GUIFxMan.Instance():RemoveFx(effect)
        end)
      end
    else
      warn("[ERROR][AagrMgr:TestRoleEffect] effectCfg nil for index, effectId, effectName:", index, effectId, effectName)
    end
  end
  if oldLevel >= AagrData.Instance():GetMaxBallLevel() and ballInfo:GetLevel() == 1 then
    local effectCfg = GetEffectRes(activityCfg.playerLevelDownSfxId)
    if effectCfg then
      warn("[AagrProtocols:_ProcessLevelChange] show cooldown effect:", Int64.tostring(role.roleId), activityCfg.playerLevelDownSfxId)
      do
        local effect = GUIFxMan.Instance():Play(effectCfg.path, "", 0, 0, -1, false)
        GameUtil.AddGlobalTimer(EFFECT_DURATION, true, function()
          GUIFxMan.Instance():RemoveFx(effect)
        end)
      end
    else
      warn("[ERROR][AagrMgr:TestRoleEffect] effectCfg nil for index, effectId, effectName:", index, effectId, effectName)
    end
  end
end
def.static("table", "table", "table")._ProcessDead = function(role, ballInfo, oldStates)
  local oldTempDeadState = AagrUtils.CheckBallState(PlayerStateEnum.TEMP_DEATH, oldStates)
  local curTempDeadState = ballInfo:CheckState(PlayerStateEnum.TEMP_DEATH)
  local oldDeadState = AagrUtils.CheckBallState(PlayerStateEnum.DEATH, oldStates)
  local curDeadState = ballInfo:CheckState(PlayerStateEnum.DEATH)
  if oldTempDeadState ~= curTempDeadState then
    if curTempDeadState and not curDeadState then
      warn("[AagrProtocols:_ProcessDead] role temp dead:", Int64.tostring(role.roleId))
      role:Dead()
    else
      warn("[AagrProtocols:_ProcessDead] role not temp dead:", Int64.tostring(role.roleId), curTempDeadState, curDeadState)
    end
  else
  end
  if role.m_visible == curDeadState then
    local function onModelLoaded()
      if curDeadState then
        warn("[AagrProtocols:_ProcessDead] role dead:", Int64.tostring(role.roleId))
        role:SetVisible(false)
      else
        warn("[AagrProtocols:_ProcessDead] role alive:", Int64.tostring(role.roleId))
        role:SetVisible(true)
      end
    end
    if role:IsInLoading() then
      role:AddOnLoadCallback("aagr_dead", onModelLoaded)
    else
      onModelLoaded()
    end
  else
  end
end
AagrProtocols.Commit()
return AagrProtocols
