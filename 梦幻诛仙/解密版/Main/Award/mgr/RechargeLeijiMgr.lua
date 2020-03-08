local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local RechargeLeijiMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local FirstRechargeMgr = require("Main.Award.mgr.FirstRechargeMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local ItemModule = require("Main.Item.ItemModule")
local def = RechargeLeijiMgr.define
def.const("number").ActivityId = constant.CQingfuCfgConsts.RECHARGE_TIMES_ACTIVITY_CFG_ID
def.const("string").RechargeLeijiKey = "AWARD_RECHARGE_LEIJI_TOUCH"
def.field("table")._rechargeCfg = nil
def.field("table")._rechargeProgress = nil
local instance
def.static("=>", RechargeLeijiMgr).Instance = function()
  if instance == nil then
    instance = RechargeLeijiMgr()
    instance._rechargeProgress = {}
  end
  return instance
end
def.method().Init = function(self)
  self:LoadCfgData()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncSaveAmtActivityInfo", RechargeLeijiMgr.OnSSyncSaveAmtActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardSuccess", RechargeLeijiMgr.OnSGetSaveAmtActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed", RechargeLeijiMgr.OnSGetSaveAmtActivityAwardFailed)
end
def.method().LoadCfgData = function(self)
  self._rechargeCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SAVE_AMT_CFG)
  if entries == nil then
    return
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, recordCount - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record:GetIntValue("activity_cfg_id") == RechargeLeijiMgr.ActivityId then
      local r = {}
      r.award_id = record:GetIntValue("award_cfg_id")
      r.name = record:GetStringValue("name")
      r.desc = record:GetStringValue("desc")
      r.saveAmt = record:GetIntValue("save_amt_cond")
      r.sortid = record:GetIntValue("sort_id")
      self._rechargeCfg[r.sortid] = r
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsOpen() and self:HasNextRechargeAward() and (self:CanGetAward() or not self:HasKnowThisAward()) then
    return 1
  end
  return 0
end
def.method("=>", "boolean").CanGetAward = function(self)
  local recharge = self:GetNextRechargeCfg()
  local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring()) - tonumber(self:GetBaseSaveAmt():tostring())
  local needYuanBao = recharge.saveAmt - totalRecharge
  return needYuanBao <= 0
end
def.method("=>", "boolean").HasKnowThisAward = function(self)
  local key = RechargeLeijiMgr.RechargeLeijiKey
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return false
  end
  return true
end
def.method().MarkAsKnowAboutThisAward = function(self)
  local key = RechargeLeijiMgr.RechargeLeijiKey
  if not LuaPlayerPrefs.HasRoleKey(key) then
    local val = 1
    LuaPlayerPrefs.SetRoleInt(key, val)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, nil)
  end
end
def.method("table").SetRechargeStatus = function(self, p)
  local amtActivityInfo = p.activity_infos[RechargeLeijiMgr.ActivityId]
  if amtActivityInfo ~= nil then
    self._rechargeProgress.baseSaveAmt = amtActivityInfo.base_save_amt
    self._rechargeProgress.awardIdx = amtActivityInfo.sortid
  end
end
def.method("number").SetRechargeProgress = function(self, sortid)
  self._rechargeProgress.awardIdx = sortid
end
def.override("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QING_FU_RECHARGE_TIMES) then
    return false
  end
  if not FirstRechargeMgr.Instance():HasDrawAward() then
    return false
  else
    return self:HasNextRechargeAward()
  end
end
def.method("=>", "number").GetNexAwardSortId = function(self)
  if self._rechargeProgress.awardIdx <= 0 then
    return 1
  else
    return self._rechargeProgress.awardIdx + 1
  end
end
def.method("=>", "table").GetNextRechargeCfg = function(self)
  local nextAwardIdx = self:GetNexAwardSortId()
  return self._rechargeCfg[nextAwardIdx]
end
def.method("=>", "boolean").HasNextRechargeAward = function(self)
  return self:GetNextRechargeCfg() ~= nil
end
def.method("=>", "userdata").GetBaseSaveAmt = function(self)
  return self._rechargeProgress.baseSaveAmt
end
def.method("=>", "number").GetAwardID = function(self)
  local nextAwardIdx = self:GetNexAwardSortId()
  return self._rechargeCfg[nextAwardIdx].award_id
end
def.method("=>", "table").GetAwardItems = function(self)
  local awardId = self:GetAwardID()
  local ItemUtils = require("Main.Item.ItemUtils")
  local cfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  local items = {}
  if cfg then
    items = cfg.itemList
  end
  return items
end
def.method("number").ShowErrorTips = function(self, retCode)
  if textRes.Award.SGetSaveAmtActivityAwardFailed[retCode] ~= nil then
    Toast(textRes.Award.SGetSaveAmtActivityAwardFailed[retCode])
  end
end
def.static("table").OnSSyncSaveAmtActivityInfo = function(p)
  instance:SetRechargeStatus(p)
end
def.method().GetRechargeLeijiAward = function(self)
  local itemMap = {}
  for k, v in pairs(self:GetAwardItems()) do
    itemMap[v.itemId] = (itemMap[v.itemId] or 0) + v.num
  end
  local full = ItemModule.Instance():IsEnoughForItems(itemMap)
  if full > 0 then
    Toast(string.format(textRes.Award[72], textRes.Item[full] or textRes.Item[ItemModule.BAG]))
  else
    local p = require("netio.protocol.mzm.gsp.qingfu.CGetSaveAmtActivityAward").new(RechargeLeijiMgr.ActivityId, self:GetNexAwardSortId())
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").OnSGetSaveAmtActivityAwardSuccess = function(p)
  if p.activity_id == RechargeLeijiMgr.ActivityId then
    instance:SetRechargeProgress(p.sort_id)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnSGetSaveAmtActivityAwardFailed = function(p)
  if p.activity_id == RechargeLeijiMgr.ActivityId then
    instance:SetRechargeProgress(p.sortid)
    instance:ShowErrorTips(p.retcode)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, nil)
  end
end
return RechargeLeijiMgr.Commit()
