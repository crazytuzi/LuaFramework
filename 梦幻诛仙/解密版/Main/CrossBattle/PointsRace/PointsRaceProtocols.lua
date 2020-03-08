local Lplus = require("Lplus")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local AnnouncementTip = require("GUI.AnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local PointsRaceProtocols = Lplus.Class("PointsRaceProtocols")
local def = PointsRaceProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SStageBroadcast", PointsRaceProtocols.OnSStageBroadcast)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SZoneDrawLotsSuccess", PointsRaceProtocols.OnSDrawSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SZoneDrawLotsFail", PointsRaceProtocols.OnSDrawFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRacePanelInfoSuccess", PointsRaceProtocols.OnSCheckEnterConditions)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SPointRaceReadySuccess", PointsRaceProtocols.OnSEnterArenaSucc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SPointRaceReadyFail", PointsRaceProtocols.OnSEnterArenaFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SPointRaceLeaveSuccess", PointsRaceProtocols.OnSLeaveArenaSucc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SPointRaceLeaveFail", PointsRaceProtocols.OnSLeaveArenaFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceDataSuccess", PointsRaceProtocols.OnSGetPointRaceDataSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceDataFail", PointsRaceProtocols.OnSGetPointRaceDataFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceRankSuccess", PointsRaceProtocols.OnSGetRankList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceRankFail", PointsRaceProtocols.OnSGetRankListFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SyncPointRaceEnd", PointsRaceProtocols.OnSRoundOver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SyncPointRacePromotion", PointsRaceProtocols.OnSPointsRaceOverPromote)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceRankLocalSuccess", PointsRaceProtocols.OnSGetPointRaceRankLocalSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetPointRaceRankLocalFail", PointsRaceProtocols.OnSGetPointRaceRankLocalFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SyncPointRaceTitle", PointsRaceProtocols.OnSPointsRaceTitle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SyncPointRaceCorpsid", PointsRaceProtocols.OnSyncPointRaceCorpsId)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SyncNextMatchCountDown", PointsRaceProtocols.OnSyncNextMatchCountDown)
end
def.static("table").OnSStageBroadcast = function(p)
  warn(string.format("[PointsRaceProtocols:OnSStageBroadcast] On SStageBroadcast! p.stage=[%d], p.zone=[%d], p.countdown=[%d], p.index=[%d], p.backup=[%d].", p.stage, p.zone, p.countdown, p.index, p.backup))
  PointsRaceData.Instance():SetPromoted(true)
  PointsRaceData.Instance():SetZoneId(p.zone)
  PointsRaceData.Instance():SetRoundInfo(p.index, p.backup and p.backup > 0 or false)
  local SStageBroadcast = require("netio.protocol.mzm.gsp.crossbattle.SStageBroadcast")
  if SStageBroadcast.STG_PREPARE == p.stage then
    PointsRaceProtocols.OnStagePrepare(p)
  elseif SStageBroadcast.STG_MATCH == p.stage then
    PointsRaceProtocols.OnStageMatching(p)
  elseif SStageBroadcast.STG_FINISH_MATCH == p.stage then
    PointsRaceProtocols.OnStageStopMatch(p)
  elseif SStageBroadcast.STG_RETURN_ORIGINAL == p.stage then
    PointsRaceProtocols.OnStageReturn(p)
  else
    PointsRaceProtocols.OnStageClosed(p)
  end
end
def.static("table").OnStagePrepare = function(p)
  PointsRaceData.Instance():SetCurStage(PointsRaceMgr.StageEnum.PREPARE, p.countdown)
  if PointsRaceMgr.Instance():IsRaceOpen(false) then
    AnnouncementTip.Announce(textRes.PointsRace.RACE_OPEN_BROADCAST)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {
      str = textRes.PointsRace.RACE_OPEN_BROADCAST
    })
    if not PointsRaceUtils.IsInPointsRaceMap() then
      PointsRaceProtocols._ShowEnterArenaConfirm()
    end
  end
end
def.static()._ShowEnterArenaConfirm = function()
  if PointsRaceData.Instance():IsReturnFromCenter() then
    warn("[PointsRaceProtocols:_ShowEnterArenaConfirm] block Confirm by return form center!")
    PointsRaceData.Instance():SetReturnFromCenter(false)
    return
  end
  warn("[PointsRaceProtocols:_ShowEnterArenaConfirm] Show Enter Arena Confirm!")
  local CorpsInterface = require("Main.Corps.CorpsInterface")
  if CorpsInterface.HasCorps() and PointsRaceUtils.IsCrossBattlePointsRaceStage() then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PointsRace.RACE_ENTER_CONFIRM_TITLE, textRes.PointsRace.RACE_ENTER_CONFIRM_DESC, function(id, tag)
      if id == 1 then
        local npcId = PointsRaceUtils.GetEntranceNPCId()
        warn("[PointsRaceProtocols:OnStagePrepare] go to npc:", npcId)
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
      end
    end, nil)
  end
