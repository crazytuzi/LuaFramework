local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ActivityModule = Lplus.Extend(ModuleBase, "ActivityModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = ActivityModule.define
local instance
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local DungeonModu = require("Main.Dungeon.DungeonModule")
local ThumbsupMgr = require("Main.activity.thumbsup.ThumbsupMgr")
local thumbsupMgr = ThumbsupMgr.Instance()
local activityInterface = ActivityInterface.Instance()
def.static("=>", ActivityModule).Instance = function()
  if instance == nil then
    instance = ActivityModule()
    instance.m_moduleId = ModuleId.ACTIVITY
  end
  return instance
end
def.field("table")._npcServiceTable = nil
def.field("table")._activityFnTable = nil
def.field("table")._activityInfoChangedFnTable = nil
def.field("boolean")._isAutoLuanShiYaoMo = false
def.override().Init = function(self)
  import(".JueZhanJiuXiao.JZJXMgr", MODULE_NAME).Instance():Init()
  import(".YaoShouTuXi.YaoShouTuXiMgr", MODULE_NAME).Instance():Init()
  import(".WatchMoon.WatchMoonMgr", MODULE_NAME).Instance():Init()
  import(".WorldGoal.WorldGoalMgr", MODULE_NAME).Instance():Init()
  import(".FestivalCountDown.FestivalCountDownMgr", MODULE_NAME).Instance():Init()
  import(".VisibleMonster.VisibleMonsterMgr", MODULE_NAME).Instance():Init()
  import(".MemoryCompetition.MemoryCompetitionMgr", MODULE_NAME).Instance():Init()
  import(".TreasureHunt.TreasureHuntMgr", MODULE_NAME).Instance():Init()
  import(".Mourn.MournMgr", MODULE_NAME).Instance():Init()
  import(".Medal.MedalMgr", MODULE_NAME).Instance():Init()
  import(".WishingWell.WishingWellMgr", MODULE_NAME).Instance():Init()
  import(".NPCAwardActivityMgr", MODULE_NAME).Instance():Init()
  import(".Tower.TowerMgr", MODULE_NAME).Instance():Init()
  import(".MultiLineTaskMgr", MODULE_NAME).Instance():Init()
  import(".MonkeyRun.MonkeyRunMgr", MODULE_NAME).Instance():Init()
  import(".FireworksShow.FireworksShowMgr", MODULE_NAME).Instance():Init()
  import(".Bandstand.BandstandMgr", MODULE_NAME).Instance():Init()
  import(".BakeCake.BakeCakeMgr", MODULE_NAME).Instance():Init()
  import(".ChristmasTree.ChristmasTreeMgr", MODULE_NAME).Instance():Init()
  import(".DragonBaoKu.DragonBaoKuMgr", MODULE_NAME).Instance():Init()
  local protocols = require("Main.activity.ActivityProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SAcceptCircleTaskRes", protocols.OnSAcceptCircleTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SisContinueZhenyao", protocols.OnSisContinueZhenyao)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SShimenDayPerfectAward", protocols.OnSShimenDayPerfectAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SShimenWeekPerfectAward", protocols.OnSShimenWeekPerfectAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncLegendTime", protocols.OnSSyncLegendTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncLegendTimeReward", protocols.OnSSyncLegendTimeReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SCircleTaskNormalResult", protocols.OnSCircleTaskNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncRenXingYiXiaCount", protocols.OnSSyncRenXingYiXiaCount)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynActivityChangeRes", protocols.OnSynActivityChangeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynActivityInitRes", protocols.OnSynActivityInitRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynLimitTimeActivityOpened", protocols.OnSynLimitTimeActivityOpened)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SDoublePointTip", protocols.OnSDoublePointTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SActivityEndTimeRes", protocols.OnSActivityEndTimeResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SActivityStageEndTimeRes", protocols.OnSActivityStageEndTimeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baotu.SNoBaoTuRes", protocols.OnSNoBaoTuRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPrice", protocols.OnSResItemYuanbaoPrice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSynZheyaoCount", protocols.OnSSynZheyaoCount)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SCurrentWeekCannotAccept", protocols.OnSCurrentWeekCannotAccept)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SGangeTaskNormalResult", protocols.OnSGangeTaskNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSeasonNormalResult", protocols.OnSSeasonNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SZheyaoAwardCountToMaxRes", protocols.OnSZheyaoAwardCountToMaxRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynActivitySpecialControlRes", protocols.OnSynActivitySpecialControlRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynActivitySpecialControlChangeRes", protocols.OnSynActivitySpecialControlChangeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncTreasureBoxActivityLeftTime", protocols.OnSSyncTreasureBoxActivityLeftTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncTreasureBoxActivityStartRes", protocols.OnSSyncTreasureBoxActivityStartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSendAwardPoolRes", protocols.OnSSendAwardPoolRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SFinishGangTaskeNotice", protocols.OnSFinishGangTaskeNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.STmpActivityNormalResult", protocols.OnSTmpActivityNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SStartLotteryViewRes", protocols.OnSStartLotteryViewRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynMoshouExchangeCountRes", protocols.OnSSynMoshouExchangeCountRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseMoshuFragmentRes", protocols.OnSUseMoshuFragmentRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", protocols.OnSCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSingleTaskNormalRes", protocols.OnSSingleTaskNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SGetGiftRep", protocols.OnSGetGiftRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SCanGetGifts", protocols.OnSCanGetGifts)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SCanGetGiftAward", protocols.OnSCanGetGiftAward)
  local protocols = require("Main.activity.HuanhunProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo", protocols.OnSSynHuanhuiInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SSynHuanHunStatus", protocols.OnSSynHuanHunStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SCheckXItemInfoRep", protocols.OnSCheckXItemInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SAddXItemInfoRep", protocols.OnSAddXItemInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SNextTaskItemsRep", protocols.OnSNextTaskItemsRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SHuanhunNormalResult", protocols.OnSHuanhunNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SSeekHelpFromGangReq", protocols.OnSSeekHelpFromGangReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SGangHelpAddItemSuc", protocols.OnSGangHelpAddItemSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SynGangHelpInfo", protocols.OnSynGangHelpInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SRmGangAllHelp", protocols.OnSRmGangAllHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SRmGangHelp", protocols.OnSRmGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SAddGangHelp", protocols.OnSAddGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.huanhun.SRmGangHelpCache", protocols.OnSRmGangHelpCache)
  local protocols = require("Main.activity.LingQiFengYinProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SMassExpInfo", protocols.OnSMassExpInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SGetMassExpTaskSuccess", protocols.OnSGetMassExpTaskSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SGetMassExpTaskFailed", protocols.OnSGetMassExpTaskFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SFillGridSuccess", protocols.OnSFillGridSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SFillGridFailed", protocols.OnSFillGridFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SGetAwardSuccess", protocols.OnSGetAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.SGetAwardFailed", protocols.OnSGetAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.massexp.STaskEndFailed", protocols.OnSTaskEndFailed)
  local protocols = require("Main.activity.BountyHunterProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bounty.SSynBountyInfo", protocols.OnSSynBountyInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bounty.SSynBTaskStatus", protocols.OnSSynBTaskStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bounty.SBountyNormalResult", protocols.OnSBountyNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bounty.SResetBountyCount", protocols.OnSResetBountyCount)
  local protocols = require("Main.activity.convoy.ConvoyProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SHuSongRes", protocols.OnSHuSongRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SupdateHuSong", protocols.OnSupdateHuSong)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynHuSongData", protocols.OnSynHuSongData)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncStartHuSong", protocols.OnSSyncStartHuSong)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SEndHuSongRes", protocols.OnSEndHuSongRes)
  local protocols = require("Main.activity.active.ActiveProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.active.SynActiveDataRes", protocols.OnSynActiveDataRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.active.SUpdateActiveDataRes", protocols.OnSUpdateActiveDataRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.active.STakeActiveAwardRes", protocols.OnSTakeActiveAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.active.SActiveNormalResult", protocols.OnSActiveNormalResult)
  local protocols = require("Main.activity.JiuZhouFuDai.FuDaiProtocols")
  protocols.RegisterEvents()
  local protocols = require("Main.activity.WishingWell.WishingWellProtocols")
  protocols.RegisterEvents()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ACTIVITY_CLICK, ActivityModule.OnActivityClick)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ActivityModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, ActivityModule.OnHeroPropInit)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ActivityModule.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ActivityModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerReq, ActivityModule.OnQueryEndingTimeFromServerReq)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerReq, ActivityModule.OnQueryPhaseFromServerReq)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ActivityModule.OnNPCService)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_RingChanged, ActivityModule.OnTaskRingChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_FinishRingChanged, ActivityModule.OnTaskRingFinishChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpBtn, ActivityModule.OnGangHelpBtn)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpAnno, ActivityModule.OnGangHelpAnno)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ActivityModule.OnNewDay)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.OPEN_ACTIVITY_AND_TIP_PANEL, ActivityModule.OnOpenActivityAndTip)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.OPEN_ACTIVITY_WEEKLY_AND_TIP_PANEL, ActivityModule.OnOpenActivityWeeklyAndTip)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.OPEN_ACTIVITY_WEEKLY_AND_TIP_PANEL_BY_TIME, ActivityModule.OnOpenActivityWeeklyAndTipByTime)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ActivityModule.OnNpcNomalServer)
  local ConvoyLogic = require("Main.activity.convoy.ConvoyLogic")
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_START, ConvoyLogic.OnConvoyStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_END, ConvoyLogic.OnConvoyEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_Succeed, ConvoyLogic.OnConvoySucceed)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ConvoyLogic.OnNewDay)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, ActivityModule.onMainUIReady)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, ActivityModule.onSynServerLevel)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, ActivityModule.OnAddBuff)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ActivityModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ActivityModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ActivityModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, ActivityModule.OnSetActivityRedPoint)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_CANCELED, ActivityModule.OnFindpathCanceled)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_DLG_SHOWN, ActivityModule.OnNPCDlgShown)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ActivityModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ActivityModule.OnFeatureOpenInit)
  ModuleBase.Init(self)
  self._npcServiceTable = {}
  self._npcServiceTable[NPCServiceConst.GetShilianTask] = ActivityModule.OnNPCService_GetShilianTask
  self._npcServiceTable[NPCServiceConst.QueryShilianCurrRing] = ActivityModule.OnNPCService_QueryShilianCurrRing
  self._npcServiceTable[NPCServiceConst.GetBaotuTask] = ActivityModule.OnNPCService_GetBaotuTask
  self._npcServiceTable[NPCServiceConst.GetShiMenQingYun] = ActivityModule.OnNPCService_GetShiMenQingYun
  self._npcServiceTable[NPCServiceConst.GetShiMenGuiWang] = ActivityModule.OnNPCService_GetShiMenGuiWang
  self._npcServiceTable[NPCServiceConst.GetShiMenTianYin] = ActivityModule.OnNPCService_GetShiMenTianYin
  self._npcServiceTable[NPCServiceConst.GetShiMenFenXiang] = ActivityModule.OnNPCService_GetShiMenFenXiang
  self._npcServiceTable[NPCServiceConst.GetShiMenHeHuan] = ActivityModule.OnNPCService_GetShiMenHeHuan
  self._npcServiceTable[NPCServiceConst.GetShiMenShengWu] = ActivityModule.OnNPCService_GetShiMenShengWu
  self._npcServiceTable[NPCServiceConst.GetShiMenCangYu] = ActivityModule.OnNPCService_GetShiMenCangYu
  self._npcServiceTable[NPCServiceConst.GetShiMenLingYin] = ActivityModule.OnNPCService_GetShiMenLingYin
  self._npcServiceTable[NPCServiceConst.GetShiMenYiNengZhe] = ActivityModule.OnNPCService_GetShiMenYiNengZhe
  self._npcServiceTable[NPCServiceConst.GetShiMenSenLuo] = ActivityModule.OnNPCService_GetShiMenSenLuo
  self._npcServiceTable[NPCServiceConst.GetZhenYao] = ActivityModule.OnNPCService_GetZhenYao
  self._npcServiceTable[NPCServiceConst.Huanhun_Get] = ActivityModule.OnNPCService_HuanhunGet
  self._npcServiceTable[NPCServiceConst.Huanhun] = ActivityModule.OnNPCService_HuanhunMishu
  self._npcServiceTable[NPCServiceConst.Huanhun_Next] = ActivityModule.OnNPCService_HuanhunNext
  self._npcServiceTable[NPCServiceConst.LingQiFengYin] = ActivityModule.OnNPCServive_LingQiFengYin
  self._npcServiceTable[NPCServiceConst.LingQiFengYin_Next] = ActivityModule.OnNPCServive_LingQiFengYinNext
  self._npcServiceTable[NPCServiceConst.BountyHunter] = ActivityModule.OnNPCService_BountyHunter
  self._npcServiceTable[NPCServiceConst.Convoy] = ActivityModule.OnNPCService_Convoy
  self._npcServiceTable[NPCServiceConst.Special_Convoy] = ActivityModule.OnNPCService_Special_Convoy
  self._npcServiceTable[NPCServiceConst.Convoy_Introduction] = ActivityModule.OnNPCService_Special_Convoy_Introduction
  self._npcServiceTable[NPCServiceConst.Activity_QQ_SHARED] = ActivityModule.OnNPCService_ShareQQ
  self._npcServiceTable[NPCServiceConst.GangTask] = ActivityModule.OnNPCService_GangTask
  self._npcServiceTable[NPCServiceConst.SeasonSingle] = ActivityModule.OnNPCService_SeasonSingle
  self._npcServiceTable[NPCServiceConst.SeasonMulti] = ActivityModule.OnNPCService_SeasonMulti
  self._npcServiceTable[NPCServiceConst.Activity_ZhongQiu] = ActivityModule.OnNPCService_ZhongQiu
  self._activityInfoChangedFnTable = {}
  self._activityInfoChangedFnTable[constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID] = ActivityModule.OnShimenActivityInfoChanged
  self._activityInfoChangedFnTable[constant.DeamonFight.LUANSHI_ACTIVITYID] = ActivityModule.OnLuanshiYaomoActivityInfoChange
  self._activityFnTable = {}
  self._activityFnTable[constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID] = ActivityModule.OnActivity_Shimen
  self._activityFnTable[constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID] = ActivityModule.OnActivity_CircleTASK
  self._activityFnTable[constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID] = ActivityModule.OnActivity_BAOTU
  self._activityFnTable[constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID] = ActivityModule.OnActivity_ZhenYao
  self._activityFnTable[constant.DeamonFight.LUANSHI_ACTIVITYID] = ActivityModule.OnActivity_LuanshiYaomo
  self._activityFnTable[constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID] = ActivityModule.OnActivity_Huanhunmishu
  self._activityFnTable[constant.BountyConsts.BOUNTYHUNTER_ACTIVITYID] = ActivityModule.OnActivity_BountyHunter
  self._activityFnTable[constant.HuSongConsts.CONVOY_ACTIVITY_ID] = ActivityModule.OnActivity_Convoy
  self._activityFnTable[constant.MenpaiPVPConsts.LEADER_BATTLE] = ActivityModule.OnActivity_LeaderBattle
  self._activityFnTable[constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID] = ActivityModule.OnActivity_GangBattle
  self._activityFnTable[constant.GangTaskConsts.ACTIVITYID] = ActivityModule.OnActivity_GangTask
  self._activityFnTable[constant.SeasonSingleConsts.ACTIVITYID] = ActivityModule.OnActivity_SeasonSingle
  self._activityFnTable[constant.SeasonMultiConsts.ACTIVITYID] = ActivityModule.OnActivity_SeasonMulti
  self._activityFnTable[constant.WorldQuestionConsts.ACTIVITYID] = ActivityModule.OnActivity_WorldAnswer
  self._activityFnTable[constant.QimaiConsts.ACTIVITY_ID] = ActivityModule.OnActivity_Qimai
  self._activityFnTable[constant.CoupleDailyActivityConst.COUPLE_DAILY_ACTIVITY_ID] = ActivityModule.OnActivity_BiYiLianZhi
  self._activityFnTable[constant.BaoKuConsts.miBaoActivityId] = ActivityModule.OnActivity_TianDiBaoKu
  self._activityFnTable[constant.CCarnivalConsts.carnivalActivityId] = ActivityModule.OnActivity_NewServerAward
  self._activityFnTable[constant.CQingfuCfgConsts.RMB_GIFT_BAG_ACTIVITY_CFG_ID] = ActivityModule.OnActivity_DailyGift
  self._activityFnTable[constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID] = ActivityModule.OnActivity_DailyLogin
  self._activityFnTable[constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID] = ActivityModule.OnActivity_AccumulatedLogin
  self._activityFnTable[constant.CLuckyBagCfgConsts.ACTIVITY_CFG_ID] = ActivityModule.OnActivity_JiuZhouFuDai
  self._activityFnTable[constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID] = ActivityModule.OnActivity_LingQiFengYin
  local ActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
  warn("pvp3 id =", ActivityID)
  self._activityFnTable[ActivityID] = ActivityModule.OnActivity_PVP3
  ActivityID = 350000011
  self._activityFnTable[ActivityID] = ActivityModule.OnActivity_ShiERShengXiao
  self._activityFnTable[350000307] = ActivityModule.OnActivity_ZhongQiu
  self._activityFnTable[constant.CThumbsupConsts.ACTIVITY_CFG_ID] = ActivityModule.OnActivity_Thumbsup
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetBaotuTask, ActivityModule.OnNPCService_GetBaotuTaskCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenQingYun, ActivityModule.OnNPCService_ShiMenQingYunCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenGuiWang, ActivityModule.OnNPCService_ShiMenGuiWangCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenTianYin, ActivityModule.OnNPCService_ShiMenTianYinCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenFenXiang, ActivityModule.OnNPCService_ShiMenFenXiangCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenHeHuan, ActivityModule.OnNPCService_ShiMenHeHuanCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenShengWu, ActivityModule.OnNPCService_ShiMenShengWuCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenCangYu, ActivityModule.OnNPCService_ShiMenCangYuCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenLingYin, ActivityModule.OnNPCService_ShiMenLingYinCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GetShiMenYiNengZhe, ActivityModule.OnNPCService_ShiMenYiNengZheCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GangTask, ActivityModule.OnNPCService_GangTaskCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.Huanhun_Get, ActivityModule.OnNPCService_HuanhunGetCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.Huanhun, ActivityModule.OnNPCService_HuanhunCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.Huanhun_Next, ActivityModule.OnNPCService_HuanhunNextCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.LingQiFengYin, ActivityModule.OnNPCService_LingQiFengYinCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.LingQiFengYin_Next, ActivityModule.OnNPCService_LingQiFengYinNextCondition)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.LingQiFengYin_Rule, ActivityModule.OnNPCService_LingQiFengYinRuleCondition)
  npcInterface:RegisterNPCServiceCustomName(NPCServiceConst.Convoy, ActivityModule.OnNPCService_Convoy_Modifiy)
  npcInterface:RegisterNPCServiceCustomName(NPCServiceConst.Special_Convoy, ActivityModule.OnNPCService_Special_Convoy_Modifiy)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.Special_Convoy, ActivityModule.OnNPCService_Special_Convoy_Condition)
  npcInterface:RegisterNPCServiceCustomCondition(constant.ZhenYaoActivityCfgConsts.ZhenYao_DEC_SERVICE1, ActivityModule.OnNpcServer_Zhenyao_Des_Condition)
  npcInterface:RegisterNPCServiceCustomCondition(constant.ZhenYaoActivityCfgConsts.ZhenYao_DEC_SERVICE2, ActivityModule.OnNpcServer_Zhenyao_Des_Condition)
  npcInterface:RegisterNPCServiceCustomCondition(constant.SeasonSingleConsts.NPC_SERVICE, ActivityModule.OnNPCService_SeasonSingleCondition)
