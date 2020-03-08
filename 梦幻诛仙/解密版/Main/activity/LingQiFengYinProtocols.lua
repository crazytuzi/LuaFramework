local Lplus = require("Lplus")
local LingQiFengYinProtocols = Lplus.Class("LingQiFengYinProtocols")
local def = LingQiFengYinProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static().StartLingQiFengYinTimer = function()
  if activityInterface._lingqifengyinTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(activityInterface._lingqifengyinTimerId)
    activityInterface._lingqifengyinTimerId = 0
  end
  local LingQiFengYinPanel = require("Main.activity.ui.LingQiFengYinPanel")
  activityInterface._lingqifengyinTimerId = GameUtil.AddGlobalTimer(1, false, function()
    local curTime = GetServerTime()
    LingQiFengYinPanel.Instance():SetLeftTime()
    if curTime >= activityInterface._lingqifengyinEndTime then
      local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
      if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED then
      end
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_End, {isTimeOver = true})
      LingQiFengYinProtocols.ResetLingQiFengYin()
    end
  end)
end
def.static().ResetLingQiFengYin = function()
  if activityInterface._lingqifengyinTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(activityInterface._lingqifengyinTimerId)
    activityInterface._lingqifengyinTimerId = 0
  end
  activityInterface._lingqifengyinStatus = 0
  activityInterface._lingqifengyinOpenIndex = 0
  activityInterface._lingqifengyinStartTime = 0
  activityInterface._lingqifengyinEndTime = 0
end
def.static("table").OnSMassExpInfo = function(msg)
  activityInterface._lingqifengyinStatus = msg.mass_exp_info.status
  activityInterface._lingqifengyinOpenIndex = msg.mass_exp_info.cur_index
  activityInterface._lingqifengyinStartTime = msg.mass_exp_info.start_timestamp
  activityInterface._lingqifengyinEndTime = msg.mass_exp_info.end_time
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_InfoChange, nil)
  LingQiFengYinProtocols.StartLingQiFengYinTimer()
end
def.static("table").OnSGetMassExpTaskSuccess = function(msg)
  activityInterface._lingqifengyinStatus = msg.mass_exp_info.status
  activityInterface._lingqifengyinOpenIndex = msg.mass_exp_info.cur_index
  activityInterface._lingqifengyinStartTime = msg.mass_exp_info.start_timestamp
  activityInterface._lingqifengyinEndTime = msg.mass_exp_info.end_time
  warn("LingQiFengYinProtocol Status:" .. activityInterface._lingqifengyinStatus)
  local LingQiFengYinPanel = require("Main.activity.ui.LingQiFengYinPanel")
  LingQiFengYinPanel.Instance():ShowDlg()
  LingQiFengYinProtocols.StartLingQiFengYinTimer()
end
def.static("table").OnSGetMassExpTaskFailed = function(msg)
  warn("Get LingQiFengYin Task Failed:" .. msg.retcode)
  local SGetMassExpTaskFailed = require("netio.protocol.mzm.gsp.massexp.SGetMassExpTaskFailed")
  if SGetMassExpTaskFailed.ERROR_ACTIVITY_NOT_OPEN == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[7])
  elseif SGetMassExpTaskFailed.ERROR_LEVEL_LIMIT == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[8])
  elseif SGetMassExpTaskFailed.ERROR_TASK_RECEIVED == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[9])
  else
    LingQiFengYinProtocols.OnCommonErr(msg.retcode)
  end
end
def.static("table").OnSFillGridSuccess = function(msg)
  activityInterface._lingqifengyinOpenIndex = msg.cur_index
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_InfoChange, nil)
end
def.static("table").OnSFillGridFailed = function(msg)
  local SFillGridFailed = require("netio.protocol.mzm.gsp.massexp.SFillGridFailed")
  if SFillGridFailed.ERROR_FILLED == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[10])
  elseif SFillGridFailed.ERROR_ORDER == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[11])
  elseif SFillGridFailed.ERROR_EXPIRED == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[12])
  elseif SFillGridFailed.ERROR_MONEY == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[18])
  else
    LingQiFengYinProtocols.OnCommonErr(msg.retcode)
  end
end
def.static("table").OnSGetAwardSuccess = function(msg)
  activityInterface._lingqifengyinStatus = msg.status
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_LingQiFengYin_End, {isTimeOver = false})
end
def.static("table").OnSGetAwardFailed = function(msg)
  local SGetAwardFailed = require("netio.protocol.mzm.gsp.massexp.SGetAwardFailed")
  if SGetAwardFailed.ERROR_NOT_JOIN_ACTIVITY == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[13])
  elseif SGetAwardFailed.ERROR_EXPIRED == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[12])
  else
    LingQiFengYinProtocols.OnCommonErr(msg.retcode)
  end
end
def.static("table").OnSTaskEndFailed = function(msg)
  local STaskEndFailed = require("netio.protocol.mzm.gsp.massexp.STaskEndFailed")
  if STaskEndFailed.ERROR_NOT_JOIN_ACTIVITY == msg.retcode then
    Toast(textRes.activity.LingQiFengYinText[13])
  else
    LingQiFengYinProtocols.OnCommonErr(msg.retcode)
  end
end
def.static("number").OnCommonErr = function(_retcode)
  local MassExpRet = require("netio.protocol.mzm.gsp.massexp.MassExpRet")
  if _retcode == MassExpRet.ERROR_SYSTEM then
    Toast(textRes.activity.LingQiFengYinText[14])
  elseif _retcode == MassExpRet.ERROR_STATUS then
    Toast(textRes.activity.LingQiFengYinText[15])
  elseif _retcode == MassExpRet.ERROR_CFG then
    Toast(textRes.activity.LingQiFengYinText[16])
  elseif _retcode == MassExpRet.ERROR_NOT_END then
    Toast(textRes.activity.LingQiFengYinText[17])
  end
end
LingQiFengYinProtocols.Commit()
return LingQiFengYinProtocols
