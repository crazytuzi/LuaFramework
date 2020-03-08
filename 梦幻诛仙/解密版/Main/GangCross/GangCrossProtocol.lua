local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangCrossProtocol = Lplus.Class(MODULE_NAME)
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = GangCrossProtocol.define
def.field("userdata").gangId = nil
def.field("number").stage = -1
def.field("number").actionPoint = 0
def.field("table").gangBattleInfo = nil
def.field("table").rivalGang = nil
def.field("table").gangIdMap = nil
def.field("table").targetPos = nil
def.field("boolean").showTip = false
def.field("number").preparePlayerNum = 0
def.field("boolean").needGoToBattle = false
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SCrossCompeteNormalResult", GangCrossProtocol.OnSCrossCompeteNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncSignUp", GangCrossProtocol.OnSSyncSignUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSignUpBrd", GangCrossProtocol.OnSSignUpBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncSignUpCancel", GangCrossProtocol.OnSSyncSignUpCancel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSignedUpFactionListRes", GangCrossProtocol.OnSSignedUpFactionListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SAgainstListRes", GangCrossProtocol.OnSAgainstListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncAgainst", GangCrossProtocol.OnSSyncAgainst)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncCompeteBrd", GangCrossProtocol.OnSSyncCompeteBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SEnterCrossCompeteMapInProgressBrd", GangCrossProtocol.OnSEnterCrossCompeteMapInProgressBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SEnterCrossCompeteMapFailBrd", GangCrossProtocol.OnSEnterCrossCompeteMapFailBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SEnterCrossCompeteMapSucceedBrd", GangCrossProtocol.OnSEnterCrossCompeteMapSucceedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncFactionPkScoreBrd", GangCrossProtocol.OnSSyncFactionPkScoreBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncFactionPlayerScoreBrd", GangCrossProtocol.OnSSyncFactionPlayerScoreBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncFactionPlayerNumberBrd", GangCrossProtocol.OnSSyncFactionPlayerNumberBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncRoleCompete", GangCrossProtocol.OnSSyncRoleCompete)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SDeductActionPointNotify", GangCrossProtocol.OnSDeductActionPointNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SWinFightBrd", GangCrossProtocol.OnSWinFightBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SCrossCompeteTitle", GangCrossProtocol.OnSCrossCompeteTitle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SWinLoseBrd", GangCrossProtocol.OnSWinLoseBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SReturnNotify", GangCrossProtocol.OnSReturnNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SWinStreakBrd", GangCrossProtocol.OnSWinStreakBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SWinLoseTimesNotify", GangCrossProtocol.OnSWinLoseTimesNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SSyncMatch", GangCrossProtocol.OnSSyncMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SCompeteResultBrd", GangCrossProtocol.OnSCompeteResultBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crosscompete.SStageBrd", GangCrossProtocol.OnSStageBrd)
end
def.static("table").OnSCrossCompeteNormalResult = function(p)
  local args = p.args
  local errorDes = textRes.GangCross.ErrorCode[p.result]
  if errorDes then
    if args and #args > 0 then
      Toast(string.format(errorDes, unpack(args)))
    else
      Toast(errorDes)
    end
  else
    Toast(textRes.GangCross[11] .. p.result)
  end
end
def.static("table").OnSSyncSignUp = function(p)
  GangCrossData.Instance():setCrossGangBattleState(true)
end
def.static("table").OnSSignUpBrd = function(p)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if p.manager_id == heroProp.id then
    Toast(textRes.GangCross[15])
    require("Main.GangCross.ui.JoinPanel").Instance():HidePanel()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CFactionListReq").new())
  else
    Toast(string.format(textRes.GangCross[16], p.manager_name))
  end
  GangCrossData.Instance():setCrossGangBattleState(true)
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SignUpBrd, nil)
end
def.static("table").OnSSyncSignUpCancel = function(p)
  GangCrossData.Instance():setCrossGangBattleState(false)
end
def.static("table").OnSSignedUpFactionListRes = function(p)
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SignedUpFactionList, {
    p.factions
  })
