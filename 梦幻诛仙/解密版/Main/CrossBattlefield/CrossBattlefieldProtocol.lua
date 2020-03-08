local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattlefieldProtocol = Lplus.Class(MODULE_NAME)
local CrossBattlefieldModule = Lplus.ForwardDeclare("Main.CrossBattlefield.CrossBattlefieldModule")
local def = CrossBattlefieldProtocol.define
def.static().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SJoinCrossFieldMatchSuccess", CrossBattlefieldProtocol.OnSJoinCrossFieldMatchSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SJoinCrossFieldMatchFail", CrossBattlefieldProtocol.OnSJoinCrossFieldMatchFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SCancelCrossFieldMatchSuccess", CrossBattlefieldProtocol.OnSCancelCrossFieldMatchSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SCancelCrossFieldMatchFail", CrossBattlefieldProtocol.OnSCancelCrossFieldMatchFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldMatchFail", CrossBattlefieldProtocol.OnSSynCrossFieldMatchFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldMatchInfo", CrossBattlefieldProtocol.OnSSynCrossFieldMatchInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldWaitNextRoundMatch", CrossBattlefieldProtocol.OnSSynCrossFieldWaitNextRoundMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldResultInfo", CrossBattlefieldProtocol.OnSSynCrossFieldResultInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldSeasonInfo", CrossBattlefieldProtocol.OnSSynCrossFieldSeasonInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldForbidMatchInfo", CrossBattlefieldProtocol.OnSSynCrossFieldForbidMatchInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SSynCrossFieldDailyAward", CrossBattlefieldProtocol.OnSSynCrossFieldDailyAward)
end
local debug = false
local function sendProtocol(p)
  if debug then
    printInfo("[DEBUG] sendProtocol " .. p.class.__cname)
  else
    gmodule.network.sendProtocol(p)
  end
end
def.static("number").CJoinCrossFieldMatchReq = function(battlefieldActId)
  local p = require("netio.protocol.mzm.gsp.crossfield.CJoinCrossFieldMatchReq").new(battlefieldActId)
  sendProtocol(p)
end
def.static("number").CCancelCrossFieldMatchReq = function(battlefieldActId)
  local p = require("netio.protocol.mzm.gsp.crossfield.CCancelCrossFieldMatchReq").new(battlefieldActId)
  sendProtocol(p)
end
def.static("table").OnSJoinCrossFieldMatchSuccess = function(p)
  Toast(textRes.CrossBattlefield[1])
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.START_MATCH_SUCCEED, {
    activityId = p.activity_cfg_id
  })
end
def.static("table").OnSJoinCrossFieldMatchFail = function(p)
  local text = textRes.CrossBattlefield.CrossFieldErrorCode[p.res]
  if text == nil then
    text = textRes.CrossBattlefield.CrossFieldErrorCode.START_MATCH_UNKNOW_ERR:format(p.res)
  end
  Toast(text)
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.START_MATCH_FAILED, {
    activityId = p.activity_cfg_id
  })
end
def.static("table").OnSCancelCrossFieldMatchSuccess = function(p)
  CrossBattlefieldModule.Instance():HideMatchingPanel()
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.CANCEL_MATCH_SUCCEED, {
    activityId = p.activity_cfg_id
  })
end
def.static("table").OnSCancelCrossFieldMatchFail = function(p)
  local text = textRes.CrossBattlefield.CrossFieldErrorCode[p.res]
  if text == nil then
    text = textRes.CrossBattlefield.CrossFieldErrorCode.CANCEL_MATCH_UNKNOW_ERR:format(p.res)
  end
  Toast(text)
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.CANCEL_MATCH_FAILED, {
    activityId = p.activity_cfg_id
  })
end
def.static("table").OnSSynCrossFieldMatchFail = function(p)
  local text = textRes.CrossBattlefield.SSynCrossFieldMatchFail[p.res]
  if text == nil then
    text = textRes.CrossBattlefield.SSynCrossFieldMatchFail.UNKNOW_ERR:format(p.res)
  end
  Toast(text)
  CrossBattlefieldModule.Instance():HideMatchingPanel()
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.MATCH_FAILED, {
    activityId = p.activity_cfg_id
  })
