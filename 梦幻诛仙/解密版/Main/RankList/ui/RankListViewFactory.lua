local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListViewFactory = Lplus.Class(CUR_CLASS_NAME)
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local def = RankListViewFactory.define
local instance
def.static("=>", RankListViewFactory).Instance = function()
  if instance == nil then
    instance = RankListViewFactory()
  end
  return instance
end
def.method("number", "=>", RankListData).CreateRankListView = function(self, chartType)
  local RankListViewClass
  if chartType == ChartType.XXX then
    RankListViewClass = import(".data.PKRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_KEJU then
    RankListViewClass = import(".data.KeJuRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_JINGJI then
    RankListViewClass = import(".data.ArenaRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_LEVEL then
    RankListViewClass = import(".data.RoleLevel", CUR_CLASS_NAME)
  elseif chartType == ChartType.PET_YAOLI then
    RankListViewClass = import(".data.PetYaoLi", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_FIGHT_VALUE then
    RankListViewClass = import(".data.RoleFightValue", CUR_CLASS_NAME)
  elseif chartType == ChartType.EXPERIENCE_MASTER then
    RankListViewClass = import(".data.ExperienceMasterListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.QMHW then
    RankListViewClass = import(".data.QimaiRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.GUI_WANG_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.QING_YUN_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.TIAN_YIN_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.FEN_XIANG_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.HE_HUAN_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.SHENG_WU_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.WAN_DU_MULTI_FIGHT_VALUE then
    RankListViewClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  else
    RankListViewClass = import(".data.CommonRankListData", CUR_CLASS_NAME)
  end
  return RankListViewClass.New(chartType)
end
return RankListViewFactory.Commit()