end
def.static("table").OnSAgainstListRes = function(p)
  local miss_turn_list = p.miss_turn_list
  local against_list = p.against_list or {}
  table.sort(against_list, function(a, b)
    return Int64.lt(a.faction1.factionid, b.faction1.factionid)
  end)
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_AgainstList, {against_list})
end
def.static("table").OnSEnterCrossCompeteMapInProgressBrd = function(p)
  local against = p.against
  local faction1 = against.faction1
  local faction2 = against.faction2
  local compete_index = against.compete_index
  local gangInfo1 = {
    factionid = faction1.factionid,
    svrname = GangCrossUtility.Instance():GetSvrNameForGangId(faction1.factionid) or "",
    svrlv = faction1.server_level,
    ganglv = faction1.faction_level,
    gangnum = faction1.member_count,
    gangname = faction1.faction_name
  }
  local gangInfo2 = {
    factionid = faction2.factionid,
    svrname = GangCrossUtility.Instance():GetSvrNameForGangId(faction2.factionid) or "",
    svrlv = faction2.server_level,
    ganglv = faction2.faction_level,
    gangnum = faction2.member_count,
    gangname = faction2.faction_name
  }
  require("Main.GangCross.ui.EnterListPanel").Instance():HidePanel()
  require("Main.GangCross.ui.VersusListPanel").Instance():HidePanel()
  require("Main.GangCross.ui.GangCrossLoadingPanel").Instance():ShowPanel({red = gangInfo1, blue = gangInfo2})
end
def.static("table").OnSEnterCrossCompeteMapFailBrd = function(p)
  GameUtil.AddGlobalTimer(1, true, function()
    require("Main.GangCross.ui.GangCrossLoadingPanel").Instance():HidePanel()
  end)
  local errorDes = textRes.GangCross.EnterMapFail[p.reason]
  if errorDes then
    Toast(errorDes)
  else
    Toast(string.format(textRes.GangCross.EnterMapFail[0], p.reason))
  end
end
def.static("table").OnSEnterCrossCompeteMapSucceedBrd = function(p)
end
def.static("table").OnSSyncAgainst = function(p)
  GangCrossBattleMgr.OnSSyncAgainst(p)
end
def.static("table").OnSSyncCompeteBrd = function(p)
  GangCrossBattleMgr.OnSSyncCompeteBrd(p)
end
def.static("table").OnSSyncFactionPkScoreBrd = function(p)
  GangCrossBattleMgr.OnSSyncFactionPkScoreBrd(p)
end
def.static("table").OnSSyncFactionPlayerScoreBrd = function(p)
  GangCrossBattleMgr.OnSSyncFactionPlayerScoreBrd(p)
end
def.static("table").OnSSyncFactionPlayerNumberBrd = function(p)
  GangCrossBattleMgr.OnSSyncFactionPlayerNumberBrd(p)
end
def.static("table").OnSSyncRoleCompete = function(p)
  GangCrossData.Instance():SetGangId(p.factionid)
  GangCrossData.Instance():SetCompeteIndex(p.compete_index)
  GangCrossData.Instance():SetGangTitle(p.designed_titleid)
  GangCrossBattleMgr.OnSSyncRoleCompetition(p)
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SyncRoleCompete, nil)
end
def.static("table", "table").OnSCrossCompeteTitle = function(role, p)
  GangCrossBattleMgr.OnSCrossCompeteTitle(role, p)
end
def.static("table").OnSWinFightBrd = function(p)
  GangCrossBattleMgr.OnSWinFightBrd(p)
end
def.static("table").OnSDeductActionPointNotify = function(p)
  GangCrossBattleMgr.OnSDeductActionPointNotify(p)
