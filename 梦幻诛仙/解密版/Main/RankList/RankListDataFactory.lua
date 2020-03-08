local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListDataFactory = Lplus.Class(CUR_CLASS_NAME)
local RankListData = import(".data.RankListData")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local def = RankListDataFactory.define
local instance
def.static("=>", RankListDataFactory).Instance = function()
  if instance == nil then
    instance = RankListDataFactory()
  end
  return instance
end
def.const("table").TYPE2CLASS = {
  [ChartType.PARASELENE] = import(".data.HuanYueDongFuData", CUR_CLASS_NAME),
  [ChartType.JIU_XIAO_FIGHT_WIN] = import(".data.JueZhanJiuXiaoData", CUR_CLASS_NAME),
  [ChartType.ROLE_ARENA] = import(".data.PVP3RankListData", CUR_CLASS_NAME),
  [ChartType.ROLE_KEJU] = import(".data.KeJuRankListData", CUR_CLASS_NAME),
  [ChartType.ROLE_JINGJI] = import(".data.ArenaRankListData", CUR_CLASS_NAME),
  [ChartType.ROLE_LEVEL] = import(".data.RoleLevel", CUR_CLASS_NAME),
  [ChartType.PET_YAOLI] = import(".data.PetYaoLi", CUR_CLASS_NAME),
  [ChartType.ROLE_FIGHT_VALUE] = import(".data.RoleFightValue", CUR_CLASS_NAME),
  [ChartType.GIVE_FLOWER] = import(".data.GiveFlowerRankListData", CUR_CLASS_NAME),
  [ChartType.RECEIVE_FLOWER] = import(".data.ReceiveFlowerRankListData", CUR_CLASS_NAME),
  [ChartType.EXPERIENCE_MASTER] = import(".data.ExperienceMasterListData", CUR_CLASS_NAME),
  [ChartType.QMHW] = import(".data.QimaiRankListData", CUR_CLASS_NAME),
  [ChartType.ROLE_MULTI_FIGHT_VALUE] = import(".data.ComprehensivePower", CUR_CLASS_NAME),
  [ChartType.JIU_XIAO_MASTER_RANK] = import(".data.EliteJueZhanJiuXiaoData", CUR_CLASS_NAME),
  [ChartType.GUI_WANG_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.QING_YUN_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.TIAN_YIN_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.FEN_XIANG_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.HE_HUAN_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.SHENG_WU_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.CANG_YU_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.LING_YIN_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.YINENG_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.WANDUMEN_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.DANQINGGE_MULTI_FIGHT_VALUE] = import(".data.OccupationFightListData", CUR_CLASS_NAME),
  [ChartType.HOMELAND] = import(".data.HomelandScoreData", CUR_CLASS_NAME),
  [ChartType.LADDER_LOCAL_60_TO_99] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.LADDER_REMOTE_60_TO_99] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.LADDER_LOCAL_100_TO_119] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.LADDER_REMOTE_100_TO_119] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.LADDER_LOCAL_120_TO_MAX] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.LADDER_REMOTE_120_TO_MAX] = import(".data.CrossServerRankData", CUR_CLASS_NAME),
  [ChartType.HULA] = import(".data.HulaRankListData", CUR_CLASS_NAME),
  [ChartType.MENPAI_STAR] = import(".data.MenpaiStarListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_GUIWANG] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_QINGYUN] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_TIANYIN] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_FENXIANG] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_HEHUAN] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_SHEGNWU] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_CANGYU] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_LINGYINDIAN] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_YINENG] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_WANDUMEN] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_DANQINGGE] = import(".data.BigBossRankListData", CUR_CLASS_NAME),
  [ChartType.CHILDREN_RATING] = import(".data.ChildrenRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_GUIWANG] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_QINGYUN] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_TIANYIN] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_FENXIANG] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_HEHUAN] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_SHEGNWU] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_CANGYU] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_LINGYIN] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_YINENG] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_WANDUMEN] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.BIG_BOSS_REMOTE_DANQINGGE] = import(".data.BigBossRemoteRankListData", CUR_CLASS_NAME),
  [ChartType.SINGLE_CROSS_FIELD_LOCAL] = import(".data.CrossBattlefieldRankData", CUR_CLASS_NAME),
  [ChartType.SINGLE_CROSS_FIELD_ROMOTE] = import(".data.CrossBattlefieldRankData", CUR_CLASS_NAME),
  [ChartType.CROSS_BATTLE_BET_WIN_REMOTE] = import(".data.CrossBattleBetRankListData", CUR_CLASS_NAME),
  [ChartType.CROSS_BATTLE_BET_LOSE_REMOTE] = import(".data.CrossBattleBetRankListData", CUR_CLASS_NAME),
  [ChartType.FRIENDS_CIRCLE_POPULARITY] = import(".data.SocialSpacePopular", CUR_CLASS_NAME),
  [ChartType.PET_ARENA_RANK] = import(".data.PetsArenaRankListData", CUR_CLASS_NAME)
}
def.method("number", "=>", RankListData).CreateRankListData = function(self, chartType)
  local RankListClass = RankListDataFactory.TYPE2CLASS[chartType] or import(".data.CommonRankListData", CUR_CLASS_NAME)
  return RankListClass.New(chartType)
end
def.method("number", "=>", RankListData).CreateRankListDataOld = function(self, chartType)
  local RankListClass
  if chartType == ChartType.PARASELENE then
    RankListClass = import(".data.HuanYueDongFuData", CUR_CLASS_NAME)
  elseif chartType == ChartType.JIU_XIAO_FIGHT_WIN then
    RankListClass = import(".data.JueZhanJiuXiaoData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_ARENA then
    RankListClass = import(".data.PVP3RankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_KEJU then
    RankListClass = import(".data.KeJuRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_JINGJI then
    RankListClass = import(".data.ArenaRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_LEVEL then
    RankListClass = import(".data.RoleLevel", CUR_CLASS_NAME)
  elseif chartType == ChartType.PET_YAOLI then
    RankListClass = import(".data.PetYaoLi", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_FIGHT_VALUE then
    RankListClass = import(".data.RoleFightValue", CUR_CLASS_NAME)
  elseif chartType == ChartType.GIVE_FLOWER then
    RankListClass = import(".data.GiveFlowerRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.RECEIVE_FLOWER then
    RankListClass = import(".data.ReceiveFlowerRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.EXPERIENCE_MASTER then
    RankListClass = import(".data.ExperienceMasterListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.QMHW then
    RankListClass = import(".data.QimaiRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.ROLE_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.ComprehensivePower", CUR_CLASS_NAME)
  elseif chartType == ChartType.JIU_XIAO_MASTER_RANK then
    RankListClass = import(".data.EliteJueZhanJiuXiaoData", CUR_CLASS_NAME)
  elseif chartType == ChartType.GUI_WANG_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.QING_YUN_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.TIAN_YIN_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.FEN_XIANG_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.HE_HUAN_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.SHENG_WU_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.CANG_YU_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.LING_YIN_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.YINENG_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.WAN_DU_MULTI_FIGHT_VALUE then
    RankListClass = import(".data.OccupationFightListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.HOMELAND then
    RankListClass = import(".data.HomelandScoreData", CUR_CLASS_NAME)
  elseif chartType == ChartType.LADDER_LOCAL_60_TO_99 or chartType == ChartType.LADDER_REMOTE_60_TO_99 or chartType == ChartType.LADDER_LOCAL_100_TO_119 or chartType == ChartType.LADDER_REMOTE_100_TO_119 or chartType == ChartType.LADDER_LOCAL_120_TO_MAX or chartType == ChartType.LADDER_REMOTE_120_TO_MAX then
    RankListClass = import(".data.CrossServerRankData", CUR_CLASS_NAME)
  elseif chartType == ChartType.HULA then
    RankListClass = import(".data.HulaRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.MENPAI_STAR then
    RankListClass = import(".data.MenpaiStarListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_GUIWANG then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_QINGYUN then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_TIANYIN then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_FENXIANG then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_HEHUAN then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_SHEGNWU then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_CANGYU then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_LINGYINDIAN then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.CHILDREN_RATING then
    RankListClass = import(".data.ChildrenRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.SINGLE_CROSS_FIELD_LOCAL or chartType == ChartType.SINGLE_CROSS_FIELD_ROMOTE then
    RankListClass = import(".data.CrossBattlefieldRankData", CUR_CLASS_NAME)
  elseif chartType == ChartType.CROSS_BATTLE_BET_WIN_REMOTE or chartType == ChartType.CROSS_BATTLE_BET_LOSE_REMOTE then
    RankListClass = import(".data.CrossBattleBetRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.FRIENDS_CIRCLE_POPULARITY then
    RankListClass = import(".data.SocialSpacePopular", CUR_CLASS_NAME)
  elseif chartType == ChartType.BIG_BOSS_YINENG then
    RankListClass = import(".data.BigBossRankListData", CUR_CLASS_NAME)
  elseif chartType == ChartType.PET_ARENA_RANK then
    RankListClass = import(".data.PetsArenaRankListData", CUR_CLASS_NAME)
  else
    RankListClass = import(".data.CommonRankListData", CUR_CLASS_NAME)
  end
  return RankListClass.New(chartType)
end
return RankListDataFactory.Commit()
