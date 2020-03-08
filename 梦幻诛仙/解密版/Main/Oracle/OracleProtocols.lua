local Lplus = require("Lplus")
local OracleData = require("Main.Oracle.data.OracleData")
local GeniusRet = require("netio.protocol.mzm.gsp.genius.GeniusRet")
local OracleProtocols = Lplus.Class("OracleProtocols")
local def = OracleProtocols.define
def.static().RegisterEvents = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SGetGeninusSeriesSuccess", OracleProtocols.OnSGetGeninusSeriesSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SSavePlanSuccess", OracleProtocols.OnSSavePlanSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SSavePlanFailed", OracleProtocols.OnSSavePlanFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SResetPlanSuccess", OracleProtocols.OnSResetPlanSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SResetPlanFailed", OracleProtocols.OnSResetPlanFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SSwitchPlanSuccess", OracleProtocols.OnSSwitchPlanSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SSwitchPlanFailed", OracleProtocols.OnSSwitchPlanFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", OracleProtocols.OnSCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.genius.SSyncExtraPoint", OracleProtocols.OnSSyncExtraPoint)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseGeniusStoneItemSuccess", OracleProtocols.OnSUseGeniusStoneItemSuccess)
end
def.static("table").OnSGetGeninusSeriesSuccess = function(p)
  warn("[OracleProtocols:OnSGetGeninusSeriesSuccess] OnSGetGeninusSeriesSuccess! p.cur_series:", p.cur_series)
  OracleData.Instance():SetAllAllocations(p.cur_series, p.series)
end
def.static("table").OnSSavePlanSuccess = function(p)
  warn("[OracleProtocols:OnSSavePlanSuccess] OnSSavePlanSuccess! p.genius_series_id:", p.genius_series_id)
  OracleData.Instance():SetAllocation(p.genius_series_id, p.genius_skills)
  Toast(textRes.Oracle.SAVE_ORACLE_ALLOCATION_SUCCESS)
end
def.static("table").OnSSavePlanFailed = function(p)
  warn("[OracleProtocols:OnSSavePlanFailed] OnSSavePlanFailed! p.retcode:", p.retcode)
  local SSavePlanFailed = require("netio.protocol.mzm.gsp.genius.SSavePlanFailed")
  if p.retcode == SSavePlanFailed.ERROR_POINT_NOT_ENOUGH then
    Toast(textRes.Oracle.ERROR_POINT_NOT_ENOUGH)
  end
  OracleProtocols.OFailed(p.retcode)
end
def.static("table").OnSResetPlanSuccess = function(p)
  warn("[OracleProtocols:OnSResetPlanSuccess] OnSResetPlanSuccess! p.genius_series_id:", p.genius_series_id)
  OracleData.Instance():SetAllocation(p.genius_series_id, nil)
  Toast(textRes.Oracle.RESET_ORACLE_ALLOCATION_SUCCESS)
end
def.static("table").OnSResetPlanFailed = function(p)
  warn("[OracleProtocols:OnSResetPlanFailed] OnSResetPlanFailed! p.retcode:", p.retcode)
  local SResetPlanFailed = require("netio.protocol.mzm.gsp.genius.SResetPlanFailed")
  if p.retcode == SResetPlanFailed.ERROR_GOLD_NOT_ENOUGH then
    Toast(textRes.Oracle.ERROR_GOLD_NOT_ENOUGH)
  end
  OracleProtocols.OFailed(p.retcode)
end
def.static("table").OnSSwitchPlanSuccess = function(p)
  warn("[OracleProtocols:OnSSwitchPlanSuccess] OnSSwitchPlanSuccess! p.genius_series_id:", p.genius_series_id)
  OracleData.Instance():SetCurrentOracleId(p.genius_series_id)
  Toast(textRes.Oracle.SWITCH_ORACLE_ALLOCATION_SUCCESS)
end
def.static("table").OnSSwitchPlanFailed = function(p)
  warn("[OracleProtocols:OnSSwitchPlanFailed] OnSSwitchPlanFailed! p.retcode:", p.retcode)
  local SSwitchPlanFailed = require("netio.protocol.mzm.gsp.genius.SSwitchPlanFailed")
  if p.retcode == SSwitchPlanFailed.ERROR_GOLD_NOT_ENOUGH then
    Toast(textRes.Oracle.ERROR_GOLD_NOT_ENOUGH)
  end
  OracleProtocols.OFailed(p.retcode)