end
def.static("table").OnStageMatching = function(p)
  PointsRaceData.Instance():SetCurStage(PointsRaceMgr.StageEnum.MATCHING, p.countdown)
  warn("[PointsRaceProtocols:OnStageMatching] UpdateNextMatchTime On PointsRace Stage MATCHING.")
  PointsRaceData.Instance():UpdateNextMatchTime()
  if PointsRaceMgr.Instance():IsRaceOpen(false) and not PointsRaceUtils.IsInPointsRaceMap() then
    PointsRaceProtocols._ShowEnterArenaConfirm()
  end
end
def.static("table").OnStageStopMatch = function(p)
  PointsRaceData.Instance():SetCurStage(PointsRaceMgr.StageEnum.STOP_MATCH, p.countdown)
end
def.static("table").OnStageReturn = function(p)
  PointsRaceData.Instance():SetCurStage(PointsRaceMgr.StageEnum.RETURN, 10)
  if PointsRaceMgr.Instance():IsRaceOpen(false) then
    Toast(textRes.PointsRace.RACE_ROUND_END_BACK)
  end
end
def.static("table").OnStageClosed = function(p)
  PointsRaceData.Instance():SetCurStage(PointsRaceMgr.StageEnum.CLOSED, 0)
end
def.static().SendCDraw = function()
  warn("[PointsRaceProtocols:SendCDraw] Send CZoneDrawLots!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CZoneDrawLots").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSDrawSuccess = function(p)
  warn("[PointsRaceProtocols:OnSDrawSuccess] On SZoneDrawLotsSuccess!")
  PointsRaceData.Instance():SetZoneId(p.zone)
  local PointsRaceDrawPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceDrawPanel")
  PointsRaceDrawPanel.ShowPanel(p.zone)
end
def.static("table").OnSDrawFailed = function(p)
  warn("[PointsRaceProtocols:OnSDrawFailed] On SZoneDrawLotsFail! p.retcode:", p.retcode)
  local SZoneDrawLotsFail = require("netio.protocol.mzm.gsp.crossbattle.SZoneDrawLotsFail")
  local errString
  if SZoneDrawLotsFail.ERROR_STAGE == p.retcode then
    errString = textRes.PointsRace.DRAW_FAIL_WRONG_STAGE
  elseif SZoneDrawLotsFail.ERROR_NOT_TEAM_LEADER == p.retcode then
    errString = textRes.PointsRace.DRAW_FAIL_NOT_CAPTAIN
  elseif SZoneDrawLotsFail.ERROR_DRAW_LOTS == p.retcode then
    errString = textRes.PointsRace.DRAW_FAIL_ALREADY_DRAW
  elseif SZoneDrawLotsFail.ERROR_SYSTEM == p.retcode then
    errString = textRes.PointsRace.DRAW_FAIL_SYSTEM
  elseif SZoneDrawLotsFail.ERROR_NOT_PROMOTION == p.retcode then
    errString = textRes.PointsRace.DRAW_FAIL_NOT_PROMOTION
  else
    warn("[ERROR][PointsRaceProtocols:OnSDrawFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PointsRaceProtocols:OnSDrawFailed] err:", errString)
    Toast(errString)
  end
end
def.static().SendCCheckEnterConditions = function()
  warn("[PointsRaceProtocols:SendCCheckEnterConditions] Send CGetPointRacePanelInfo!")
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local rountIdx = PointsRaceData.Instance():GetRoundIndex()
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetPointRacePanelInfo").new(activityId, rountIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSCheckEnterConditions = function(p)
  warn("[PointsRaceProtocols:OnSCheckEnterConditions] On SGetPointRacePanelInfoSuccess!")
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  local status = {
    p.is_five_role_team > 0,
    0 < p.is_in_one_corps,
    0 < p.is_can_join_point_race,
    0 < p.is_role_same_with_sign_up
  }
  CrossBattleConditionCheckPanel.Instance():SetConditionCheckStatus(status)