end
def.static("table").OnSSynCrossFieldMatchInfo = function(p)
  print("OnSSynCrossFieldMatchInfo", p.activity_cfg_id, ",", p.process)
  local CrossFieldMatchProcess = require("netio.protocol.mzm.gsp.crossfield.CrossFieldMatchProcess")
  if p.process == CrossFieldMatchProcess.PROCESS_MATCHING then
    if _G.IsEnteredWorld() then
      CrossBattlefieldModule.Instance():ShowMatchingPanel(p.activity_cfg_id)
    else
      CrossBattlefieldModule.Instance():SetMatchingActivityId(p.activity_cfg_id)
    end
  elseif p.process == CrossFieldMatchProcess.PROCESS_TRANSFOR_DATA_SUC and _G.IsEnteredWorld() then
    CrossBattlefieldModule.Instance():ShowLoadingPanel(p.activity_cfg_id)
  end
end
def.static("table").OnSSynCrossFieldWaitNextRoundMatch = function(p)
  warn(textRes.CrossBattlefield.SSynCrossFieldWaitNextRoundMatch.ERR_MSG:format(p.reason))
  if p.reason == p.class.REASON_NO_ROAM_SERVER then
    Toast(textRes.CrossBattlefield.SSynCrossFieldWaitNextRoundMatch[1])
  elseif p.reason == p.class.REASON_ROAM_SERVER_ROLE_TOO_MUCH or p.reason == p.class.REASON_MATCH_ROLE_TOO_MUCH then
    Toast(textRes.CrossBattlefield.SSynCrossFieldWaitNextRoundMatch.COMMON_ERR)
  end
end
def.static("table").OnSSynCrossFieldSeasonInfo = function(p)
  local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  seasonMgr:SetSeason(p.season)
  seasonMgr:SetStarNum(p.star_num)
  seasonMgr:SetWinPoint(p.win_point)
  seasonMgr:SetWinningStreak(p.straight_win_num)
  seasonMgr:SetCurStarGetTime(p.star_num_timestamp)
  seasonMgr:SetWeekPoint(p.current_week_point, p.last_get_point_time:ToNumber())
end
def.static("table").OnSSynCrossFieldResultInfo = function(p)
  local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  seasonMgr:SetSeason(p.season)
  seasonMgr:SetStarNum(p.current_star_num)
  seasonMgr:SetWinPoint(p.current_win_point)
  seasonMgr:SetWinningStreak(p.current_straight_win_num)
  seasonMgr:SetCurStarGetTime(p.star_num_timestamp)
  seasonMgr:SetWeekPoint(p.current_week_point, p.last_get_point_time:ToNumber())
  local params = {
    last = {
      starNum = p.original_star_num,
      winPoint = p.original_win_point
    },
    cur = {
      starNum = p.current_star_num,
      winPoint = p.current_win_point
    },
    bounceStreak = _G.constant.CCrossFieldConsts.STRAIGHT_WIN_NUM
  }
  params.cur.isMvp = p.is_mvp == 1
  params.cur.winningStreak = p.current_straight_win_num
  require("Main.CrossBattlefield.ui.BattlefieldResultPanel").Instance():ShowPanel(params)
end
def.static("table").OnSSynCrossFieldForbidMatchInfo = function(p)
  local timestamp = p.active_leave_field_timestamp
  if type(timestamp) == "number" then
    timestamp = Int64.new(timestamp)
  else
  end
  CrossBattlefieldModule.Instance():SetActiveLeaveTimestamp(timestamp)
end
local _enterWorldShowDailyAward
def.static("table").OnSSynCrossFieldDailyAward = function(p)
  local function showDailyAward()
    local AwardUtils = require("Main.Award.AwardUtils")
    local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.award_info, textRes.CrossBattlefield[8])
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    for _, v in ipairs(htmlTexts) do
      PersonalHelper.SendOut(v)
    end
  end
  local function delayShow()
    GameUtil.AddGlobalTimer(1, true, function()
      if _G.IsEnteredWorld() then
        showDailyAward()
      end
    end)
  end
  if _G.IsEnteredWorld() then
    delayShow()
    _enterWorldShowDailyAward = nil
  else
    _enterWorldShowDailyAward = delayShow
  end
end
def.static("table", "table").OnEnterWorld = function(params, context)
  if _enterWorldShowDailyAward then
    _enterWorldShowDailyAward()
    _enterWorldShowDailyAward = nil
  end
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  _enterWorldShowDailyAward = nil
end
return CrossBattlefieldProtocol.Commit()
