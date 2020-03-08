local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local FuDaiData = Lplus.Class("FuDaiData")
local def = FuDaiData.define
local _instance
def.static("=>", FuDaiData).Instance = function()
  if _instance == nil then
    _instance = FuDaiData()
  end
  return _instance
end
def.field("number")._credit = 0
def.field("table")._exchangeCfgs = nil
def.field("table")._fudaiMap = nil
def.method().Reset = function(self)
  warn("[FuDaiData:_Reset] _Reset!")
  self:_SetCredit(0)
end
def.method("number").OnSyncCredit = function(self, credit)
  self:_SetCredit(credit)
end
def.method("number")._SetCredit = function(self, value)
  self._credit = value
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_FuYuan_Change, {
    credit = self._credit
  })
end
def.method("=>", "number").GetCredit = function(self)
  return self._credit
end
def.method("=>", "table")._GetFuDaiMap = function(self)
  if nil == self._fudaiMap then
    self:_LoadFuDaiCCfgs()
  end
  return self._fudaiMap
end
def.method()._LoadFuDaiCCfgs = function(self)
  self._fudaiMap = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUDAI_CLuckyBagCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local fudaiCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    fudaiCfg.id = DynamicRecord.GetIntValue(entry, "id")
    fudaiCfg.fuyuanAward = DynamicRecord.GetIntValue(entry, "score")
    fudaiCfg.costItemId = DynamicRecord.GetIntValue(entry, "itemCfgid")
    fudaiCfg.costItemNum = DynamicRecord.GetIntValue(entry, "itemNum")
    fudaiCfg.costItemNum10 = DynamicRecord.GetIntValue(entry, "itemNums")
    fudaiCfg.turntableAwardsId = DynamicRecord.GetIntValue(entry, "uiCfgid")
    fudaiCfg.mapItemHandlerType = DynamicRecord.GetIntValue(entry, "mapItemHandlerType")
    fudaiCfg.fixAwardId = DynamicRecord.GetIntValue(entry, "awardCfgid")
    fudaiCfg.fixAwardItemList = self:_GetAwards(fudaiCfg.fixAwardId)
    fudaiCfg.titleSpriteName = DynamicRecord.GetStringValue(entry, "titileSourse")
    fudaiCfg.closedBagTexId = DynamicRecord.GetIntValue(entry, "bagTypeSourse")
    fudaiCfg.openedBagTexId = DynamicRecord.GetIntValue(entry, "openBagSourse")
    fudaiCfg.topText = DynamicRecord.GetStringValue(entry, "upText")
    fudaiCfg.midText = DynamicRecord.GetStringValue(entry, "middleText")
    fudaiCfg.bottumText = DynamicRecord.GetStringValue(entry, "downText")
    fudaiCfg.tipId = DynamicRecord.GetIntValue(entry, "tipCfgid")
    fudaiCfg.awardSpriteName = DynamicRecord.GetStringValue(entry, "multipleAwardSourse")
    self._fudaiMap[fudaiCfg.id] = fudaiCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "table")._GetAwards = function(self, awardId)
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
  if itemList and itemList[1] then
    return itemList
  else
    return nil
  end
end
def.method("number", "=>", "table").GetFuDaiCfgByType = function(self, type)
  return self:_GetFuDaiMap()[type]
end
def.method("=>", "table").GetExchangeCfgs = function(self)
  if nil == self._exchangeCfgs then
    self:_LoadExchangeCfgs()
  end
  return self._exchangeCfgs
end
def.method()._LoadExchangeCfgs = function(self)
  self._exchangeCfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUDAI_CLuckyBagScoreCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local exchangeCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    exchangeCfg.id = DynamicRecord.GetIntValue(entry, "id")
    exchangeCfg.index = DynamicRecord.GetIntValue(entry, "index")
    exchangeCfg.scoreValue = DynamicRecord.GetIntValue(entry, "scoreValue")
    exchangeCfg.awardId = DynamicRecord.GetIntValue(entry, "awardId")
    exchangeCfg.itemList = self:_GetAwards(exchangeCfg.awardId)
    table.insert(self._exchangeCfgs, exchangeCfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self._exchangeCfgs, function(a, b)
    return a.index >= b.index
  end)
end
def.method("number", "=>", "table").GetExchangeItemByIndex = function(self, index)
  return self:GetExchangeCfgs()[index]
end
def.method("=>", "number").GetCreditIconId = function(self)
  return 90037
end
FuDaiData.Commit()
return FuDaiData
