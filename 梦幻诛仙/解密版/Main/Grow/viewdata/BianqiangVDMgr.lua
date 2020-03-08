local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BianqiangVDMgr = Lplus.Class(MODULE_NAME)
local GrowUtils = import("..GrowUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local StrongerLevelType = require("consts.mzm.gsp.grow.confbean.StrongerLevelType")
local def = BianqiangVDMgr.define
local instance
def.static("=>", BianqiangVDMgr).Instance = function()
  if instance == nil then
    instance = BianqiangVDMgr()
  end
  return instance
end
def.method("=>", "table").GetBianqiangPanelViewData = function(self)
  local viewData = {}
  local cfgs = GrowUtils.GetAllBianqiangCfgs()
  local classifyMap = {}
  for k, cfg in pairs(cfgs) do
    classifyMap[cfg.bqType] = classifyMap[cfg.bqType] or {}
    table.insert(classifyMap[cfg.bqType], cfg)
  end
  local classifyList = {}
  for k, v in pairs(classifyMap) do
    local bqTypeCfg = GrowUtils.GetBianqiangTypeCfg(k)
    local tabData = {}
    tabData.bqType = bqTypeCfg.bqType
    tabData.rank = bqTypeCfg.rank
    tabData.name = bqTypeCfg.name
    table.insert(classifyList, tabData)
  end
  table.sort(classifyList, function(left, right)
    return left.rank < right.rank
  end)
  for i, tabData in ipairs(classifyList) do
    tabData.datas = {}
    local list = classifyMap[tabData.bqType]
    for i, v in ipairs(list) do
      if v.operateLevelType == StrongerLevelType.TOP_TYPE then
        local data = self:_BianqiangCfgToViewData(cfgs, v)
        table.insert(tabData.datas, data)
      end
    end
    table.sort(tabData.datas, function(left, right)
      return left.rank < right.rank
    end)
    viewData[i] = tabData
  end
  return viewData
end
def.method("table", "table", "=>", "table")._BianqiangCfgToViewData = function(self, cfgs, v)
  local data = {}
  data.name = v.title
  data.desc = v.desc
  data.icon = v.icon
  data.level = v.level
  data.operateId = v.operateId
  data.rank = v.rank
  data.star = v.star
  data.progressType = v.progressType
  if v.operateLevelType == StrongerLevelType.TOP_TYPE and #v.subIdList > 0 then
    data.child = {}
    for j, subId in ipairs(v.subIdList) do
      local v = cfgs[subId]
      local childData = self:_BianqiangCfgToViewData(cfgs, v)
      data.child[j] = childData
    end
    table.sort(data.child, function(left, right)
      return left.rank < right.rank
    end)
  end
  return data
end
def.method("number", "=>", "string", "string").GetProgressColorAndDesc = function(self, rate)
  local allProgressCfg = GrowUtils.GetBianQiangProgressCfg()
  if nil == allProgressCfg then
    return textRes.Grow[51], textRes.Grow[50]
  end
  for k, progressInfo in pairs(allProgressCfg) do
    local lowRate = progressInfo.lowerRate
    local upRate = progressInfo.upRate
    if rate >= lowRate and rate <= upRate then
      return progressInfo.spriteName, progressInfo.stateDesc
    end
  end
  return textRes.Grow[53], textRes.Grow[52]
end
def.method("number", "=>", "number").GetBianQiangScoreCfg = function(self, progressType)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local value = GrowUtils.GetGrowScoreCfg(progressType, heroLevel)
  return value
end
def.method("table", "=>", "table").FilterCfgDataByLevel = function(self, originData)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local resData = {}
  for k, v in pairs(originData) do
    local needLevel = v.level
    if heroLevel >= needLevel then
      local cfg = {}
      cfg.name = v.name
      cfg.desc = v.desc
      cfg.icon = v.icon
      cfg.level = v.level
      cfg.operateId = v.operateId
      cfg.rank = v.rank
      cfg.star = v.star
      cfg.progressType = v.progressType
      table.insert(resData, cfg)
    end
  end
  table.sort(resData, function(a, b)
    return a.rank < b.rank
  end)
  return resData
end
local ProgressTypeEnum = require("consts.mzm.gsp.grow.confbean.ProgressType")
local ValueFunctionMap = {
  [ProgressTypeEnum.MENGPAISKILL] = GrowUtils.CalcMenPaiValue,
  [ProgressTypeEnum.XIANLVFIHGT] = GrowUtils.CalcXianLvValue,
  [ProgressTypeEnum.EQUIPMENT] = GrowUtils.CalcEquipValue,
  [ProgressTypeEnum.QILINGLEVEL] = GrowUtils.CalcQiLingValue,
  [ProgressTypeEnum.XIULIANLEVEL] = GrowUtils.CalcXiuLianValue,
  [ProgressTypeEnum.PETSCORE] = GrowUtils.CalcPetValue,
  [ProgressTypeEnum.WINGSCORE] = GrowUtils.CalcWingValue,
  [ProgressTypeEnum.FABAOSCORE] = GrowUtils.CalcFaBaoValue
}
def.method("number", "=>", "number").CalcValueByProgressType = function(self, progressType)
  local resValue = 0
  local curValue = 0
  local calcFunction = ValueFunctionMap[progressType]
  if calcFunction then
    curValue = calcFunction()
    local baseValue = self:GetBianQiangScoreCfg(progressType)
    resValue = curValue / baseValue * 10000
  end
  return resValue
end
return BianqiangVDMgr.Commit()