end
def.override().OnReset = function(self)
  self._isAutoLuanShiYaoMo = false
  activityInterface:Reset()
  import(".WatchMoon.WatchMoonMgr", MODULE_NAME).Instance():Reset()
  require("Main.activity.JiuZhouFuDai.data.FuDaiData").Instance():Reset()
  import(".Tower.TowerMgr", MODULE_NAME).Instance():Reset()
end
def.method().jumpActivity = function(self)
  local exchangePanel = require("Main.Exchange.ui.ExchangePanel").Instance()
  if exchangePanel:IsShow() then
    exchangePanel:DestroyPanel()
  end
  ActivityModule.OnActivityClick({}, {})
end
def.static("table", "table").OnActivityClick = function(param1, param2)
  local list = activityInterface:GetDailyActivityList()
  if #list >= 1 then
    require("Main.activity.ui.ActivityMain").Instance():ShowDlg()
  else
    Toast(textRes.Common[10])
  end
  local bubbleLabel = require("GUI.ECGUIMan").Instance().m_UIRoot:FindDirect("panel_main/Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity/Label_New")
  if not bubbleLabel then
    return
  end
  bubbleLabel:SetActive(false)
end
def.static("table", "table").OnHeroLevelUp = function(param1, param2)
  GameUtil.AddGlobalTimer(0.1, true, function()
    activityInterface:SetLevelUpInfo(param1.lastLevel, param1.level)
    activityInterface:RefreshActivityList()
  end)
  activityInterface:refreshActivityTimer()