end
def.static().SendCEnterArena = function()
  warn("[PointsRaceProtocols:SendCEnterArena] Send CPointRaceReady!")
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local rountIdx = PointsRaceData.Instance():GetRoundIndex()
  local p = require("netio.protocol.mzm.gsp.crossbattle.CPointRaceReady").new(activityId, rountIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEnterArenaSucc = function(p)
  warn("[PointsRaceProtocols:OnSEnterArenaSucc] On SPointRaceReadySuccess!")
  warn("[PointsRaceProtocols:OnSEnterArenaSucc] show PointsRaceLoadingPanel on SPointRaceReadySuccess!")
  local PointsRaceLoadingPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceLoadingPanel")
  PointsRaceLoadingPanel.Instance():ShowPanel(true)
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():HidePanel()
  local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
  CrossBattlePanel.Instance():Hide()
end
def.static("table").OnSEnterArenaFail = function(p)
  warn("[PointsRaceProtocols:OnSEnterArenaFail] On SPointRaceReadyFail! p.retcode:", p.retcode)
  local SPointRaceReadyFail = require("netio.protocol.mzm.gsp.crossbattle.SPointRaceReadyFail")
  local errString
  if SPointRaceReadyFail.ERROR_CORPS_NOT_PROMOTION == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_NOT_PROMOTION
  elseif SPointRaceReadyFail.ERROR_POINT_RACE_TIME == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_WRONG_TIME
  elseif SPointRaceReadyFail.ERROR_NOT_IN_TEAM == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_NOT_IN_TEAM
  elseif SPointRaceReadyFail.ERROR_TEAM_MEMBER_NOT_ENOUGH == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_MEMBER_NOT_ENOUGH
  elseif SPointRaceReadyFail.ERROR_TEAM_NOT_MATCH_CORPS == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_NOT_MATCH_CORPS
  elseif SPointRaceReadyFail.ERROR_CORPS_ZONE == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_NO_ZONE
  elseif SPointRaceReadyFail.ERROR_UN_KNOW == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_UNKNOWN_SERVER_ERR
  elseif SPointRaceReadyFail.ERROR_GEN_TOKEN == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_GEN_TOKEN
  elseif SPointRaceReadyFail.ERROR_DATA_TRANSFOR == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_DATA_TRANSFOR
  elseif SPointRaceReadyFail.ERROR_PENDING == p.retcode then
    errString = textRes.PointsRace.ENTER_FAIL_WAITING
  else
    warn("[ERROR][PointsRaceProtocols:OnSEnterArenaFail] unhandled p.retcode:", p.retcode)
  end
  if SPointRaceReadyFail.ERROR_PENDING ~= p.retcode then
    warn("[PointsRaceProtocols:OnSEnterArenaFail] hide PointsRaceLoadingPanel on p.retcode:", p.retcode)
    local PointsRaceLoadingPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceLoadingPanel")
    PointsRaceLoadingPanel.Instance():DestroyPanel()
  end
  if errString then
    warn("[PointsRaceProtocols:OnSEnterArenaFail] err:", errString)
    Toast(errString)
  end
end
def.static("table", "table").OnSPointsRaceTitle = function(role, p)
  if role == nil then
    warn("[ERROR][PointsRaceProtocols:OnSPointsRaceTitle] role is nil")
    return
  end
  if p == nil then
    warn("[ERROR][PointsRaceProtocols:OnSPointsRaceTitle] p is nil")
    return
  end
  if p.corps_id then
    local myCorpsId = PointsRaceData.Instance():GetCrossBattleCorpsID()
    warn(string.format("[PointsRaceProtocols:OnSPointsRaceTitle] myCorpsId=[%s], p.corps_id.=[%s].", tostring(myCorpsId), tostring(p.corps_id)))
    local colorId = 0
    if myCorpsId and p.corps_id:eq(myCorpsId) then
      colorId = constant.CrossBattleConsts.OWN_CORPS_TITLE_COLOR_ID
    else
      colorId = constant.CrossBattleConsts.OTHER_CORPS_TITLE_COLOR_ID
    end
    local titleColor = GetColorData(colorId)
    local title = GetStringFromOcts(p.corps_name)
    role:SetShowTitle(title, titleColor)
    local CorpsUtils = require("Main.Corps.CorpsUtils")
    local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(p.corps_badge_id)
    if badgeCfg then
      role:SetOrganizationIcon(badgeCfg.iconId)
    end
  else
    warn("[ERROR][PointsRaceProtocols:OnSPointsRaceTitle] p.corps_id is nil")
    role:SetShowTitle("", nil)
    role:SetOrganizationIcon(0)
  end
end
def.static("table").OnSyncPointRaceCorpsId = function(p)
  warn("[PointsRaceProtocols:OnSyncPointRaceCorpsId] On SyncPointRaceCorpsid, p.corps_id:", p.corps_id and Int64.tostring(p.corps_id))
  PointsRaceData.Instance():SetCrossBattleCorpsID(p.corps_id)
end
def.static("table").OnSyncNextMatchCountDown = function(p)
  warn("[PointsRaceProtocols:OnSyncNextMatchCountDown] On SyncNextMatchCountDown, p.countdown:", p.countdown)
  Toast(textRes.PointsRace.MATCH_FAIL)
  warn("[PointsRaceProtocols:OnSyncNextMatchCountDown] UpdateNextMatchTime On SyncNextMatchCountDown.")
  PointsRaceData.Instance():OnMatchFailed(p.countdown)
end
def.static().SendCLeaveArena = function()
  warn("[PointsRaceProtocols:SendCLeaveArena] Send CPointRaceLeave!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CPointRaceLeave").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSLeaveArenaSucc = function(p)
  warn("[PointsRaceProtocols:OnSLeaveArenaSucc] On SPointRaceLeaveSuccess!")
  PointsRaceData.Instance():SetReturnFromCenter(true)
  warn("[PointsRaceProtocols:OnSLeaveArenaSucc] show PointsRaceLoadingPanel on SLeaveArenaSucc!")
  local PointsRaceLoadingPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceLoadingPanel")
  PointsRaceLoadingPanel.Instance():ShowPanel(false)
end
def.static("table").OnSLeaveArenaFail = function(p)
  warn("[PointsRaceProtocols:OnSLeaveArenaFail] On SPointRaceLeaveFail! p.retcode:", p.retcode)
  local errString
  local SPointRaceLeaveFail = require("netio.protocol.mzm.gsp.crossbattle.SPointRaceLeaveFail")
  if SPointRaceLeaveFail.ERROR_IN_FIGHT == p.retcode then
    errString = textRes.PointsRace.QUIT_FAIL_IN_FIGHT
  elseif SPointRaceLeaveFail.ERROR_TEAM == p.retcode then
    errString = textRes.PointsRace.QUIT_FAIL_TEAM_ERR
  elseif SPointRaceLeaveFail.ERROR_NOT_TEAM_LEADER == p.retcode then
    errString = textRes.PointsRace.QUIT_FAIL_NOT_CAPTAIN
  elseif SPointRaceLeaveFail.ERROR_TEAM_MEMBER == p.retcode then
    errString = textRes.PointsRace.QUIT_FAIL_MEMBER_NUMBER_ERR
  elseif SPointRaceLeaveFail.ERROR_CORPS_MEMBER == p.retcode then
    errString = textRes.PointsRace.QUIT_FAIL_MEMBER_ERR
  else
    warn("[ERROR][PointsRaceProtocols:OnSLeaveArenaFail] unhandled p.retcode:", p.retcode)
  end
  warn("[PointsRaceProtocols:OnSLeaveArenaFail] hide PointsRaceLoadingPanel on SPointRaceLeaveFail!")
  local PointsRaceLoadingPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceLoadingPanel")
  PointsRaceLoadingPanel.Instance():DestroyPanel()
  if errString then
    warn("[PointsRaceProtocols:OnSLeaveArenaFail] err:", errString)
    Toast(errString)
  end
end
def.static().SendCGetPointRaceData = function()
  warn("[PointsRaceProtocols:SendCGetPointRaceData] Send CGetPointRaceData!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetPointRaceData").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetPointRaceDataSuccess = function(p)
  warn("[PointsRaceProtocols:OnSGetPointRaceDataSuccess] On SGetPointRaceDataSuccess!")
  local PointsRaceInfoPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceInfoPanel")
  if PointsRaceInfoPanel.Instance():IsShow() then
    PointsRaceInfoPanel.Instance():OnSGetPointRaceDataSuccess(p)
  end
end
def.static("table").OnSGetPointRaceDataFail = function(p)
  warn("[PointsRaceProtocols:OnSGetPointRaceDataFail] On SGetPointRaceDataFail! p.retcode:", p.retcode)
  local errString
  if errString then
    warn("[PointsRaceProtocols:OnSGetPointRaceDataFail] err:", errString)
    Toast(errString)
  end
end
def.static("number", "number", "number").SendCGetRankList = function(rankType, from, to)
  warn(string.format("[PointsRaceProtocols:SendCGetRankList] send CGetPointRaceRank, request form[%d] to[%d] for type[%d].", from, to, rankType))
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetPointRaceRank").new(rankType, from, to)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRankList = function(p)
  warn(string.format("[PointsRaceProtocols:OnSGetRankList] receive SGetPointRaceRankSuccess, ranklist form[%d] to[%d] for type[%d].", p.from, p.to, p.rank_type))
  local PointsRaceInfoPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceInfoPanel")
  if PointsRaceInfoPanel.Instance():IsShow() then
    PointsRaceInfoPanel.Instance():OnSGetRankList(p)
  end
end
def.static("table").OnSGetRankListFail = function(p)
  warn("[PointsRaceProtocols:OnSGetRankListFail] On SGetPointRaceRankFail! p.retcode:", p.retcode)
  local errString
  if errString then
    warn("[PointsRaceProtocols:OnSGetRankListFail] err:", errString)
    Toast(errString)
  end
  local PointsRaceInfoPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceInfoPanel")
  if PointsRaceInfoPanel.Instance():IsShow() then
    PointsRaceInfoPanel.Instance():OnSGetRankListFail(p)
  end
end
def.static("number", "number", "number", "number", "number").SendCGetZoneRankList = function(zoneId, round, rankType, from, to)
  if rankType ~= 0 then
    round = 0
  end
  warn(string.format("[PointsRaceProtocols:SendCGetZoneRankList] send CGetPointRaceRankLocal, request zone[%d] round[%d] form[%d] to[%d] for type[%d].", zoneId, round, from, to, rankType))
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetPointRaceRankLocal").new(round, constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, zoneId, from, to)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetPointRaceRankLocalSuccess = function(p)
  warn("OnSGetPointRaceRankLocalSuccess")
  if p.time_point_cfgid == 0 then
    p.rank_type = 1
  else
    p.rank_type = 0
  end
  local CrossBattlePointsFightInfoPanel = require("Main.CrossBattle.ui.CrossBattlePointsFightInfoPanel")
  if CrossBattlePointsFightInfoPanel.Instance():IsShow() then
    CrossBattlePointsFightInfoPanel.Instance():OnSGetRankList(p)
  end
end
def.static("table").OnSGetPointRaceRankLocalFail = function(p)
  warn("OnSGetPointRaceRankLocalFail\239\188\154" .. p.retcode)
  if textRes.CrossBattle.Schedule.SGetPointRaceRankLocalFail[p.retcode] then
    Toast(textRes.CrossBattle.Schedule.SGetPointRaceRankLocalFail[p.retcode])
  end
  local CrossBattlePointsFightInfoPanel = require("Main.CrossBattle.ui.CrossBattlePointsFightInfoPanel")
  if CrossBattlePointsFightInfoPanel.Instance():IsShow() then
    CrossBattlePointsFightInfoPanel.Instance():OnSGetRankListFail(p)
  end
end
def.static("table").OnSRoundOver = function(p)
  warn("[PointsRaceProtocols:OnSRoundOver] On SyncPointRaceEnd!")
  AnnouncementTip.Announce(textRes.PointsRace.RACE_ROUND_END_BROADCAST)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {
    str = textRes.PointsRace.RACE_ROUND_END_BROADCAST
  })
end
def.static("table").OnSPointsRaceOverPromote = function(p)
  warn("[PointsRaceProtocols:OnSPointsRaceOver] On SyncPointRacePromotion!")
  if p.promotions and #p.promotions > 0 then
    PointsRaceMgr.Instance():PlayPromoteEffect()
    local promoteStr = textRes.PointsRace.RACE_PROMOTE_BROADCAST
    local promoteStrTop = textRes.PointsRace.RACE_PROMOTE_BROADCAST_TOP
    local teams = ""
    for i = 1, #p.promotions do
      local teamName = _G.GetStringFromOcts(p.promotions[i])
      teams = teams .. teamName
      if i < #p.promotions then
        teams = teams .. "\227\128\129"
      end
    end
    promoteStr = string.format(promoteStr, teams, PointsRaceUtils.GetZoneName(p.zone), PointsRaceUtils.GetPromoteCount())
    promoteStrTop = string.format(promoteStrTop, teams, PointsRaceUtils.GetZoneName(p.zone), PointsRaceUtils.GetPromoteCount())
    InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(promoteStrTop, 0, "Group_3")
    AnnouncementTip.Announce(promoteStr)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = promoteStr})
  end
end
PointsRaceProtocols.Commit()
return PointsRaceProtocols
