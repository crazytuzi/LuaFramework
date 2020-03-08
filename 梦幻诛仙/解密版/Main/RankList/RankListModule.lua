local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local RankListModule = Lplus.Extend(ModuleBase, "RankListModule")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local RankListData = require("Main.RankList.data.RankListData")
local SelfRankMgr = require("Main.RankList.SelfRankMgr")
local RankListUtils = require("Main.RankList.RankListUtils")
local def = RankListModule.define
def.const("table").RankListType = ChartType
def.field("table").rankLists = nil
def.field("table").activityIdMapRankList = nil
RankListModule.OPEN_LEVEL = 0
local instance
def.static("=>", RankListModule).Instance = function()
  if instance == nil then
    instance = RankListModule()
    instance.m_moduleId = ModuleId.RANK_LIST
  end
  return instance
end
def.override().Init = function(self)
  require("Main.RankList.RankListUIMgr").Instance()
  self.rankLists = {}
  self.activityIdMapRankList = {}
  RankListModule.OPEN_LEVEL = RankListUtils.GetRankListConsts("OPEN_LEVEL") or 0
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleLevelRankRes", RankListModule.S2C_GetRoleLevelRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleFightValueRankRes", RankListModule.S2C_GetRoleFightValueRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SGetPetYaoLiRankRes", RankListModule.S2C_GetPetYaoLiRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SGetRoleJingjiRankRes", RankListModule.S2C_GetArenaRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SChartRes", RankListModule.S2C_SChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SKeJuRankRes", RankListModule.S2C_GetKeJuRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGetGiveFlowerPointRankRes", RankListModule.S2C_GetGiveFlowerPointRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGetReceiveFlowerPointRankRes", RankListModule.S2C_GetReceiveFlowerPointRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SBigbossChartRes", RankListModule.S2C_BigbossChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SGetBigBossRemoteRankSuccess", RankListModule.S2C_SGetBigBossRemoteRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SGetRoleBigBossRemoteRankSuccess", RankListModule.S2C_SGetRoleBigBossRemoteRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SParaseleneChartRes", RankListModule.S2C_ParaseleneChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoRankRes", RankListModule.S2C_JiuXiaoRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoSelfRankRes", RankListModule.S2C_JiuXiaoSelfRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SMasterChartRes", RankListModule.S2C_ExperienceMasterRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SQMHWRankRes", RankListModule.S2C_GetQimaiRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleMFVRankRes", RankListModule.S2C_GetRoleMFVRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetOccupationMFVRankRes", RankListModule.S2C_GetOccupationMFVRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SHomeChartRes", RankListModule.S2C_HomeChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderRankRes", RankListModule.S2C_GetLadderRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderSelfRankRes", RankListModule.S2C_GetLadderSelfRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SHulaChartRes", RankListModule.S2C_HulaChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGetMenPaiStarsSuccess", RankListModule.S2C_SGetMenPaiStarsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SChildrenChartRes", RankListModule.S2C_SChildrenChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SGetCrossFieldRankSuccess", RankListModule.S2C_SGetCrossFieldRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossfield.SGetRoleCrossFieldRankSuccess", RankListModule.S2C_SGetRoleCrossFieldRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleBetRankSuccess", RankListModule.S2C_SGetCrossBattleBetRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoleCrossBattleBetRankSuccess", RankListModule.S2C_SGetRoleCrossBattleBetRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SWeekPopularityChartRes", RankListModule.S2C_SWeekPopularityChartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetChartSuccess", RankListModule.S2C_SGetPetsArenaChartRes)
  require("Main.RankList.Top3Mgr").Instance():Init()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, RankListModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.static("number", "=>", "boolean").IsOpen = function(heroLevel)
  return heroLevel >= RankListModule.OPEN_LEVEL
end
def.method("=>", "table").GetOpenedRankListClasses = function(self)
  local classCfgs = RankListUtils.GetRankListClassCfgs()
  local opendClassCfgs = {}
  for i, v in ipairs(classCfgs) do
    local classCfg = {}
    classCfg.id = v.id
    classCfg.name = v.name
    classCfg.subCfgIds = v.subCfgIds
    for _, rankListCfg in ipairs(v) do
      local rankListData = self:GetRankListData(rankListCfg.type)
      if rankListData:IsOpen() then
        table.insert(classCfg, rankListCfg)
      else
      end
    end
    if #classCfg > 0 then
      table.insert(opendClassCfgs, classCfg)
    end
  end
  return opendClassCfgs
end
def.method("number", "=>", RankListData).GetRankListData = function(self, type)
  local rankListData = self.rankLists[type]
  if rankListData == nil then
    rankListData = self:NewRankListData(type)
    self.rankLists[type] = rankListData
  end
  return rankListData
end
def.method("number", "=>", RankListData).NewRankListData = function(self, type)
  local RankListDataFactory = require("Main.RankList.RankListDataFactory")
  return RankListDataFactory.Instance():CreateRankListData(type)
