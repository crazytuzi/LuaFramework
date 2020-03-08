local MODULE_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local ActivityRetrieveMgr = Lplus.Extend(AwardMgrBase, MODULE_NAME)
local Cls = ActivityRetrieveMgr
local def = Cls.define
local instance
local RetrieveData = require("Main.Award.ActivityRetrieve.ActivityRetrieveData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local const = constant.CActivityCompensateConsts
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitycompensate.SActivityCompensateNormalResult", Cls.OnNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitycompensate.SSyncActivityCompensates", Cls.OnSynActivityRetrieveInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitycompensate.SGetAwardRes", Cls.OnGetAwardsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitycompensate.SGetAllAwardRes", Cls.OnSEasyActivityRetrieve)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, Cls.OnServeLvChange)
end
def.static("table", "table").OnHeroLvUp = function(p, c)
  Cls.updateExpValue()
end
def.static("table", "table").OnServeLvChange = function(p, c)
  Cls.updateExpValue()
end
def.static().updateExpValue = function()
  local heroLv = require("Main.Hero.Interface").GetBasicHeroProp().level
  local srvLv = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
  local srvLvAwardCfg = require("Main.Server.ServerUtility").GetServerLevelAwardCfg(heroLv, srvLv)
  local fac = srvLvAwardCfg and (srvLvAwardCfg.roleExpMod and srvLvAwardCfg.roleExpMod or 1) or 1
  warn("fac ========>", fac)
  local retrieveData = Cls.GetData():GetRetrieveList()
  for i = 1, #retrieveData do
    local retrieveAct = retrieveData[i]
    retrieveAct.free_exp = math.floor(retrieveAct.free_exp * fac)
    retrieveAct.gold_exp = math.floor(retrieveAct.gold_exp * fac)
    retrieveAct.yuanbao_exp = math.floor(retrieveAct.yuanbao_exp * fac)
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_INFO_CHG, nil)
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  local retrieveData = Cls.GetData():GetRetrieveList()
  for i = 1, #retrieveData do
    if retrieveData[i].times > 0 then
      return true
    end
  end
  return false
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_ACTIVITY_COMPENSATE)
  return bOpen
end
def.override("=>", "boolean").IsOpen = function(self)
  return _G.GetHeroProp().level >= const.NeedLevel and Cls.IsFeatureOpen()
end
def.static("=>", "table").GetData = function()
  return RetrieveData.Instance()
end
def.static("table").OnSynActivityRetrieveInfo = function(p)
  Cls.GetData():SetRetrieveActList(p.compensates)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_INFO_CHG, nil)
end
def.static("number", "number", "number", "boolean").SendGetAwardReq = function(actId, retrieveType, iLeftTimes, bUseDblPt)
  local CGetAwardReq = require("netio.protocol.mzm.gsp.activitycompensate.CGetAwardReq")
  local p = CGetAwardReq.new(actId, retrieveType, iLeftTimes, bUseDblPt and CGetAwardReq.USE_DOUBLE_POINT_YES or CGetAwardReq.USE_DOUBLE_POINT_NO)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnGetAwardsSuccess = function(p)
  Cls.GetData():SetRetrieveActLeftTimes(p.activityid, p.left_times)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACTIVITY_RETRIEVE_SUCCESS, {
    actId = p.activityid
  })
  if p.left_times < 1 then
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
  end
end
def.static("table").OnNormalRes = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.activitycompensate.SActivityCompensateNormalResult")
  warn("Get Activity Retrieve error code: ", p.result)
  local txt = textRes.Award.ActivityRetrieve[1000 + p.result]
  if txt then
    Toast(txt)
  end
end
def.static("number", "boolean").SendEasyGetAllAwards = function(retrieveType, bUseDblPt)
  local CGetAllAwardReq = require("netio.protocol.mzm.gsp.activitycompensate.CGetAllAwardReq")
  local p = CGetAllAwardReq.new(retrieveType, bUseDblPt and CGetAllAwardReq.USE_DOUBLE_POINT_YES or CGetAllAwardReq.USE_DOUBLE_POINT_NO)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEasyActivityRetrieve = function(p)
  Cls.GetData():SetEasyRetrieve(p.get_type)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.EASY_RETRIEVE_SUCCESS, {
    getType = p.get_type
  })
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
return Cls.Commit()
