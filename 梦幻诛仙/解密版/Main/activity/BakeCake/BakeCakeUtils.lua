local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BakeCakeUtils = Lplus.Class(MODULE_NAME)
local def = BakeCakeUtils.define
def.static("=>", "table").GetAllBakeCakeActivityBriefCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAKECAKE_CCakeActivityCfg)
  if entries == nil then
    warn(string.format("GetAllFireworksShowCfgs return {}"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activityId")
    cfg.switchId = record:GetIntValue("switchId")
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetBakeCakeActivityCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAKECAKE_CCakeActivityCfg, activityId)
  if record == nil then
    warn(string.format("GetBakeCakeActivityCfg(%d) return nil", activityId))
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.switchId = record:GetIntValue("switchId")
  cfg.stateId = record:GetIntValue("stateId")
  cfg.cookTurn = record:GetIntValue("cookTurn")
  cfg.prepareTime = record:GetIntValue("prepareTime")
  cfg.cookPrepareTime = record:GetIntValue("cookPrepareTime")
  cfg.collectionCheckId = record:GetIntValue("collectionCheckId")
  cfg.collectMaterialItemId = record:GetIntValue("collectMaterialItemId")
  cfg.materialController = record:GetIntValue("materialController")
  cfg.triggerCountMax = record:GetIntValue("triggerCountMax")
  cfg.triggerCountMin = record:GetIntValue("triggerCountMin")
  cfg.triggerCountRet = record:GetIntValue("triggerCountRet")
  cfg.eachTurnCanGetMaxNum = record:GetIntValue("eachTurnCanGetMaxNum")
  cfg.cookTime = record:GetIntValue("cookTime")
  cfg.giftMaterialNum = record:GetIntValue("giftMaterialNum")
  cfg.giftMaterialItemId = record:GetIntValue("giftMaterialItemId")
  cfg.randomRangeTopLimit = record:GetIntValue("randomRangeTopLimit")
  cfg.randomRangeFloorLimit = record:GetIntValue("randomRangeFloorLimit")
  cfg.makeCakeTime = record:GetIntValue("makeCakeTime")
  cfg.selfCookCountMax = record:GetIntValue("selfCookCountMax")
  cfg.helpCookCountMax = record:GetIntValue("helpCookCountMax")
  cfg.cakeRangeMax = record:GetIntValue("cakeRangeMax")
  cfg.cakeRecordMax = record:GetIntValue("cakeRecordMax")
  cfg.activityTipId = record:GetIntValue("activityTipId")
  cfg.addCakeEffectId = record:GetIntValue("addCakeEffectId")
  cfg.barkingEffectId = record:GetIntValue("barkingEffectId")
  cfg.cakeRiseEffectId = record:GetIntValue("cakeRiseEffectId")
  cfg.cakeDropEffectId = record:GetIntValue("cakeDropEffectId")
  cfg.finishTipEffectId = record:GetIntValue("finishTipEffectId")
  return cfg
end
def.static("number", "=>", "table").GetCakeCfg = function(cakeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAKECAKE_CCakeContentCfg, cakeId)
  if record == nil then
    warn(string.format("GetCakeCfg(%d) return nil", cakeId))
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.cakeName = record:GetStringValue("cakeName")
  cfg.range = record:GetIntValue("range")
  return cfg
end
def.static("=>", "number").GetMaxCakeLevel = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAKECAKE_CCakeContentCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  return count
end
return BakeCakeUtils.Commit()