end
def.static("table", "table").OnHeroPropInit = function(param1, param2)
  activityInterface:RefreshActivityList()
end
def.static("table", "table").OnActivityInfoChanged = function(p1, p2)
  local activityId = p1[1]
  local fn = instance._activityInfoChangedFnTable[activityId]
  if fn ~= nil then
    fn(activityId)
  end
  activityInterface:RefreshActivityList()
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityID = p1[1]
  local self = instance
  local singTaskCfg = ActivityInterface.GetSingleTaskCfg(activityID)
  if singTaskCfg then
    if singTaskCfg.openId == 0 or IsFeatureOpen(singTaskCfg.openId) then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
        singTaskCfg.npcid
      })
    end
    return
  end
  local fn = self._activityFnTable[activityID]
  warn("----------------OnActivityTodo:", activityID, fn)
  if fn ~= nil then
    fn(activityID)
  end
end
def.static("table", "table").OnQueryEndingTimeFromServerReq = function(p1, p2)
  local activityId = p1[1]
  local p = require("netio.protocol.mzm.gsp.activity.CActivityEndTimeReq").new(activityId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnQueryPhaseFromServerReq = function(p1, p2)
  local activityId = p1[1]
  local phase = p1[2]
  local p = require("netio.protocol.mzm.gsp.activity.CActivityStageEndTimeReq").new(activityId, phase)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local npcID = p1[2]
  local singleTaskActivityId = ActivityInterface.GetSingleTaskActivityId(npcID, serviceID)
  if singleTaskActivityId > 0 then
    local activityInfo = activityInterface:GetActivityInfo(singleTaskActivityId)
    local activityCfg = ActivityInterface.GetActivityCfgById(singleTaskActivityId)
    if activityInfo then
      local count = activityInfo.count or 0
      if 0 < activityCfg.recommendCount and count >= activityCfg.recommendCount then
        Toast(textRes.activity[388])
        return
      end
    end
    local singTaskCfg = ActivityInterface.GetSingleTaskCfg(singleTaskActivityId)
    if singTaskCfg.openId == 0 or IsFeatureOpen(singTaskCfg.openId) then
      local p = require("netio.protocol.mzm.gsp.activity.CAcceptSingleCircleTask").new(singleTaskActivityId)
      gmodule.network.sendProtocol(p)
    else
      Toast(textRes.activity[407])
    end
    return
  end
  local succeed = ActivityModule.OnNPCService_Luanshiyaomo(serviceID, npcID)
  if succeed then
    warn("--------over")
    return
  end
  local serviceFn = instance._npcServiceTable[serviceID]
  local fivePerciousItemId = ActivityModule.GetFivePreciousExchange(npcID, serviceID)
  if fivePerciousItemId > 0 then
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_ITEM_EXCHANGE)
    if isServerOpen then
      local ItemUtils = require("Main.Item.ItemUtils")
      local fivePreciousItemCfg = ItemUtils.GetFivePreciousItemCfg(fivePerciousItemId)
      local exchangeID = fivePreciousItemCfg.exchangeid
      local NpcExchangePanel = require("Main.Exchange.ui.NpcExchangePanel")
      local npcExchangePanel = NpcExchangePanel.Instance()
      npcExchangePanel:ShowPanel(exchangeID, fivePreciousItemCfg.isuseyuanbao)
    else
      Toast(textRes.activity[402])
    end
    return
  end
  if serviceFn ~= nil then
    serviceFn(serviceID, npcID)
  else
  end
end
def.static("number", "number", "=>", "number").GetFivePreciousExchange = function(npcId, serviceId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FIVE_PRECIOUS_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local itemId = 0
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local curNpcId = record:GetIntValue("npcid")
    local curServiceId = record:GetIntValue("npcservice")
    if npcId == curNpcId and serviceId == curServiceId then
      itemId = record:GetIntValue("id")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return itemId
end
def.static("table", "table").OnTaskRingChanged = function(p1, p2)
  local graphId = p1[1]
  local curRing = p1[2]
end
def.static("table", "table").OnTaskRingFinishChanged = function(p1, p2)
  local graphId = p1[1]
  local curRing = p1[2]
end
def.static("table", "table").OnGangHelpBtn = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp.level < constant.HuanHunMiShuConsts.HUANHUN_HELP_OTHER_LEVEL_LESS then
      Toast(string.format(textRes.activity[206], constant.HuanHunMiShuConsts.HUANHUN_HELP_OTHER_LEVEL_LESS))
      return
    end
    local roleId = p1[2]
    roleId = Int64.new(roleId)
    local soltId = p1[3]
    soltId = tonumber(soltId)
    local p = require("netio.protocol.mzm.gsp.huanhun.CCheckXItemInfoReq").new(roleId, soltId)
    gmodule.network.sendProtocol(p)
  elseif activityId == constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID then
    local teamData = require("Main.Team.TeamData").Instance()
    if teamData:HasTeam() == true then
      Toast(textRes.Team[45])
      return
    end
    local myRoleID = _G.GetMyRoleID()
    local roleID = p1[2]
    roleID = Int64.new(roleID)
    if myRoleID:eq(roleID) then
      Toast(textRes.activity[222])
      return
    end
    local teamID = p1[3]
    teamID = Int64.new(teamID)
    local p = require("netio.protocol.mzm.gsp.team.CApplyTeamByTeamId").new(teamID)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnGangHelpAnno = function(p1, p2)
  local SSyncGangHelp = require("netio.protocol.mzm.gsp.gang.SSyncGangHelp")
  local helperType = p1[1]
  local paramString = p1[2]
  local paramLong = p1[3]
  local paramInt = p1[4]
  if helperType == SSyncGangHelp.TYPE_HUN then
    local itemID = paramInt[SSyncGangHelp.HUN_ITEM_ID]
    local itemNum = paramInt[SSyncGangHelp.HUN_ITEM_NUM]
    local itemSlot = paramInt[SSyncGangHelp.HUN_ITEM_SLOT_NUM]
    local roleID = paramLong[SSyncGangHelp.HUN_ROLE_ID]
    local GangData = require("Main.Gang.data.GangData").Instance()
    local memberInfo = GangData:GetMemberInfoByRoleId(roleID)
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase2(itemID)
    local itemName = ""
    if not memberInfo then
      return
    end
    if itemBase ~= nil then
      itemName = itemBase.name
    else
      local filterCfg = ItemUtils.GetItemFilterCfg(itemID)
      itemName = filterCfg.name
    end
    local GangModule = require("Main.Gang.GangModule")
    local button = GangModule.GetHelpAnnoStr(textRes.activity[215], constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID, tostring(roleID), tostring(itemSlot))
    local display = string.format(textRes.Gang[169], memberInfo.name, textRes.activity[220], itemName, itemNum, button)
    GangModule.ShowInGangChannel(display)
  elseif helperType == SSyncGangHelp.TYPE_CIRCLETASK then
    local roleID = paramLong[SSyncGangHelp.ROLE_ID]
    local teamID = paramLong[SSyncGangHelp.TEAM_ID]
    local taskID = paramInt[SSyncGangHelp.TASK_ID]
    local taskCfg = TaskInterface.GetTaskCfg(taskID)
    local GangData = require("Main.Gang.data.GangData").Instance()
    local memberInfo = GangData:GetMemberInfoByRoleId(roleID)
    if not memberInfo then
      return
    end
    local GangModule = require("Main.Gang.GangModule")
    local button = GangModule.GetHelpAnnoStr(textRes.activity[96], constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID, tostring(roleID), tostring(teamID))
    local display = string.format(textRes.Gang[173], memberInfo.name, textRes.activity[85], taskCfg.taskName, button)
    GangModule.ShowInGangChannel(display)
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  warn("!!!!!!!!!!activity OnNewDay curServetTime:", GetServerTime())
  activityInterface._activeDatas = {}
  activityInterface._awardActiveCfgids = {}
  activityInterface._currentTotalActive = 0
  activityInterface:RefreshActivityList()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, nil)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, nil)