end
def.static("table").OnSWinLoseBrd = function(p)
  local resultInfo = {
    winner_id = p.winner_id,
    winner_name = p.winner_name,
    winner_score = p.winner_score,
    winner_participate_count = p.winner_participate_count,
    winner_left_count = p.winner_left_count,
    winner_win_times = p.winner_win_times,
    loser_id = p.loser_id,
    loser_name = p.loser_name,
    loser_score = p.loser_score,
    loser_participate_count = p.loser_participate_count,
    loser_left_count = p.loser_left_count,
    loser_win_times = p.loser_win_times,
    result = p.result
  }
  GangCrossData.Instance():SetResultWinLoss(resultInfo)
  GangCrossBattleMgr.OnSWinLoseBrd(p)
end
def.static("table").OnSReturnNotify = function(p)
  local reason = p.reason
  local SReturnNotify = require("netio.protocol.mzm.gsp.crosscompete.SReturnNotify")
  if reason == SReturnNotify.REASON_LOSE or reason == SReturnNotify.REASON_TREASURE or reason == SReturnNotify.REASON_FORCE_END or reason == SReturnNotify.REASON_WINNER_ACTIVE then
    local result = GangCrossData.Instance():GetResultWinLoss()
    if result then
      local winInfo = {
        gangid = result.winner_id,
        gangname = result.winner_name,
        svrname = GangCrossUtility.Instance():GetSvrNameForGangId(result.winner_id),
        score = result.winner_score,
        winnum = result.winner_win_times,
        joinnum = result.winner_participate_count,
        keepnum = result.winner_left_count
      }
      local lossInfo = {
        gangid = result.loser_id,
        gangname = result.loser_name,
        svrname = GangCrossUtility.Instance():GetSvrNameForGangId(result.loser_id),
        score = result.loser_score,
        winnum = result.loser_win_times,
        joinnum = result.loser_participate_count,
        keepnum = result.loser_left_count
      }
      require("Main.GangCross.ui.ResultPanel").Instance():ShowPanel({winInfo = winInfo, lossInfo = lossInfo})
    end
  else
    local state = GangCrossData.Instance():GetGangCrossState()
    if state == GangCrossData.BattleState.FIGHT then
      local fightInfo = GangCrossData.Instance():GetRoleFightInfo()
      local win = fightInfo.win_times or 0
      local loss = (fightInfo.lose_times or 0) + (fightInfo.escape_times or 0)
      require("Main.GangCross.ui.SingleResultPanel").Instance():ShowPanel({
        win = win,
        loss = loss,
        desc = textRes.GangCross[20]
      })
    else
      require("Main.GangCross.ui.GangCrossReturnPanel").Instance():ShowPanel()
    end
  end
end
def.static("table").OnSWinStreakBrd = function(p)
  GangCrossBattleMgr.OnSWinStreakBrd(p)
end
def.static("table").OnSWinLoseTimesNotify = function(p)
  GangCrossData.Instance():SetRoleFightInfo({
    win_times = p.win_times,
    lose_times = p.lose_times,
    win_streak = p.win_streak,
    escape_times = p.escape_times
  })
end
def.static("table").OnSSyncMatch = function(p)
  GangCrossData.Instance():SetMatchState(true)
  GangCrossData.Instance():SetCompeteIndex(p.compete_index)
  local actIndex = p.compete_index
  if actIndex >= constant.GangCrossConsts.MaxCompeteCountOfOneTime then
    actIndex = 1
  else
    actIndex = 0
  end
  local nowTime = GetServerTime()
  local actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
  actTime = actTime + constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + constant.GangCrossConsts.WaitMinutes * 60
  local beginTime = actTime + actIndex * minutes * 60
  local endTime = beginTime + constant.GangCrossConsts.PrepareMinutes * 60
  if nowTime >= beginTime and nowTime < endTime then
    local gangUtility = require("Main.Gang.GangUtility").Instance()
    gangUtility:AddGangActivityRedPoint(constant.GangCrossConsts.Activityid)
  end
end
def.static("table").OnSCompeteResultBrd = function(p)
  GangCrossBattleMgr.OnSCompeteResultBrd(p)
end
def.static("table").OnSStageBrd = function(p)
  GangCrossBattleMgr.OnSStageBrd(p)
end
return GangCrossProtocol.Commit()