end
def.method("number", "number", "number").ReqRankListDelegate = function(self, type, from, to)
  self:C2S_GetRankList(type, from, to)
end
def.method("number", "table").MapActivity2RankList = function(self, activityId, rankListData)
  self.activityIdMapRankList[activityId] = rankListData
end
def.method().ReleaseAllRankList = function(self)
  self.rankLists = {}
end
def.override().OnReset = function(self)
  self:ReleaseAllRankList()
  self.activityIdMapRankList = {}
end
def.static("table", "table").OnActivityEnd = function(params)
  local activityId = params[1]
  local rankListData = instance.activityIdMapRankList[activityId]
  if rankListData == nil then
    return
  end
  rankListData:SetExpire()
end
def.method("number", "number", "number").C2S_GetRankList = function(self, rankListType, from, to)
  local p = require("netio.protocol.mzm.gsp.chart.CGetRankList").new(rankListType, from, to + 1)
  gmodule.network.sendProtocol(p)
end
def.method("number").C2S_GetTopThreeListList = function(self, rankListType)
  local p = require("netio.protocol.mzm.gsp.chart.CGetTopThreeListList").new(rankListType)
  gmodule.network.sendProtocol(p)
end
def.static("table").S2C_GetRoleLevelRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_LEVEL)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetRoleFightValueRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_FIGHT_VALUE)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetPetYaoLiRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.PET_YAOLI)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetArenaRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_JINGJI)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_ARENA)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetKeJuRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_KEJU)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetGiveFlowerPointRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.GIVE_FLOWER)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetReceiveFlowerPointRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.RECEIVE_FLOWER)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_BigbossChartRes = function(p)
  local charType = RankListUtils.GetWroldBossChartTypeByOccup(p.ocp)
  local rankListData = instance:GetRankListData(charType)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetBigBossRemoteRankSuccess = function(p)
  local charType = RankListUtils.GetWroldBossRemoteChartTypeByOccup(p.occupation)
  local rankListData = instance:GetRankListData(charType)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetRoleBigBossRemoteRankSuccess = function(p)
  local charType = RankListUtils.GetWroldBossRemoteChartTypeByOccup(p.occupation)
  local rankListData = instance:GetRankListData(charType)
  rankListData:UnmarshalSelfRankProtocol(p)
end
def.static("table").S2C_ParaseleneChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.PARASELENE)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_JiuXiaoRankRes = function(p)
  local rankListData = instance:GetRankListData(p.rankType)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_JiuXiaoSelfRankRes = function(p)
  local rankListData = instance:GetRankListData(p.rankType)
  rankListData:UnmarshalSelfRankProtocol(p)
end
def.static("table").S2C_ExperienceMasterRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.EXPERIENCE_MASTER)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetQimaiRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.QMHW)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetRoleMFVRankRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.ROLE_MULTI_FIGHT_VALUE)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetOccupationMFVRankRes = function(p)
  local charType = RankListUtils.GetChartTypeByOccupation(p.occupationId)
  local rankListData = instance:GetRankListData(charType)
  if rankListData ~= nil then
    rankListData:UnmarshalProtocol(p)
  end
end
def.static("table").S2C_HomeChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.HOMELAND)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetLadderRankRes = function(p)
  local rankListData = instance:GetRankListData(p.rankType)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_GetLadderSelfRankRes = function(p)
  local rankListData = instance:GetRankListData(p.rankType)
  rankListData:UnmarshalSelfRankProtocol(p)
end
def.static("table").S2C_HulaChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.HULA)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetMenPaiStarsSuccess = function(p)
  local rankListData = instance:GetRankListData(ChartType.MENPAI_STAR)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SChildrenChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.CHILDREN_RATING)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetCrossFieldRankSuccess = function(p)
  local rankListData = instance:GetRankListData(p.rank_type)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetRoleCrossFieldRankSuccess = function(p)
  local rankListData = instance:GetRankListData(p.rank_type)
  rankListData:UnmarshalSelfRankProtocol(p)
end
def.static("table").S2C_SGetCrossBattleBetRankSuccess = function(p)
  local rankListData = instance:GetRankListData(p.rank_type)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetRoleCrossBattleBetRankSuccess = function(p)
  warn(">>>>>>>------S2C_SGetRoleCrossBattleBetRankSuccess:", p.rank_type, p.profit)
  local rankListData = instance:GetRankListData(p.rank_type)
  rankListData:UnmarshalSelfRankProtocol(p)
end
def.static("table").S2C_SWeekPopularityChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.FRIENDS_CIRCLE_POPULARITY)
  rankListData:UnmarshalProtocol(p)
end
def.static("table").S2C_SGetPetsArenaChartRes = function(p)
  local rankListData = instance:GetRankListData(ChartType.PET_ARENA_RANK)
  rankListData:UnmarshalProtocol(p)
end
return RankListModule.Commit()