end
def.static("table", "table").OnOpenActivityAndTip = function(p1, p2)
  local activityId = p1.activityId
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local activityMain = ActivityMain.Instance()
  activityMain._targetActivityID = activityId
  activityMain._targetTip = true
  activityMain:ShowDlg()
end
def.static("table", "table").OnOpenActivityWeeklyAndTip = function(p1, p2)
  local activityId = p1.activityId
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local ActivityWeekly = require("Main.activity.ui.ActivityWeekly")
  local UIBehaviorShowUI = require("Utility.UIBehaviorShowUI")
  local UIBehaviorWaitUIShowShowUI = require("Utility.UIBehaviorWaitUIShowShowUI")
  local UIBehaviorWaitUIShowClick = require("Utility.UIBehaviorWaitUIShowClick")
  local UIBehaviorMgr = require("Utility.UIBehaviorMgr")
  local mgr = UIBehaviorMgr.Instance()
  local activityMain = ActivityMain.Instance()
  local tsu = UIBehaviorShowUI.New(activityMain, ActivityMain.ShowDlg)
  local tssu = UIBehaviorWaitUIShowShowUI.New(ActivityWeekly.Instance(), ActivityWeekly.ShowDlg, "panel_activty")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CALENDER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local found = false
  local targetRow = 0
  local targetCol = 0
  local beginIdx = 1
  for i = beginIdx, ActivityWeekly.ROWS do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    for j = 1, 7 do
      local activityID = entry:GetIntValue(string.format("actvityId%d", j))
      if activityID == activityId then
        found = true
        targetRow = i
        targetCol = j
        break
      end
    end
    if found == true then
      break
    end
  end
  if found == false then
    return
  end
  local targetName = string.format("Box_Activity_%02d_%02d", targetRow, targetCol)
  local tsc = UIBehaviorWaitUIShowClick.New(ActivityWeekly.Instance(), "panel_activityweekly", targetName)
  mgr:AddBehavior(tsu)
  mgr:AddBehavior(tssu)
  mgr:AddBehavior(tsc)
  mgr:Do()
end
def.static("table", "table").OnOpenActivityWeeklyAndTipByTime = function(p1, p2)
  local hour = p1.hour
  local targetActivityID = 0
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local ActivityWeekly = require("Main.activity.ui.ActivityWeekly")
  local UIBehaviorShowUI = require("Utility.UIBehaviorShowUI")
  local UIBehaviorWaitUIShowShowUI = require("Utility.UIBehaviorWaitUIShowShowUI")
  local UIBehaviorWaitUIShowClick = require("Utility.UIBehaviorWaitUIShowClick")
  local UIBehaviorMgr = require("Utility.UIBehaviorMgr")
  local mgr = UIBehaviorMgr.Instance()
  local activityMain = ActivityMain.Instance()
  local tsu = UIBehaviorShowUI.New(activityMain, ActivityMain.ShowDlg)
  local tssu = UIBehaviorWaitUIShowShowUI.New(ActivityWeekly.Instance(), ActivityWeekly.ShowDlg, "panel_activty")
  local nowDayWeek = tonumber(os.date("%w", nowSec))
  if nowDayWeek == 0 then
    nowDayWeek = 7
  end
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CALENDER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local found = false
  local targetRow = 0
  local targetCol = 0
  local beginIdx = 1
  for i = beginIdx, ActivityWeekly.ROWS do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local activityID = entry:GetIntValue(string.format("actvityId%d", nowDayWeek))
    if activityID ~= nil and activityID ~= 0 then
      local cfg = ActivityInterface.GetActivityCfgById(activityID)
      for idx, timeDurationCommonCfg in pairs(cfg.activityTimeCfgs) do
        local beginHour = timeDurationCommonCfg.timeCommonCfg.activeHour
        local beginMinute = timeDurationCommonCfg.timeCommonCfg.activeMinute
        if hour <= beginHour then
          found = true
          targetRow = i
          targetCol = nowDayWeek
          targetActivityID = activityID
          activityMain._targetActivityID = activityID
          break
        end
      end
      if found == true then
        break
      end
    end
  end
  if found == false then
    return
  end
  local targetName = string.format("Box_Activity_%02d_%02d", targetRow, targetCol)
  local tsc = UIBehaviorWaitUIShowClick.New(ActivityWeekly.Instance(), "panel_activityweekly", targetName)
  mgr:AddBehavior(tsu)
  mgr:AddBehavior(tssu)
  mgr:AddBehavior(tsc)
  mgr:Do()
end
def.static().ShowActivityMain = function()
  local activityMain = require("Main.activity.ui.ActivityMain").Instance()
  activityMain:ShowDlg()
end
def.static("number", "=>", "boolean").OnNPCService_ShilianTaskCondition = function(ServiceID)
  local infos = taskInterface:GetTaskInfos()
  for taskId, graphIdValue in pairs(infos) do
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if graphCfg.taskType == TaskConsts.TASK_TYPE_TRIAL and info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
        return false
      end
    end
  end
  return true
end
def.static("number", "number").OnNPCService_GetShilianTask = function(serviceID, npcID)
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID)
  if succeed == false then
    Toast(textRes.activity[82])
    return
  end
  if ActivityInterface.CheckActivityConditionTeamMemberCount(constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID, true) == false then
    return
  end
  if ActivityInterface.CheckActivityConditionLevel(constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID, true) == false then
    return
  end
  local infos = taskInterface:GetTaskInfos()
  for taskId, graphIdValue in pairs(infos) do
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if graphCfg.taskType == TaskConsts.TASK_TYPE_TRIAL and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        Toast(textRes.activity[80])
        return
      end
    end
  end
  local ItemModule = require("Main.Item.ItemModule")
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(constant.CircleTaskConsts.Circle_START_TASK_NEED_SILVER) == true then
    Toast(string.format(textRes.activity[83], constant.CircleTaskConsts.Circle_START_TASK_NEED_SILVER))
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[85], string.format(textRes.activity[84], constant.CircleTaskConsts.Circle_START_TASK_NEED_SILVER), ActivityModule.OnAcceptShilianTaskConfirm, {})
end
def.static("number", "table").OnAcceptShilianTaskConfirm = function(id, tag)
  if id == 1 then
    local CAcceptCircleTaskReq = require("netio.protocol.mzm.gsp.activity.CAcceptCircleTaskReq").new()
    gmodule.network.sendProtocol(CAcceptCircleTaskReq)
    print("** gmodule.network.sendProtocol(\"netio.protocol.mzm.gsp.activity.CAcceptCircleTaskReq\")")
  end
