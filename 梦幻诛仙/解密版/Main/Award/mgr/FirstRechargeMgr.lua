local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local FirstRechargeMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local RechargeStatus = require("netio.protocol.mzm.gsp.qingfu.SSyncFirstRechargeInfo")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = FirstRechargeMgr.define
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.const("string").FirstTouchKey = "AWARD_FIRST_RECHARGE_AWARD_TOUCH"
local STATUS_NOT_SET = -1
def.field("number").m_status = STATUS_NOT_SET
local instance
def.static("=>", FirstRechargeMgr).Instance = function()
  if instance == nil then
    instance = FirstRechargeMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncFirstRechargeInfo", FirstRechargeMgr.OnSSyncFirstRechargeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetFirstRechargeAwardResp", FirstRechargeMgr.OnSGetFirstRechargeAwardResp)
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if not self:HasDrawAward() and (self:HasRecharge() or not self:HasKnowThisAward()) then
    return 1
  end
  return 0
end
def.method("number").SetRechargeStatus = function(self, status)
  self.m_status = status
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, {
    self.m_status
  })
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
end
def.method("=>", "boolean").HasKnowThisAward = function(self)
  local key = FirstRechargeMgr.FirstTouchKey
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return false
  end
  return true
end
def.method().MarkAsKnowAboutThisAward = function(self)
  local key = FirstRechargeMgr.FirstTouchKey
  if not LuaPlayerPrefs.HasRoleKey(key) then
    local val = 1
    LuaPlayerPrefs.SetRoleInt(key, val)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, {
      self.m_status
    })
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.method("=>", "number").GetAwardID = function(self)
  return _G.constant.CQingfuCfgConsts.FIRST_RECHARGE_AWARD_ID
end
def.method("=>", "table").GetAwardItems = function(self)
  local awardId = self:GetAwardID()
  local myProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local school = myProp.occupation
  local gender = myProp.gender
  local key = string.format("%d_%d_%d", awardId, school, gender)
  local ItemUtils = require("Main.Item.ItemUtils")
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local items = {}
  if cfg then
    items = cfg.itemList
  else
    local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
    local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
    local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
    local cfg = ItemUtils.GetGiftAwardCfg(key)
    items = cfg and cfg.itemList or items
  end
  return items
end
def.method("=>", "boolean").HasRecharge = function(self)
  return self.m_status >= RechargeStatus.AWARD
end
def.method("=>", "boolean").HasDrawAward = function(self)
  return self.m_status == RechargeStatus.FINISH
end
def.method().DrawAward = function(self)
  self:C2S_GetFirstRechargeAward()
end
def.method().C2S_GetFirstRechargeAward = function(self)
  local p = require("netio.protocol.mzm.gsp.qingfu.CGetFirstRechargeAward").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSyncFirstRechargeInfo = function(p)
  instance:SetRechargeStatus(p.status)
end
def.static("table").OnSGetFirstRechargeAwardResp = function(p)
  if p.retcode == p.class.SUCCESS then
    instance:SetRechargeStatus(RechargeStatus.FINISH)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.GET_FIRST_RECHARGE_AWARD_SUCCESS, nil)
  else
    local text = textRes.Award.SGetFirstRechargeAwardResp[p.retcode]
    if text then
      Toast(text)
    end
  end
end
return FirstRechargeMgr.Commit()
