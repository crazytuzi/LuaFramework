local Lplus = require("Lplus")
local RankListUtils = Lplus.Class("RankListUtils")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local PetUtility = require("Main.Pet.PetUtility")
local def = RankListUtils.define
def.static("string", "=>", "number").GetRankListConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RANK_LIST_CONSTS, key)
  if record == nil then
    warn("GetRankListConsts(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("=>", "table").GetRankListClassCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RANK_LIST_CLASS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.name = record:GetStringValue("bigTypeName")
    cfg.subCfgIds = {}
    local subTypeStruct = record:GetStructValue("subTypeStruct")
    local size = subTypeStruct:GetVectorSize("subTypeVector")
    for i = 0, size - 1 do
      local vectorRow = subTypeStruct:GetVectorValueByIdx("subTypeVector", i)
      local rankListCfgId = vectorRow:GetIntValue("subTypeId")
      table.insert(cfg.subCfgIds, rankListCfgId)
      local subCfg = RankListUtils.GetRankListCfg(rankListCfgId)
      table.insert(cfg, subCfg)
    end
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetRankListCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RANK_LIST_CFG, id)
  if record == nil then
    warn("GetRankListCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.name = record:GetStringValue("typeName")
  cfg.type = record:GetIntValue("chartType")
  cfg.timeCfgId = record:GetIntValue("timeCfgId")
  cfg.tipId = record:GetIntValue("TIPS") or 0
  return cfg
end
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local OccupationCharMap = {
  [OccupationEnum.GUI_WANG_ZONG] = ChartType.GUI_WANG_MULTI_FIGHT_VALUE,
  [OccupationEnum.QIN_GYUN_MEN] = ChartType.QING_YUN_MULTI_FIGHT_VALUE,
  [OccupationEnum.TIAN_YIN_SI] = ChartType.TIAN_YIN_MULTI_FIGHT_VALUE,
  [OccupationEnum.FEN_XIANG_GU] = ChartType.FEN_XIANG_MULTI_FIGHT_VALUE,
  [OccupationEnum.HE_HUAN_PAI] = ChartType.HE_HUAN_MULTI_FIGHT_VALUE,
  [OccupationEnum.SHENG_WU_JIAO] = ChartType.SHENG_WU_MULTI_FIGHT_VALUE,
  [OccupationEnum.CANG_YU_GE] = ChartType.CANG_YU_MULTI_FIGHT_VALUE,
  [OccupationEnum.LING_YIN_DIAN] = ChartType.LING_YIN_MULTI_FIGHT_VALUE,
  [OccupationEnum.YI_NENG_ZHE] = ChartType.YINENG_FIGHT_VALUE,
  [OccupationEnum.WAN_DU_MEN] = ChartType.WANDUMEN_MULTI_FIGHT_VALUE,
  [OccupationEnum.DAN_QING_GE] = ChartType.DANQINGGE_MULTI_FIGHT_VALUE
}
def.static("number", "=>", "number").GetOccupationByChartType = function(chartType)
  for occupation, chart in pairs(OccupationCharMap) do
    if chart == chartType then
      return occupation
    end
  end
  return -1
end
def.static("number", "=>", "number").GetChartTypeByOccupation = function(occupation)
  local chartType = OccupationCharMap[occupation] or -1
  return chartType
end
local OccupWorldBossChartMap = {
  [OccupationEnum.GUI_WANG_ZONG] = ChartType.BIG_BOSS_GUIWANG,
  [OccupationEnum.QIN_GYUN_MEN] = ChartType.BIG_BOSS_QINGYUN,
  [OccupationEnum.TIAN_YIN_SI] = ChartType.BIG_BOSS_TIANYIN,
  [OccupationEnum.FEN_XIANG_GU] = ChartType.BIG_BOSS_FENXIANG,
  [OccupationEnum.HE_HUAN_PAI] = ChartType.BIG_BOSS_HEHUAN,
  [OccupationEnum.SHENG_WU_JIAO] = ChartType.BIG_BOSS_SHEGNWU,
  [OccupationEnum.CANG_YU_GE] = ChartType.BIG_BOSS_CANGYU,
  [OccupationEnum.LING_YIN_DIAN] = ChartType.BIG_BOSS_LINGYINDIAN,
  [OccupationEnum.YI_NENG_ZHE] = ChartType.BIG_BOSS_YINENG,
  [OccupationEnum.WAN_DU_MEN] = ChartType.BIG_BOSS_WANDUMEN,
  [OccupationEnum.DAN_QING_GE] = ChartType.BIG_BOSS_DANQINGGE
}
def.static("number", "=>", "number").GetOccupByWroldBossChartType = function(chartType)
  for occupation, chart in pairs(OccupWorldBossChartMap) do
    if chart == chartType then
      return occupation
    end
  end
  return -1
end
def.static("number", "=>", "number").GetWroldBossChartTypeByOccup = function(occupation)
  local chartType = OccupWorldBossChartMap[occupation] or -1
  return chartType
end
local ChartOccupWorldBossMap = {
  [ChartType.BIG_BOSS_REMOTE_GUIWANG] = OccupationEnum.GUI_WANG_ZONG,
  [ChartType.BIG_BOSS_REMOTE_QINGYUN] = OccupationEnum.QIN_GYUN_MEN,
  [ChartType.BIG_BOSS_REMOTE_TIANYIN] = OccupationEnum.TIAN_YIN_SI,
  [ChartType.BIG_BOSS_REMOTE_FENXIANG] = OccupationEnum.FEN_XIANG_GU,
  [ChartType.BIG_BOSS_REMOTE_HEHUAN] = OccupationEnum.HE_HUAN_PAI,
  [ChartType.BIG_BOSS_REMOTE_SHEGNWU] = OccupationEnum.SHENG_WU_JIAO,
  [ChartType.BIG_BOSS_REMOTE_CANGYU] = OccupationEnum.CANG_YU_GE,
  [ChartType.BIG_BOSS_REMOTE_LINGYIN] = OccupationEnum.LING_YIN_DIAN,
  [ChartType.BIG_BOSS_REMOTE_YINENG] = OccupationEnum.YI_NENG_ZHE,
  [ChartType.BIG_BOSS_REMOTE_WANDUMEN] = OccupationEnum.WAN_DU_MEN,
  [ChartType.BIG_BOSS_REMOTE_DANQINGGE] = OccupationEnum.DAN_QING_GE
}
def.static("number", "=>", "number").GetOccupByWroldBossRemoteChartType = function(chartType)
  local occupation = ChartOccupWorldBossMap[chartType] or -1
  return occupation
end
def.static("number", "=>", "number").GetWroldBossRemoteChartTypeByOccup = function(occupation)
  for chart, ocp in pairs(ChartOccupWorldBossMap) do
    if occupation == ocp then
      return chart
    end
  end
  return -1
end
return RankListUtils.Commit()