end
def.static("number", "number").OnNPCService_QueryShilianCurrRing = function(serviceID, npcID)
  local hasShilian = false
  local infos = taskInterface:GetTaskInfos()
  for taskId, graphIdValue in pairs(infos) do
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if graphCfg.taskType == TaskConsts.TASK_TYPE_TRIAL and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        hasShilian = true
        break
      end
    end
  end
  local ring = taskInterface:GetTaskRing(constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID)
  if ring < 0 then
    ring = 0
  end
  local circle = 0
  local activityCfg = ActivityInterface.GetActivityCfgById(constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID)
  local activityInfo = activityInterface:GetActivityInfo(constant.CircleTaskConsts.Circle_TASK_ACTIVITY_ID)
  if activityInfo ~= nil then
    circle = activityInfo.count
  end
  local contents = {}
  local content = {}
  content.npcid = npcID
  if hasShilian == true then
    local circle = math.max(0, circle - 1)
    content.txt = string.format(textRes.activity[89], circle, ring)
  elseif circle == 0 then
    content.txt = string.format(textRes.activity[94], circle)
  else
    local circle = math.max(0, circle - 1)
    content.txt = string.format(textRes.activity[95], circle)
  end
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("number", "number").OnNPCService_GetBaotuTask = function(serviceID, npcID)
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID)
  if succeed == false then
    Toast(textRes.activity[101])
    return
  end
  if ActivityInterface.CheckActivityConditionLevel(constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID, true) == false then
    return
  end
  if ActivityInterface.CheckActivityConditionTeamMemberCount(constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID, true) == false then
    return
  end
  if taskInterface:HasTaskByGraphID(constant.BaoTuActivityCfgConsts.BAOTU_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[100])
  end
  local CJoinBaoTuReq = require("netio.protocol.mzm.gsp.baotu.CJoinBaoTuReq").new()
  gmodule.network.sendProtocol(CJoinBaoTuReq)
end
def.static("number").OnActivity_Shimen = function(activityID)
  local t = {
    constant.ShimenActivityCfgConsts.SHIMEN_GUIWANG_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_QINGYUN_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_TIANYIN_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_FENXIANG_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_HEHUAN_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_SHENGWU_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_CANGYU_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_LINGYINDIAN_GRAPH_ID,
    constant.ShimenActivityCfgConsts.SHIMEN_YINENGZHE_GRAPH_ID
  }
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local myGraphID = t[heroProp.occupation]
  local taskInfo = taskInterface._taskInfo
  for taskId, graphIdValue in pairs(taskInfo) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == myGraphID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
        return
      end
    end
  end
  for k, v in pairs(t) do
    if taskInterface:HasTaskByGraphID(v, false, true, true) == true then
      return
    end
  end
  local menpaiNPC = activityInterface:GetMenpaiNPCData(heroProp.occupation)
  if menpaiNPC ~= nil then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      menpaiNPC.NPCID
    })
  end
end
def.static("number").OnShimenActivityInfoChanged = function(activityID)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityID)
  local info = activityInterface:GetActivityInfo(activityID)
  if info == nil or info.count == activityCfg.recommendCount then
  end
end
def.static("number", "table").OnAcceptShimenTaskConfirm = function(id, tag)
  if id == 0 then
    ActivityModule.SendGetShiMen()
  end
end
def.static("number").OnActivity_CircleTASK = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.CircleTaskConsts.Circle_ACCEPT_NPC_ID
  })
end
def.static("number").OnActivity_BAOTU = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.BaoTuActivityCfgConsts.BAOTU_NPC_ID
  })
end
def.static("number").OnActivity_ZhenYao = function(activityID)
  local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityID)
  local minLv = actCfg.levelMin
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local myLv = heroProp.level
  if minLv > myLv then
    Toast(string.format(textRes.activity[383], minLv))
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == false then
    require("Main.TeamPlatform.ui.TeamPlatformPanel").Instance():FocusOnTarget(constant.TeamPlatformConsts.ZHEN_YAO_MATCH_ID)
    return
  end
  local taskInfo = taskInterface._taskInfo
  for taskId, graphIdValue in pairs(taskInfo) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
        return
      end
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.ZhenYaoActivityCfgConsts.ZhenYao_NPC_ID
  })
end
def.static("=>", "number").GetLuanShiYaoMoNpcId = function()
  local FlyModule = require("Main.Fly.FlyModule")
  local hasAirCraft = FlyModule.Instance():HasAirCraft()
  local myLevel = require("Main.Hero.Interface").GetHeroProp().level
  local targetMap = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DEAMON_TRANSFER_MAP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local highLevel = DynamicRecord.GetIntValue(entry, "highLevel")
    local lowLevel = DynamicRecord.GetIntValue(entry, "lowLevel")
    local mapId = DynamicRecord.GetIntValue(entry, "mapId")
    local npcid = DynamicRecord.GetIntValue(entry, "npcid")
    local skyNpcid = DynamicRecord.GetIntValue(entry, "skyNpcid")
    if myLevel >= lowLevel and myLevel <= highLevel then
      local FlyModule = require("Main.Fly.FlyModule")
      local hasAirCraft = FlyModule.Instance():HasAirCraft()
      if hasAirCraft then
        return skyNpcid
      else
        return npcid
      end
      return 0
    end
  end
  return 0
end
def.static("number").OnActivity_LuanshiYaomo = function(activityID)
  local npcId = ActivityModule.GetLuanShiYaoMoNpcId()
  if npcId > 0 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
    return
  end
  Toast(textRes.activity[361])
end
def.static("number").OnActivity_Huanhunmishu = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.HuanHunMiShuConsts.HUANHUN_NPC_ID
  })
end
def.static("number").OnActivity_LingQiFengYin = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.LingQiFengYinConsts.LINGQIFENGYIN_NPC_ID
  })
end
def.static("number").OnActivity_BountyHunter = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.BountyConsts.BOUNTYHUNTER_NPC_ID
  })
end
def.static("number").OnActivity_Convoy = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.HuSongConsts.CONVOY_NPCID
  })
end
def.static("number").OnActivity_PVP3 = function(activityID)
  local NPCID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "EnterNpc"):GetIntValue("value")
  warn("NPCID =", NPCID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {NPCID})
end
def.static("number").OnActivity_ShiERShengXiao = function(activityID)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityID)
  local desc = textRes.activity[321]
  if activityCfg then
    desc = activityCfg.activityDes
    desc = string.gsub(desc, "%[([0-9a-fA-F]+)%](.-)(%[%-%])", "<font color=#%1>%2</font>")
  end
  Toast(desc)
end
def.static("number").OnActivity_ZhongQiu = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {150111955})
end
def.static("number").OnActivity_Thumbsup = function(activityID)
  thumbsupMgr:GoThumbsup()
end
def.static("number").OnActivity_LeaderBattle = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.MenpaiPVPConsts.EnterNpc
  })
end
def.static("number").OnActivity_GangBattle = function(activityID)
  local GangBattleMgr = require("Main.Gang.GangBattleMgr")
  local gangBattleMgr = GangBattleMgr.Instance()
  gangBattleMgr:GotoGangBattle()
end
def.static("number").OnActivity_GangTask = function(activityID)
  local gangId = require("Main.Gang.GangModule").Instance().data:GetGangId()
  if not gangId then
    Toast(textRes.Gang[45])
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.GangTaskConsts.NPC_ID
  })
end
def.static("number").OnActivity_SeasonSingle = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.SeasonSingleConsts.NPC_ID
  })
end
def.static("number").OnActivity_SeasonMulti = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.SeasonMultiConsts.NPC_ID
  })
end
def.static("number").OnActivity_WorldAnswer = function(activityID)
  Toast(textRes.activity[340])
end
def.static("number").OnActivity_Qimai = function(activityID)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.QimaiConsts.NPC_ID
  })
end
def.static("number").OnActivity_BiYiLianZhi = function(activityID)
  local MarriageInterface = require("Main.Marriage.MarriageInterface")
  if MarriageInterface.IsMarried() then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CoupleDailyActivityConst.NPC_ID
    })
  else
    Toast(textRes.activity[370])
  end
end
def.static("number").OnActivity_TianDiBaoKu = function(activityID)
  local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
  LotteryAwardMgr.Instance():OpenBaoKuPanel()
end
def.static("number").OnActivity_NewServerAward = function(activityID)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  AwardPanel.Instance():ShowPanelEx(AwardPanel.NodeId.NewServerAward)
end
def.static("number").OnActivity_DailyGift = function(activityID)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  AwardPanel.Instance():ShowPanelEx(AwardPanel.NodeId.DailyGiftAward)
end
def.static("number").OnActivity_DailyLogin = function(activityID)
  require("Main.CustomActivity.ui.CustomActivityPanel").Instance():ShowPanelWithTabName("Tab_Carnival")
end
def.static("number").OnActivity_AccumulatedLogin = function(activityID)
  require("Main.CustomActivity.ui.CustomActivityPanel").Instance():ShowPanelWithTabName("Tab_Carnival")
end
def.static("number").OnActivity_JiuZhouFuDai = function(activityID)
  local text = textRes.JiuZhouFuDai[4]
  if text then
    Toast(text)
  end
end
def.static("number", "=>", "boolean").OnNPCService_GetBaotuTaskCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.BaoTuActivityCfgConsts.BAOTU_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenQingYunCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_QINGYUN_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenQingYun = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_QINGYUN_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenGuiWangCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_GUIWANG_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenGuiWang = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_GUIWANG_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenTianYinCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_TIANYIN_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenTianYin = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_TIANYIN_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenFenXiangCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_FENXIANG_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenFenXiang = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_FENXIANG_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenHeHuanCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_HEHUAN_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenHeHuan = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_HEHUAN_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenShengWuCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_SHENGWU_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenCangYuCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_CANGYU_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenLingYinCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_LINGYINDIAN_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_ShiMenYiNengZheCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_YINENGZHE_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_GetShiMenShengWu = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_SHENGWU_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "number").OnNPCService_GetShiMenCangYu = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_CANGYU_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "number").OnNPCService_GetShiMenLingYin = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_LINGYINDIAN_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "number").OnNPCService_GetShiMenYiNengZhe = function(serviceID, npcID)
  if taskInterface:HasTaskByGraphID(constant.ShimenActivityCfgConsts.SHIMEN_YINENGZHE_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[110])
  end
  ActivityModule.SendGetShiMen()