end
def.static("number").OFailed = function(retcode)
  local errString
  if retcode == GeniusRet.ERROR_SYSTEM then
    errString = textRes.Oracle.ERROR_SYSTEM
  elseif retcode == GeniusRet.ERROR_USERID then
    errString = textRes.Oracle.ERROR_USERID
  elseif retcode == GeniusRet.ERROR_CFG then
    errString = textRes.Oracle.ERROR_CFG
  elseif retcode == GeniusRet.ERROR_LEVEL then
    errString = textRes.Oracle.ERROR_LEVEL
  elseif retcode == GeniusRet.ERROR_GENIUS_EMPTY then
    errString = textRes.Oracle.ERROR_GENIUS_EMPTY
  elseif retcode == GeniusRet.ERROR_SWITCH_GENIUS_SERIES then
    errString = textRes.Oracle.ERROR_SWITCH_GENIUS_SERIES
  elseif retcode == GeniusRet.ERROR_GENIU_PLAN_PARAM_INVALID then
    errString = textRes.Oracle.ERROR_GENIU_PLAN_PARAM_INVALID
  elseif retcode == GeniusRet.ERROR_GENIU_POINT_OVER_FLOW then
    errString = textRes.Oracle.ERROR_GENIU_POINT_OVER_FLOW
  elseif retcode == GeniusRet.ERROR_PREVIOUS_GENIUS_POINT_NOT_ENOUGH then
    errString = textRes.Oracle.ERROR_PREVIOUS_GENIUS_POINT_NOT_ENOUGH
  elseif retcode == GeniusRet.ERROR_PREVIOUS_POINT_NOT_ENOUGH then
    errString = textRes.Oracle.ERROR_PREVIOUS_POINT_NOT_ENOUGH
  elseif retcode == GeniusRet.ERROR_GENIUS_IGNORE then
    errString = textRes.Oracle.ERROR_GENIUS_IGNORE
  end
  if errString then
    warn("[OracleProtocols:OFailed] err:", errString)
    Toast(errString)
  end
end
def.static("table").OnSCommonErrorInfo = function(p)
  warn("[OracleProtocols:OnSCommonErrorInfo] On SCommonErrorInfo! p.retcode:", p.retcode)
  local errString
  local SCommonErrorInfo = require("netio.protocol.mzm.gsp.item.SCommonErrorInfo")
  if p.errorCode == SCommonErrorInfo.GENIUS_STONE_ITEM_USE_LEVEL_LIMIT then
    errString = textRes.Oracle.GENIUS_STONE_ITEM_USE_LEVEL_LIMIT
  elseif p.errorCode == SCommonErrorInfo.GENIUS_FUN_LEVEL_LIMIT then
    errString = textRes.Oracle.GENIUS_FUN_LEVEL_LIMIT
  elseif p.errorCode == SCommonErrorInfo.GENIUS_STONE_ITEM_USE_MAX then
    errString = textRes.Oracle.GENIUS_STONE_ITEM_USE_MAX
  end
  if errString then
    warn("[OracleProtocols:OnSCommonErrorInfo] err:", errString)
    Toast(errString)
  end
end
def.static("table").OnSSyncExtraPoint = function(p)
  warn("[OracleProtocols:OnSSyncExtraPoint] On SSyncExtraPoint! p.extra_point:", p.extra_point)
  OracleData.Instance():OnSyncExtraPoint(p.extra_point)
  Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.SYNC_EXTRA_POINT, nil)
end
def.static("table").OnSUseGeniusStoneItemSuccess = function(p)
  warn("[OracleProtocols:OnSUseGeniusStoneItemSuccess] On SUseGeniusStoneItemSuccess! p. item_cfgid & p.used_num:", p.item_cfgid, p.used_num)
  local addpoints = OracleData.Instance():GetItemAddPoints(p.item_cfgid) * p.used_num
  if addpoints > 0 then
    warn("[OracleProtocols:OnSUseGeniusStoneItemSuccess] add points:", addpoints)
    Toast(string.format(textRes.Oracle.ADD_ORACLE_POINTS, addpoints))
  else
    warn("[OracleProtocols:OnSUseGeniusStoneItemSuccess] add ZERO points!")
  end
end
def.static("=>", "boolean").SendCGetGeninusSeries = function()
  warn("[OracleProtocols:SendCGetGeninusSeries] Send CGetGeninusSeries!")
  local p = require("netio.protocol.mzm.gsp.genius.CGetGeninusSeries").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.static("number", "table", "=>", "boolean").SendCSavePlan = function(oracleId, oracleAllocation)
  warn("[OracleProtocols:SendCSavePlan] Send CSavePlan, oracleId=", oracleId)
  local p = require("netio.protocol.mzm.gsp.genius.CSavePlan").new(oracleId, oracleAllocation)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("number", "=>", "boolean").SendCResetPlan = function(oracleId)
  warn("[OracleProtocols:SendCResetPlan] Send CResetPlan, oracleId=", oracleId)
  local p = require("netio.protocol.mzm.gsp.genius.CResetPlan").new(oracleId)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("number", "=>", "boolean").SendCSwitchPlan = function(oracleId)
  warn("[OracleProtocols:SendCSwitchPlan] Send CSwitchPlan, oracleId=", oracleId)
  local p = require("netio.protocol.mzm.gsp.genius.CSwitchPlan").new(oracleId)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("userdata", "number", "=>", "boolean").SendCUseGeniusStoneItem = function(uuid, bUseAll)
  warn(string.format("[OracleProtocols:SendCUseGeniusStoneItem] Send CUseGeniusStoneItem, bUseAll=[%d]", bUseAll))
  local p = require("netio.protocol.mzm.gsp.item.CUseGeniusStoneItem").new(uuid, bUseAll)
  gmodule.network.sendProtocol(p)
  return true
end
OracleProtocols.Commit()
return OracleProtocols