end
def.static("number", "number").OnNPCService_GetShiMenSenLuo = function(serviceID, npcID)
  error("!!!!!!!!!!!!OnNPCService_GetShiMenSenLuo ")
end
def.static().SendGetShiMen = function()
  local CJoinShimenReq = require("netio.protocol.mzm.gsp.activity.CJoinShimenReq").new()
  gmodule.network.sendProtocol(CJoinShimenReq)
end
def.static("number", "number").OnNPCService_GetZhenYao = function(serviceID, npcID)
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID)
  if succeed == false then
    Toast(textRes.activity[130])
    return
  end
  if ActivityInterface.CheckActivityConditionLevel(constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID, true) == false then
    return
  end
  if ActivityInterface.CheckActivityConditionTeamMemberCount(constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID, true) == false then
    return
  end
  local taskInfo = taskInterface._taskInfo
  for taskId, graphIdValue in pairs(taskInfo) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
        return
      end
    end
  end
  if taskInterface:HasTaskByGraphID(constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID, false, true, true) == true then
    Toast(textRes.activity[120])
  end
  local CJoinZhenyaoReq = require("netio.protocol.mzm.gsp.activity.CJoinZhenyaoReq").new()
  gmodule.network.sendProtocol(CJoinZhenyaoReq)
end
def.static("number", "=>", "boolean").OnNPCService_HuanhunGetCondition = function(ServiceID)
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if activityInterface._huanhunStatus == 0 then
    return true
  end
  local nowSec = GetServerTime()
  local enddingSec = activityInterface._huanhunTimeLimit:ToNumber() / 1000
  local remainSec = enddingSec - nowSec
  local status = activityInterface._huanhunStatus
  local ret = (status == SSynHuanhuiInfo.ST_HUN__ACCEPT or status == SSynHuanhuiInfo.ST_HUN__HAND_UP) and remainSec < 0
  return ret
end
def.static("number", "=>", "boolean").OnNPCService_HuanhunCondition = function(ServiceID)
  if activityInterface._huanhunTimeLimit == nil then
    return false
  end
  local nowSec = GetServerTime()
  local enddingSec = activityInterface._huanhunTimeLimit:ToNumber() / 1000
  local remainSec = enddingSec - nowSec
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  local ret = activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__ACCEPT and remainSec >= 0 or activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__FINISH
  return ret
end
def.static("number", "=>", "boolean").OnNPCService_HuanhunNextCondition = function(ServiceID)
  if activityInterface._huanhunTimeLimit == nil then
    return false
  end
  local nowSec = GetServerTime()
  local enddingSec = activityInterface._huanhunTimeLimit:ToNumber() / 1000
  local remainSec = enddingSec - nowSec
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  local hasHuanhunNext = false
  if activityInterface._huanhunNextItem ~= nil then
    for k, v in pairs(activityInterface._huanhunNextItem) do
      if v ~= 0 then
        hasHuanhunNext = true
        break
      end
    end
  end
  local ret = hasHuanhunNext == true and activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__HAND_UP and remainSec >= 0
  return ret
end
def.static("number", "number").OnNPCService_HuanhunGet = function(serviceID, npcID)
  local HuanhunGet = require("Main.activity.ui.HuanhunGet")
  HuanhunGet.Instance():ShowDlg()
end
def.static("number", "number").OnNPCService_HuanhunMishu = function(serviceID, npcID)
  local nowSec = GetServerTime()
  local enddingSec = activityInterface._huanhunTimeLimit:ToNumber() / 1000
  local remainSec = enddingSec - nowSec
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__ACCEPT and remainSec >= 0 then
    local huanhun = require("Main.activity.ui.Huanhun").Instance()
    local myRoleID = _G.GetMyRoleID()
    local huanhunItemInfos = activityInterface._huanhunItemInfos
    huanhun:SetEnddingSec(activityInterface._huanhunTimeLimit:ToNumber() / 1000)
    huanhun:ShowDlg(myRoleID, huanhunItemInfos)
    return
  end
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__FINISH then
    local HuanhunPrize = require("Main.activity.ui.HuanhunPrize")
    HuanhunPrize.Instance():ShowDlg()
    return
  end
end
def.static("number", "number").OnNPCService_HuanhunNext = function(serviceID, npcID)
  local HuanhunNext = require("Main.activity.ui.HuanhunNext")
  HuanhunNext.Instance():ShowDlg()
end
def.static("number", "=>", "boolean").OnNPCService_LingQiFengYinRuleCondition = function(ServiceID)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_LingQiFengYinCondition = function(ServiceID)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    return false
  end
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  if serverLevelData.level < constant.LingQiFengYinConsts.LINGQIFENGYIN_SERVER_LEVEL_LIMIT then
    return false
  end
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_END then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_LingQiFengYinNextCondition = function(ServiceID)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    return false
  end
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_END then
    return true
  end
  return false
end
def.static("number", "number").OnNPCServive_LingQiFengYin = function(serviceID, npcID)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    Toast(textRes.activity.LingQiFengYinText[22])
    return
  end
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  warn("LingQiFengYinPanel Status:" .. activityInterface._lingqifengyinStatus)
  if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_INIT then
    warn("---Send Get Lingqifengyin Task")
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.massexp.CGetMassExpTask").new())
  elseif activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED then
    local LingQiFengYinPanel = require("Main.activity.ui.LingQiFengYinPanel")
    LingQiFengYinPanel.Instance():ShowDlg()
  end
end
def.static("number", "number").OnNPCServive_LingQiFengYinNext = function(serviceID, npcID)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    Toast(textRes.activity.LingQiFengYinText[22])
    return
  end
  if activityInterface._lingqifengyinEndTime == 0 then
    Toast(textRes.activity.LingQiFengYinText[22])
    return
  end
  local nowSec = GetServerTime()
  local remainSec = math.max(0, activityInterface._lingqifengyinEndTime - nowSec)
  local day = math.floor(remainSec / 86400)
  local hour = math.floor(remainSec % 86400 / 3600)
  local min = math.floor(remainSec % 3600 / 60)
  local sec = math.floor(remainSec % 60)
  Toast(string.format(textRes.activity.LingQiFengYinText[23], string.format(textRes.activity.LingQiFengYinText[24], day, hour, min, sec)))
end
def.static("number", "number", "number").OnNPCService_BaotuAdvancedExchange = function(serviceID, npcID, itemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local enough = true
  local itemMap = {}
  local fivePreciousItemCfg = ItemUtils.GetFivePreciousItemCfg(itemId)
  local allUUIDs = {}
  local exchangeItemID = fivePreciousItemCfg.exchangeid
  local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(exchangeItemID)
  for k, v in pairs(exchangeItemCfg.needItemList) do
    local uuids = {}
    local count = 0
    uuids, count = itemData:GetItemUUIDsByItemId(BagInfo.BAG, v.itemId, v.itemNum, uuids)
    if count < v.itemNum then
      enough = false
      itemMap[v.itemId] = v.itemNum
    end
    for k, v in pairs(uuids) do
      table.insert(allUUIDs, v.uuid)
    end
  end
  if enough == true then
    local p = require("netio.protocol.mzm.gsp.item.CExchangeUseItem").new(exchangeItemID, allUUIDs[1])
    gmodule.network.sendProtocol(p)
  elseif fivePreciousItemCfg.isuseyuanbao then
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local str = textRes.activity[111] .. "\n"
    local str2 = ""
    local itemIDs = {}
    for itemID, itemNum in pairs(itemMap) do
      local itemBase = ItemUtils.GetItemBase(itemID)
      str2 = str2 .. "[" .. HtmlHelper.NameColor[itemBase.namecolor] .. "]" .. itemBase.name .. "[-]x" .. itemNum .. " "
      table.insert(itemIDs, itemID)
    end
    activityInterface.npcExchangeItemId = fivePreciousItemCfg.id
    local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPrice").new(itemIDs)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.activity[396])
  end
end
def.static("number", "number").OnNPCService_BountyHunter = function(serviceID, npcID)
  local bountyHunter = require("Main.activity.ui.BountyHunter").Instance()
  bountyHunter:ShowDlg()
end
def.static("number", "number").OnNPCService_Convoy = function(serviceID, npcID)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local count = 0
  if activityInterface._husongMap ~= nil then
    count = activityInterface._husongMap[HuSongType.NORMAL] or 0
  end
  local activityCfg = ActivityInterface.GetActivityCfgById(constant.HuSongConsts.CONVOY_ACTIVITY_ID)
  if count >= activityCfg.recommendCount then
    Toast(string.format(textRes.activity[250], activityCfg.recommendCount))
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == true then
    Toast(textRes.activity[252])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local silver = itemModule:GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local needSilver = 0
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CHuSongMoneyCfg)
  local recordsCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, recordsCount - 1 do
    while true do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.levelMax = entry:GetIntValue("levelMax")
      cfg.levelMin = entry:GetIntValue("levelMin")
      cfg.HuSongType = entry:GetIntValue("HuSongType")
      if cfg.HuSongType == HuSongType.NORMAL and cfg.levelMax >= heroProp.level and heroProp.level >= cfg.levelMin then
        needSilver = entry:GetIntValue("needSilver")
      end
      break
    end
    if needSilver ~= 0 then
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if silver:lt(needSilver) then
    Toast(textRes.activity[260])
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[253], string.format(textRes.activity[261], needSilver), ActivityModule.OnConvoyConfirm, {})
end
def.static("number", "table").OnConvoyConfirm = function(id, tag)
  if id == 1 then
    local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
    local p = require("netio.protocol.mzm.gsp.activity.CHuSongReq").new(HuSongType.NORMAL)
    gmodule.network.sendProtocol(p)
  end
end
def.static("number", "number").OnNPCService_Special_Convoy = function(serviceID, npcID)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local count = 0
  if activityInterface._husongMap ~= nil then
    count = activityInterface._husongMap[HuSongType.SPECIAL] or 0
  end
  if count >= constant.HuSongConsts.CONVOY_SPECIALNUM then
    Toast(string.format(textRes.activity[251], constant.HuSongConsts.CONVOY_SPECIALNUM))
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == true then
    Toast(textRes.activity[252])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local silver = itemModule:GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local needSilver = 0
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CHuSongMoneyCfg)
  local recordsCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, recordsCount - 1 do
    while true do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.levelMax = entry:GetIntValue("levelMax")
      cfg.levelMin = entry:GetIntValue("levelMin")
      cfg.HuSongType = entry:GetIntValue("HuSongType")
      if cfg.HuSongType == HuSongType.SPECIAL and cfg.levelMax >= heroProp.level and heroProp.level >= cfg.levelMin then
        needSilver = entry:GetIntValue("needSilver")
      end
      break
    end
    if needSilver ~= 0 then
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if silver:lt(needSilver) then
    Toast(textRes.activity[260])
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[253], string.format(textRes.activity[261], needSilver), ActivityModule.OnConvoySpecialConfirm, {})
end
def.static("number", "table").OnConvoySpecialConfirm = function(id, tag)
  if id == 1 then
    local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
    local p = require("netio.protocol.mzm.gsp.activity.CHuSongReq").new(HuSongType.SPECIAL)
    gmodule.network.sendProtocol(p)
  end
end
def.static("number", "number").OnNPCService_Special_Convoy_Introduction = function(serviceID, npcID)
  local contents = {}
  local content = {}
  content.npcid = npcID
  content.txt = textRes.activity[254]
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("number", "number").OnNPCService_ShareQQ = function(serviceID, npcID)
  local succeed = DungeonModu.Instance():IsSingleDungeonAnyFinish()
  if succeed == false then
    Toast(textRes.activity[300])
    return
  else
    require("Main.Activity.ui.ShareAward").Instance():ShowDlg(343900001)
  end
end
def.static("number", "number").OnNPCService_GangTask = function(serviceID, npcID)
  local gangId = require("Main.Gang.GangModule").Instance().data:GetGangId()
  if not gangId then
    Toast(textRes.Gang[45])
    return
  end
  if taskInterface:HasTaskByGraphID(constant.GangTaskConsts.TASK_GRAPH_ID, true, true, true) == true then
    Toast(textRes.activity[149])
  end
  local p = require("netio.protocol.mzm.gsp.activity.CJoinGangTaskeReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "=>", "boolean").OnNPCService_GangTaskCondition = function(ServiceID)
  if taskInterface:HasTaskByGraphID(constant.GangTaskConsts.TASK_GRAPH_ID, true, true, true) == true then
    return false
  end
  return true
end
def.static("number", "number").OnNPCService_SeasonSingle = function(serviceID, npcID)
  if taskInterface:isOwnTaskByGraphId(constant.SeasonSingleConsts.TASK_GRAPH_ID) then
    Toast(textRes.activity[389])
    return
  end
  if not ActivityInterface.CheckActivityConditionFinishCount(constant.SeasonSingleConsts.ACTIVITYID) then
    Toast(textRes.activity[388])
    return
  end
  if ActivityInterface.CheckActivityConditionTeamMemberCount(constant.SeasonSingleConsts.ACTIVITYID, true) == false then
    return
  end
  local p = require("netio.protocol.mzm.gsp.activity.CJoinSingleSeasonTaskReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").OnNPCService_SeasonMulti = function(serviceID, npcID)
  if taskInterface:isOwnTaskByGraphId(constant.SeasonMultiConsts.TASK_GRAPH_ID) then
    Toast(textRes.activity[389])
    return
  end
  local p = require("netio.protocol.mzm.gsp.activity.CJoinMultiSeasonTaskReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").OnNPCService_ZhongQiu = function(serviceID, npcID)
  warn("<---------OnNPCService_ZhongQiu---------->")
  local p = require("netio.protocol.mzm.gsp.activity.CJoinTmpTaskReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table", "=>", "string").OnNPCService_Convoy_Modifiy = function(serviceCfg)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local activityCfg = ActivityInterface.GetActivityCfgById(constant.HuSongConsts.CONVOY_ACTIVITY_ID)
  local count = 0
  if activityInterface._husongMap ~= nil then
    count = activityInterface._husongMap[HuSongType.NORMAL] or 0
  end
  local ret = serviceCfg.choiceName .. "(" .. count .. "/" .. activityCfg.recommendCount .. ")"
  return ret
end
def.static("table", "=>", "string").OnNPCService_Special_Convoy_Modifiy = function(serviceCfg)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local count = 0
  if activityInterface._husongMap ~= nil then
    count = activityInterface._husongMap[HuSongType.SPECIAL] or 0
  end
  local ret = serviceCfg.choiceName .. "(" .. count .. "/" .. constant.HuSongConsts.CONVOY_SPECIALNUM .. ")"
  return ret
end
def.static("number", "=>", "boolean").OnNPCService_Special_Convoy_Condition = function(ServiceID)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local count = 0
  if activityInterface._husongMap ~= nil then
    count = activityInterface._husongMap[HuSongType.NORMAL] or 0
  end
  local activityCfg = ActivityInterface.GetActivityCfgById(constant.HuSongConsts.CONVOY_ACTIVITY_ID)
  return count >= activityCfg.recommendCount
end
def.static("number", "=>", "boolean").OnNpcServer_Zhenyao_Des_Condition = function(serviceId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpenFiftyAward = feature:CheckFeatureOpen(Feature.TYPE_ZHENYAO_FIFTY_AWARD)
  if serviceId == constant.ZhenYaoActivityCfgConsts.ZhenYao_DEC_SERVICE1 then
    return not isOpenFiftyAward
  elseif serviceId == constant.ZhenYaoActivityCfgConsts.ZhenYao_DEC_SERVICE2 then
    return isOpenFiftyAward
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_SeasonSingleCondition = function(serviceId)
  if serviceId == constant.SeasonSingleConsts.NPC_SERVICE then
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SUMMER_SINGLE) then
      return true
    else
      return false
    end
  end
  return true
end
def.static("number", "number", "=>", "boolean").OnNPCService_Luanshiyaomo = function(serviceID, NPCID)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DEAMON_TRANSFER_MAP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local highLevel = DynamicRecord.GetIntValue(entry, "highLevel")
    local lowLevel = DynamicRecord.GetIntValue(entry, "lowLevel")
    local mapId = DynamicRecord.GetIntValue(entry, "mapId")
    local npcid = DynamicRecord.GetIntValue(entry, "npcid")
    local serviceid = DynamicRecord.GetIntValue(entry, "npcServiceid")
    local skyNpcid = DynamicRecord.GetIntValue(entry, "skyNpcid")
    local skyServiceid = DynamicRecord.GetIntValue(entry, "skyNpcServiceid")
    if serviceid == serviceID and npcid == NPCID or skyServiceid == serviceID and skyNpcid == NPCID then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.activity.CLuanShiYaoMoNpcFight").new(npcID, serviceID))
      return true
    end
  end
  return false
end
def.static("table", "table").onMainUIReady = function(p1, p2)
  for _, v in pairs(activityInterface._activityInfos) do
    activityInterface:displayActivityTip(v.actvityId, false)
  end
end
def.method("number", "function").RegisterActivityTipFunc = function(self, activityId, func)
  activityInterface._activityTipFunc = activityInterface._activityTipFunc or {}
  activityInterface._activityTipFunc[activityId] = func
end
def.method("number", "function").RegisterActivityTipFuncEx = function(self, activityId, func)
  activityInterface._activityTipFuncEx = activityInterface._activityTipFuncEx or {}
  activityInterface._activityTipFuncEx[activityId] = func
end
def.static("table", "table").onSynServerLevel = function(p1, p2)
  if activityInterface then
    activityInterface:RefreshActivityList()
    activityInterface:refreshActivityTimer()
  end
end
def.static("table", "table").OnAddBuff = function(p1, p2)
  warn("------add online award buff:", p1[1])
  if p1 and p1[1] and p1[1] == constant.OnlineTreasureBoxActivityConst.activityAwardBuffId then
    Toast(textRes.activity[373])
  end
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  local shimenConst = constant.ShimenActivityCfgConsts
  if p1[2] == shimenConst.EXCHANGE_NPC_ID then
    do
      local itemData = require("Main.Item.ItemData").Instance()
      local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local count = itemData:GetNumByItemType(BagInfo.BAG, ItemType.MOSHOU_LIN_SHI_ITEM)
      if p1[1] == shimenConst.EXCHANGE_MOSHOU_NPC_SERVICE then
        if not activityInterface._canExchangeMoshou then
          Toast(textRes.activity[378])
          return
        end
        local needNum = shimenConst.EXCHANGE_MOSHOU_REWARD_NEED_ITEM_NUM
        if count < needNum then
          Toast(textRes.activity[376])
          return
        end
        local function callback(id)
          if id == 1 then
            local itemKey, item = itemData:SelectOneItemByItemType(BagInfo.BAG, ItemType.MOSHOU_LIN_SHI_ITEM)
            local req = require("netio.protocol.mzm.gsp.item.CUseMoshuFragmentReq").new(item.id, 0)
            gmodule.network.sendProtocol(req)
          end
        end
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.activity[375], needNum), callback, {})
      elseif p1[1] == shimenConst.EXCHANGE_NORMAL_NPC_SERVICE then
        if count < shimenConst.EXCHANGE_NORMAL_REWARD_NEED_ITEM_NUM then
          Toast(textRes.activity[376])
          return
        end
        local itemKey, item = itemData:SelectOneItemByItemType(BagInfo.BAG, ItemType.MOSHOU_LIN_SHI_ITEM)
        local req = require("netio.protocol.mzm.gsp.item.CUseMoshuFragmentReq").new(item.id, 1)
        gmodule.network.sendProtocol(req)
      end
    end
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  warn("-----activity:OnEnterWorld")
  activityInterface:initAllActivitTimer()
  thumbsupMgr:Init()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  thumbsupMgr:OnLeaveWorld()
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.BountyConsts.BOUNTYHUNTER_ACTIVITYID then
    activityInterface._bountyCount = 0
    local bountyHunter = require("Main.activity.ui.BountyHunter").Instance()
    if bountyHunter:IsShow() then
      bountyHunter:Fill()
    end
  elseif activityId == constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID then
    activityInterface._huanhunGangHelpInfo = {}
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, {isAdd = false})
  end
end
def.static("table", "table").OnSetActivityRedPoint = function(p1, p2)
  if p1.activityId then
    activityInterface.activityRedPoint[p1.activityId] = p1.isShowRedPoint
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, {})
  end
end
def.static("number").OnLuanshiYaomoActivityInfoChange = function(activityId)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AUTO_LUAN_SHI_YAO_MO) then
    local teamData = require("Main.Team.TeamData").Instance()
    if teamData:HasTeam() then
      local idx = teamData:GetMemberIndex(_G.GetMyRoleID())
      if idx ~= 1 then
        return
      end
    end
    local activityInfo = activityInterface:GetActivityInfo(activityId)
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    if activityInfo.count < activityCfg.recommendCount then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local dlg = CommonConfirmDlg.ShowConfirmCoundDown("", textRes.activity[406], "", "", 1, 3, function(selection, tag)
        if selection == 1 then
          local npcId = ActivityModule.GetLuanShiYaoMoNpcId()
          if npcId > 0 then
            if npcInterface:isInNpcNear(npcId) then
              gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.activity.CLuanShiYaoMoNpcFight").new())
            else
              instance._isAutoLuanShiYaoMo = true
              ActivityModule.OnActivity_LuanshiYaomo(activityId)
            end
          else
            Toast(textRes.activity[361])
          end
        end
      end, nil)
    end
  else
    warn("--------luan shi yao mo IDIP is closed")
  end
end
def.static("table", "table").OnFindpathFinished = function(p1, p2)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AUTO_LUAN_SHI_YAO_MO) and instance and instance._isAutoLuanShiYaoMo then
    instance._isAutoLuanShiYaoMo = false
    local activityId = constant.DeamonFight.LUANSHI_ACTIVITYID
    local activityInfo = activityInterface:GetActivityInfo(activityId)
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    if activityInfo.count < activityCfg.recommendCount then
      GameUtil.AddGlobalTimer(0.5, true, function()
        local dlg = require("Main.npc.ui.NPCDlg").Instance()
        if dlg:IsShow() == true then
          dlg:onClick("Btn_01")
        else
          warn("------NPCDlg not show------")
        end
      end)
    end
  end
end
def.static("table", "table").OnFindpathCanceled = function(p1, p2)
  if instance then
    instance._isAutoLuanShiYaoMo = false
  end
end
def.static("table", "table").OnNPCDlgShown = function(p1, p2)
  if instance and instance._isAutoLuanShiYaoMo then
    local npcId = ActivityModule.GetLuanShiYaoMoNpcId()
    warn("-------------OnNPCDlgShown:", p1[1], npcId)
    if p1[1] and npcId == p1[1] then
      if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AUTO_LUAN_SHI_YAO_MO) then
        instance._isAutoLuanShiYaoMo = false
        local activityId = constant.DeamonFight.LUANSHI_ACTIVITYID
        local activityInfo = activityInterface:GetActivityInfo(activityId)
        local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
        if activityInfo.count < activityCfg.recommendCount then
          GameUtil.AddGlobalTimer(0.5, true, function()
            local dlg = require("Main.npc.ui.NPCDlg").Instance()
            if dlg:IsShow() == true then
              dlg:onClick("Btn_01")
            else
              warn("------NPCDlg not show------")
            end
          end)
        end
      end
    else
      instance._isAutoLuanShiYaoMo = false
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SUMMER_SINGLE) then
    activityInterface:removeCustomCloseActivity(constant.SeasonSingleConsts.ACTIVITYID)
  else
    activityInterface:addCustomCloseActivity(constant.SeasonSingleConsts.ACTIVITYID)
  end
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  if IsFeatureOpen(ModuleFunSwitchInfo.TYPE_COMMON_FEN_XIANG_YOU_LI) then
    activityInterface:removeCustomCloseActivity(RelationShipChainMgr.SHAREACTIVIEID)
  else
    activityInterface:addCustomCloseActivity(RelationShipChainMgr.SHAREACTIVIEID)
  end
  if _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_HALLOWEEN_VISIBLE_MONSTER_ACTIVITY) then
    activityInterface:removeCustomCloseActivity(constant.CHalloweenConst.activity_cfg_id)
  else
    activityInterface:addCustomCloseActivity(constant.CHalloweenConst.activity_cfg_id)
  end
  local singTaskCfgs = ActivityInterface.GetSingleTaskAllCfgs()
  for i, v in pairs(singTaskCfgs) do
    if v.openId > 0 then
      if IsFeatureOpen(v.openId) then
        activityInterface:removeCustomCloseActivity(v.activityId)
      else
        activityInterface:addCustomCloseActivity(v.activityId)
      end
      npcInterface:RegisterNPCServiceCustomCondition(v.serviceid, ActivityModule.OnNPCService_SingleTaskCondition)
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local openId = ModuleFunSwitchInfo.TYPE_SUMMER_SINGLE
  if p1.feature == openId then
    if IsFeatureOpen(openId) then
      activityInterface:removeCustomCloseActivity(constant.SeasonSingleConsts.ACTIVITYID)
    else
      activityInterface:addCustomCloseActivity(constant.SeasonSingleConsts.ACTIVITYID)
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_COMMON_FEN_XIANG_YOU_LI then
    local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
    if IsFeatureOpen(openId) then
      activityInterface:removeCustomCloseActivity(RelationShipChainMgr.SHAREACTIVIEID)
    else
      activityInterface:addCustomCloseActivity(RelationShipChainMgr.SHAREACTIVIEID)
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_HALLOWEEN_VISIBLE_MONSTER_ACTIVITY then
    if _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_HALLOWEEN_VISIBLE_MONSTER_ACTIVITY) then
      activityInterface:removeCustomCloseActivity(constant.CHalloweenConst.activity_cfg_id)
    else
      activityInterface:addCustomCloseActivity(constant.CHalloweenConst.activity_cfg_id)
    end
  end
  local singTaskCfgs = ActivityInterface.GetSingleTaskAllCfgs()
  for i, v in pairs(singTaskCfgs) do
    if v.openId > 0 and p1.feature == v.openId then
      if IsFeatureOpen(v.openId) then
        activityInterface:removeCustomCloseActivity(v.activityId)
      else
        activityInterface:addCustomCloseActivity(v.activityId)
      end
    end
  end
end
def.static("number", "=>", "boolean").OnNPCService_SingleTaskCondition = function(serviceId)
  local singleTaskCfg = ActivityInterface.GetSingleTaskCfgByServiceId(serviceId)
  if singleTaskCfg and singleTaskCfg.openId > 0 then
    if IsFeatureOpen(singleTaskCfg.openId) then
      return true
    else
      return false
    end
  end
  return true
end
ActivityModule.Commit()
return ActivityModule
