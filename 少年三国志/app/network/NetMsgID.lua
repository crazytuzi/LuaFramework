NetMsg_ID =  {

  --网关中的协议
  ID_C2S_KeepAlive = 10000,
  ID_S2C_KeepAlive = 10001,
  ID_C2S_Login = 10002,
  ID_S2C_Login = 10003,
  ID_C2S_Create = 10004,
  ID_S2C_Create = 10005,
  ID_C2S_Offline = 10009,
  ID_C2S_GetServerTime = 10011,
  ID_S2C_GetServerTime = 10012,

  ID_C2S_Flush = 10006,
  ID_S2C_Flush = 10007,
  ID_S2C_GetUser = 10008,
  ID_S2C_GetKnight = 10010,

  ID_C2S_TestBattle = 10013,
  ID_S2C_TestBattle = 10014,

  ID_S2C_FightKnight = 10016,
  ID_C2S_ChangeFormation = 10017,
  ID_S2C_ChangeFormation = 10018,
  ID_C2S_ChangeTeamKnight = 10019,
  ID_S2C_ChangeTeamKnight = 10020,
  ID_C2S_AddTeamKnight = 10021,
  ID_S2C_AddTeamKnight = 10022,
  ID_S2C_GetItem = 10023,
  ID_S2C_GetFragment = 10024,
  ID_C2S_Shopping = 10025,
  ID_S2C_Shopping = 10026,
  ID_C2S_UseItem = 10027,
  ID_S2C_UseItem = 10028,
  ID_S2C_GetEquipment = 10029,
  ID_C2S_EnterShop = 10030,
  ID_S2C_EnterShop = 10031,
  ID_S2C_OpObject = 10032,
  ID_C2S_Sell = 10033,
  ID_S2C_Sell = 10034,
  ID_C2S_FragmentCompound = 10035,
  ID_S2C_FragmentCompound = 10036,
  ID_C2S_MysticalShopInfo = 10037,
  ID_S2C_MysticalShopInfo = 10038,
  ID_C2S_MysticalShopRefresh = 10039,
  ID_S2C_MysticalShopRefresh = 10040,
  ID_S2C_GetTreasureFragment = 10041,
  ID_S2C_GetTreasure = 10042,
  ID_S2C_FightResource = 10043,
  ID_C2S_AddFightEquipment = 10044,
  ID_S2C_AddFightEquipment = 10045,
  ID_C2S_ClearFightEquipment = 10046,
  ID_S2C_ClearFightEquipment = 10047,
  ID_C2S_AddFightTreasure = 10048,
  ID_S2C_AddFightTreasure = 10049,
  ID_C2S_ClearFightTreasure = 10050,
  ID_S2C_ClearFightTreasure = 10051,
  ID_C2S_GiftCode = 10052,
  ID_S2C_GiftCode = 10053,
  ID_S2C_RollNotice = 10054, --跑马灯公告
  ID_S2C_HOF_Points = 10055,
  ID_S2C_GetAwakenItem = 10056,
  ID_C2S_AwakenShopInfo = 10057,
  ID_S2C_AwakenShopInfo = 10058,
  ID_C2S_AwakenShopRefresh = 10059,
  ID_S2C_AwakenShopRefresh = 10060,
  ID_C2S_GetTencentReward = 10061, --获取腾讯应用宝礼包
  ID_C2S_ChangeTitle = 10062, --装备称号
  ID_S2C_ChangeTitle = 10063,
  ID_C2S_UpdateFightValue = 10064, --更新玩家战斗力数据(重算战斗力)
  ID_C2S_FragmentSale = 10065,
  ID_S2C_FragmentSale = 10066,
  ID_C2S_ItemCompose = 10067,
  ID_S2C_ItemCompose = 10068,
  ID_C2S_ChangeName = 10069,
  ID_S2C_ChangeName = 10070,

  --聊天
  ID_C2S_ChatRequest = 10100,
  ID_S2C_ChatRequest = 10101,
  ID_S2C_Chat = 10102,
  ID_S2C_Notify = 10103,

  --好友
  ID_C2S_GetFriendList = 10200,
  ID_S2C_GetFriendList = 10201,
  ID_C2S_GetFriendReqList = 10202,
  ID_S2C_GetFriendReqList = 10203,
  ID_C2S_RequestAddFriend = 10204,
  ID_S2C_RequestAddFriend  = 10205,
  ID_C2S_RequestDeleteFriend = 10206,
  ID_S2C_RequestDeleteFriend = 10207,
  ID_C2S_ConfirmAddFriend = 10208,
  ID_S2C_ConfirmAddFriend = 10209,
  ID_C2S_FriendPresent = 10210,
  ID_S2C_FriendPresent = 10211,
  ID_C2S_GetFriendPresent = 10212,
  ID_S2C_GetFriendPresent = 10213,
  ID_C2S_GetPlayerInfo = 10214,
  ID_S2C_GetPlayerInfo = 10215,
  ID_S2C_AddFriendRespond = 10216,
  ID_C2S_ChooseFriend = 10217,
  ID_S2C_ChooseFriend = 10218,
  ID_C2S_GetFriendsInfo = 10219,
  ID_S2C_GetFriendsInfo = 10220,
  ID_C2S_KillFriend = 10221,
  ID_S2C_KillFriend = 10222,
  ID_S2C_DelFriend = 10223,

  --主线副本
  ID_C2S_GetChapterList = 10300,
  ID_S2C_GetChapterList = 10301,
  --ID_C2S_GetStageList = 10302,
  --ID_S2C_GetStageList = 10303,
  ID_C2S_GetChapterRank = 10304,
  ID_S2C_GetChapterRank = 10305,
  ID_S2C_AddStage = 10306,
  ID_C2S_ExecuteStage  = 10307,
  ID_S2C_ExecuteStage  = 10308,
  ID_C2S_FastExecuteStage  = 10309,
  ID_S2C_FastExecuteStage  = 10310,
  ID_C2S_ChapterAchvRwdInfo  = 10311,--副本星数奖励信息
  ID_S2C_ChapterAchvRwdInfo  = 10312,
  ID_C2S_FinishChapterAchvRwd  = 10313,--获取星星成就奖励
  ID_S2C_FinishChapterAchvRwd  = 10314,
  ID_C2S_FinishChapterBoxRwd  = 10315,--获取箱子奖励
  ID_S2C_FinishChapterBoxRwd  = 10316,
  ID_C2S_ResetDungeonExecution = 10317,--重置副本次数
  ID_S2C_ResetDungeonExecution = 10318,
  ID_C2S_ResetDungeonFastTimeCd = 10319,--重置秒杀时间
  ID_S2C_ResetDungeonFastTimeCd = 10320,
  ID_S2C_ExecuteMultiStage = 10321,--副本战斗多战报协议
  ID_C2S_ExecuteMultiStage = 10322,
  ID_S2C_FirstEnterChapter = 10323,--第一次进入设置TAG
  ID_C2S_FirstEnterChapter = 10324,

  --竞技场
  ID_C2S_GetArenaInfo = 10400,--获取竞技场信息
  ID_S2C_GetArenaInfo = 10401,
  ID_C2S_ChallengeArena = 10402,--挑战竞技场
  ID_S2C_ChallengeArena = 10403,
  ID_C2S_GetArenaTopInfo = 10404,--获取竞技场排行榜
  ID_S2C_GetArenaTopInfo = 10405,
  ID_C2S_GetArenaUserInfo = 10406,--获取竞技场排行榜
  ID_S2C_GetArenaUserInfo = 10407,

  --闯关
  ID_C2S_TowerInfo = 10500,
  ID_S2C_TowerInfo = 10501,
  ID_C2S_TowerChallenge = 10502,
  ID_S2C_TowerChallenge = 10503,
  ID_C2S_TowerStartCleanup = 10504,
  ID_S2C_TowerStartCleanup = 10505,
  ID_C2S_TowerStopCleanup = 10506,
  ID_S2C_TowerStopCleanup = 10507,
  ID_C2S_TowerReset = 10508,
  ID_S2C_TowerReset = 10509,
  ID_C2S_TowerGetBuff = 10510,
  ID_S2C_TowerGetBuff = 10511,
  ID_C2S_TowerRfBuff = 10512,
  ID_S2C_TowerRfBuff = 10513,
  ID_C2S_TowerRequestReward = 10514,
  ID_S2C_TowerRequestReward = 10515,
  ID_C2S_TowerRankingList = 10516,
  ID_S2C_TowerRankingList = 10517,
  ID_C2S_TowerChallengeGuide = 10518,
  ID_S2C_TowerChallengeGuide = 10519,

  --邮件
  ID_S2C_GetSimpleMail = 10600,
  ID_S2C_AddSimpleMail = 10601,
  ID_S2C_GetNewMailCount = 10602,
  ID_C2S_GetMail = 10603,
  ID_S2C_GetMail = 10604,--普通邮件
  ID_S2C_GetGiftMailCount = 10605,
  ID_C2S_GetGiftMail = 10606,
  ID_S2C_GetGiftMail = 10607,
  ID_C2S_ProcessGiftMail = 10608,
  ID_S2C_ProcessGiftMail = 10609,
  ID_C2S_TestMail= 10610,
  ID_C2S_Mail= 10611,
  ID_S2C_Mail= 10612,

  --抽卡
  ID_C2S_RecruitInfo = 10700,
  ID_S2C_RecruitInfo = 10701,
  ID_C2S_RecruitLp = 10702,
  ID_S2C_RecruitLp = 10703,
  ID_C2S_RecruitLpTen = 10704,
  ID_S2C_RecruitLpTen = 10705,
  ID_C2S_RecruitJp = 10706,
  ID_S2C_RecruitJp = 10707,
  ID_C2S_RecruitJpTen = 10708,
  ID_S2C_RecruitJpTen = 10709,
  ID_C2S_RecruitJpTw = 10710,
  ID_S2C_RecruitJpTw = 10711,
  ID_C2S_RecruitZy = 10712,
  ID_S2C_RecruitZy = 10713,

  --技能树
  ID_C2S_GetSkillTree = 10800,
  ID_S2C_GetSkillTree = 10801,
  ID_C2S_LearnSkill = 10802,--学习和升级都用这条协议
  ID_S2C_LearnSkill = 10803,
  ID_C2S_ResetSkill= 10804,
  ID_S2C_ResetSkill = 10805,
  ID_C2S_PlaceSkill= 10806,
  ID_S2C_PlaceSkill = 10807,

  --剧情副本
  ID_C2S_GetStoryList = 10900,
  ID_S2C_GetStoryList = 10901,
  ID_C2S_ExecuteBarrier = 10902,
  ID_S2C_ExecuteBarrier = 10903,
  ID_C2S_FastExecuteBarrier = 10904,
  ID_S2C_FastExecuteBarrier = 10905,
  ID_C2S_SanguozhiAwardInfo = 10906,
  ID_S2C_SanguozhiAwardInfo = 10907,
  ID_C2S_FinishSanguozhiAward = 10908,
  ID_S2C_FinishSanguozhiAward = 10909,
  ID_C2S_ResetStoryFastTimeCd = 10910,--重置秒杀时间
  ID_S2C_ResetStoryFastTimeCd = 10911,
  ID_S2C_AddStoryDungeon = 10912,--新增剧情副本
  ID_C2S_SetStoryTag = 10913,
  ID_S2C_SetStoryTag = 10914,
  ID_C2S_GetBarrierAward = 10915,
  ID_S2C_GetBarrierAward = 10916,

  -- 武将养成
  ID_C2S_UpgradeKnight = 11000,--武将强化
  ID_S2C_UpgradeKnight = 11001,
  ID_C2S_AdvancedKnight = 11002,--武将升阶
  ID_S2C_AdvancedKnight = 11003,
  ID_C2S_TrainingKnight = 11004,--武将历练
  ID_S2C_TrainingKnight = 11005,
  ID_C2S_SaveTrainingKnight = 11006,--保存武将历练
  ID_S2C_SaveTrainingKnight = 11007,
  ID_C2S_GiveupTrainingKnight = 11008,--放弃武将历练
  ID_S2C_GiveupTrainingKnight = 11009,
  ID_C2S_RecycleKnight = 11010,--武将回收
  ID_S2C_RecycleKnight = 11011,
  ID_C2S_UpgradeKnightHalo = 11012,--升级武将光环
  ID_S2C_UpgradeKnightHalo = 11013,

  ID_C2S_GetKnightAttr = 11014,--获取武将一级属性(仅供开发测试使用)
  ID_S2C_GetKnightAttr = 11015,
  ID_C2S_KnightTransform = 11016,--武将回收
  ID_S2C_KnightTransform = 11017,
  ID_C2S_KnightOrangeToRed = 11018, -- 武将橙色升红色
  ID_S2C_KnightOrangeToRed = 11019,


  --装备养成
  ID_C2S_UpgradeEquipment = 12000,--强化装备
  ID_S2C_UpgradeEquipment = 12001,
  ID_C2S_RefiningEquipment = 12002,--精炼装备
  ID_S2C_RefiningEquipment = 12003,
  ID_C2S_RecycleEquipment = 12004,--分解装备
  ID_S2C_RecycleEquipment = 12005,
  ID_C2S_RebornEquipment = 12006,--装备重生
  ID_S2C_RebornEquipment = 12007,
  ID_C2S_UpStarEquipment = 12008, --升星装备
  ID_S2C_UpStarEquipment = 12009,
  ID_C2S_FastRefineEquipment = 12010, --一键神练
  ID_S2C_FastRefineEquipment = 12011,

  --图鉴
  ID_C2S_GetHandbookInfo = 12100,
  ID_S2C_GetHandbookInfo = 12101,

  --叛军
  ID_S2C_GetRebel = 12200,
  ID_C2S_EnterRebelUI = 12201,
  ID_S2C_EnterRebelUI = 12202,
  ID_C2S_AttackRebel = 12203,
  ID_S2C_AttackRebel = 12204,
  ID_C2S_PublicRebel = 12205,
  ID_S2C_PublicRebel = 12206,
  ID_C2S_RebelRank = 12207,
  ID_S2C_RebelRank = 12208,
  ID_C2S_MyRebelRank = 12209,
  ID_S2C_MyRebelRank = 12210,
  ID_C2S_RefreshRebel = 12211,
  ID_S2C_RefreshRebel = 12212,
  ID_C2S_GetExploitAward = 12215,
  ID_S2C_GetExploitAward = 12216,
  ID_C2S_GetExploitAwardType = 12217,
  ID_S2C_GetExploitAwardType = 12218,
  ID_C2S_RefreshRebelShow = 12221,
  ID_S2C_RefreshRebelShow = 12222,

  --宝物系统
  ID_C2S_GetTreasureFragmentRobList = 12300,--获取宝物碎片抢夺列表
  ID_S2C_GetTreasureFragmentRobList = 12301,
  ID_C2S_RobTreasureFragment = 12302,--抢夺宝物碎片
  ID_S2C_RobTreasureFragment = 12303,
  ID_C2S_UpgradeTreasure = 12304,--强化宝物
  ID_S2C_UpgradeTreasure = 12305,
  ID_C2S_RefiningTreasure = 12306,--精炼宝物
  ID_S2C_RefiningTreasure = 12307,
  ID_C2S_ComposeTreasure = 12308,--合成宝物
  ID_S2C_ComposeTreasure = 12309,
  ID_C2S_TreasureFragmentForbidBattle = 12310,--使用免战牌
  ID_S2C_TreasureFragmentForbidBattle = 12311,
  ID_C2S_RecycleTreasure = 12312,--宝物重生
  ID_S2C_RecycleTreasure = 12313,
  ID_C2S_FastRobTreasureFragment = 12314,--5次夺宝
  ID_S2C_FastRobTreasureFragment = 12315,
  ID_C2S_TreasureSmelt = 12316,     --宝物熔炼
  ID_S2C_TreasureSmelt = 12317,
  ID_C2S_TreasureForge = 12318,     --宝物铸造
  ID_S2C_TreasureForge = 12319,
  ID_C2S_OneKeyRobTreasureFragment = 12320,	--一键夺宝
  ID_S2C_OneKeyRobTreasureFragment = 12321,	

  --新手引导
  ID_C2S_GetGuideId = 12400,
  ID_S2C_GetGuideId = 12401,
  ID_C2S_SaveGuideId = 12402,
  ID_S2C_SaveGuideId = 12403,

  --VIP副本
  ID_C2S_GetVip = 12500,
  ID_S2C_GetVip = 12501,
  ID_C2S_ExecuteVipDungeon = 12502,
  ID_S2C_ExecuteVipDungeon = 12503,
  ID_C2S_ResetVipDungeonCount = 12504,
  ID_S2C_ResetVipDungeonCount = 12505,

  -- 喝酒
  ID_C2S_LiquorInfo = 12600,
  ID_S2C_LiquorInfo = 12601,
  ID_C2S_Drink = 12602,
  ID_S2C_Drink = 12603,

  --充值相关
  ID_C2S_GetRecharge = 12700,
  ID_S2C_GetRecharge = 12701,
  ID_C2S_UseMonthCard = 12702,
  ID_S2C_UseMonthCard = 12703,
  ID_S2C_RechargeSuccess = 12704,
  ID_C2S_GetRechargeBonus = 12705,
  ID_S2C_GetRechargeBonus= 12706,

  -- 关公
  ID_C2S_MrGuanInfo = 12800,
  ID_S2C_MrGuanInfo = 12801,
  ID_C2S_Worship = 12802,
  ID_S2C_Worship = 12803,

  -- 登陆奖励
  ID_C2S_LoginRewardInfo = 12900,
  ID_S2C_LoginRewardInfo = 12901,
  ID_C2S_LoginReward = 12902,
  ID_S2C_LoginReward = 12903,

  --每日任务
  ID_C2S_GetDailyMission = 13000,
  ID_S2C_GetDailyMission = 13001,
  ID_C2S_FinishDailyMission = 13002,
  ID_S2C_FinishDailyMission = 13003,
  ID_C2S_GetDailyMissionAward = 13004,
  ID_S2C_GetDailyMissionAward = 13005,
  ID_C2S_ResetDailyMission = 13006,
  ID_S2C_ResetDailyMission = 13007,
  ID_S2C_FlushDailyMission = 13008,

  -- 无双
  ID_C2S_WushInfo = 13100,
  ID_S2C_WushInfo = 13101,
  ID_C2S_WushGetBuff = 13102,
  ID_S2C_WushGetBuff = 13103,
  ID_C2S_WushChallenge = 13104,
  ID_S2C_WushChallenge = 13105,
  ID_C2S_WushReset = 13106,
  ID_S2C_WushReset = 13107,
  ID_C2S_WushRankingList = 13108,
  ID_S2C_WushRankingList = 13109,
  ID_C2S_WushApplyBuff = 13110,
  ID_S2C_WushApplyBuff = 13111,
  ID_C2S_WushBuy = 13112,
  ID_S2C_WushBuy = 13113,

  -- 目标系统
  ID_C2S_TargetInfo = 13200,
  ID_S2C_TargetInfo = 13201,
  ID_C2S_TargetGetReward = 13202,
  ID_S2C_TargetGetReward = 13203,

  --MAIN GROUTH
  ID_C2S_GetMainGrouthInfo = 13301,
  ID_S2C_GetMainGrouthInfo = 13302,
  ID_C2S_UseMainGrouthInfo = 13303,
  ID_S2C_UseMainGrouthInfo = 13304,

  --名人堂
  ID_C2S_HOF_UIInfo = 13400,
  ID_S2C_HOF_UIInfo = 13401,
  ID_C2S_HOF_Confirm = 13402,
  ID_S2C_HOF_Confirm = 13403,
  ID_C2S_HOF_Sign = 13404,
  ID_S2C_HOF_Sign = 13405,
  ID_C2S_HOF_RankInfo = 13406,
  ID_S2C_HOF_RankInfo = 13407,

  --开服基金
  ID_C2S_GetFundInfo = 13500, --获取全服基金购买信息
  ID_S2C_GetFundInfo = 13501,
  ID_C2S_GetUserFund = 13502, --获取个人基金信息
  ID_S2C_GetUserFund = 13503,
  ID_C2S_BuyFund = 13504, --购买基金
  ID_S2C_BuyFund = 13505,
  ID_C2S_GetFundAward = 13506, --领取基金奖励
  ID_S2C_GetFundAward = 13507,
  ID_C2S_GetFundWeal = 13508, --领取福利奖励
  ID_S2C_GetFundWeal = 13509,

  -- 城池挂机
  ID_C2S_CityInfo = 13600,
  ID_S2C_CityInfo = 13601,
  ID_C2S_CityAttack = 13602,
  ID_S2C_CityAttack = 13603,
  ID_C2S_CityPatrol = 13604,
  ID_S2C_CityPatrol = 13605,
  ID_C2S_CityReward = 13606,
  ID_S2C_CityReward = 13607,
  ID_C2S_CityAssist = 13608,
  ID_S2C_CityAssist = 13609,
  ID_C2S_CityCheck = 13610,
  ID_S2C_CityCheck = 13611,
  ID_S2C_CityAssisted = 13612,
  ID_C2S_CityOneKeyReward = 13613,
  ID_S2C_CityOneKeyReward = 13614,
  ID_C2S_CityOneKeyPatrol = 13615,
  ID_S2C_CityOneKeyPatrol = 13616,
  ID_C2S_CityOneKeyPatrolSet = 13617,
  ID_S2C_CityOneKeyPatrolSet = 13618,
  ID_C2S_CityTechUp = 13619,
  ID_S2C_CityTechUp = 13620,

  --可配置活动
  ID_C2S_GetCustomActivityInfo = 13700, --获取可配置活动信息
  ID_S2C_GetCustomActivityInfo = 13701,
  ID_S2C_UpdateCustomActivity = 13702, --更新可配置活动
  ID_S2C_UpdateCustomActivityQuest = 13703, --更新可配置活动任务
  ID_C2S_GetCustomActivityAward = 13704, --领取可配置活动奖励
  ID_S2C_GetCustomActivityAward = 13705,
  ID_S2C_UpdateCustomSeriesActivity = 13706, --更新系列活动
  ID_C2S_GetCustomSeriesActivity = 13707, --获取系列活动
  ID_S2C_GetCustomSeriesActivity = 13708,

  --节日活动
  ID_C2S_GetHolidayEventInfo = 13800,
  ID_S2C_GetHolidayEventInfo = 13801,
  ID_C2S_GetHolidayEventAward = 13802,
  ID_S2C_GetHolidayEventAward = 13803,

  --觉醒相关功能
  ID_C2S_ComposeAwakenItem = 13900, --道具合成
  ID_S2C_ComposeAwakenItem = 13901,
  ID_C2S_PutonAwakenItem = 13902, --装备觉醒道具
  ID_S2C_PutonAwakenItem = 13903,
  ID_C2S_AwakenKnight = 13904, --武将觉醒
  ID_S2C_AwakenKnight = 13905,
  ID_C2S_FastComposeAwakenItem = 13906, --一键道具合成
  ID_S2C_FastComposeAwakenItem = 13907,

  --开服七天活动
  ID_C2S_GetDaysActivityInfo = 14000,
  ID_S2C_GetDaysActivityInfo = 14001,
  ID_C2S_FinishDaysActivity = 14002,
  ID_S2C_FinishDaysActivity = 14003,
  ID_C2S_GetDaysActivitySell = 14004,
  ID_S2C_GetDaysActivitySell = 14005,
  ID_C2S_PurchaseActivitySell = 14006,
  ID_S2C_PurchaseActivitySell = 14007,
  ID_S2C_FlushDaysActivity = 14008,

  ID_C2S_UpgradeDress = 14100,
  ID_S2C_UpgradeDress = 14101,
  ID_S2C_GetDress = 14156,
  ID_C2S_AddFightDress = 14157,
  ID_S2C_AddFightDress = 14158,
  ID_C2S_ClearFightDress = 14159,
  ID_S2C_ClearFightDress = 14160,
  ID_C2S_RecycleDress = 14161,
  ID_S2C_RecycleDress = 14162,

	--微信分享
  ID_C2S_Share = 14200,
  ID_S2C_Share = 14201,
  ID_C2S_GetShareState = 14202,
  ID_S2C_GetShareState = 14203,
  ID_C2S_GetPhoneBindNotice = 14204,
  ID_S2C_GetPhoneBindNotice = 14205,

  --封测充值返还
  ID_C2S_GetRechargeBack = 14300,--查看是否有返还信息
  ID_S2C_GetRechargeBack = 14301,
  ID_C2S_RechargeBackGold = 14302,--领取返还元宝
  ID_S2C_RechargeBackGold = 14303,

  --军团 16000 - 17000 为军团 勿用
  --默认获取
  ID_C2S_GetCorpList = 16000,--获取军团列表
  ID_S2C_GetCorpList = 16001,
  ID_C2S_GetJoinCorpList = 16002,--获取玩家申请军团列表
  ID_S2C_GetJoinCorpList = 16003,
  ID_C2S_GetCorpDetail = 16004,--获取自身帮会信息 刷新自身帮会信息都通过这条
  ID_S2C_GetCorpDetail = 16005,
  ID_C2S_GetCorpMember = 16006,--获取军团成员信息
  ID_S2C_GetCorpMember= 16007,
  ID_C2S_GetCorpHistory= 16008,--获取军团动态
  ID_S2C_GetCorpHistory= 16009,
  ID_S2C_NotifyCorpDismiss = 16010,--军团解散消息
  --军团权利行为
  --以下为所有人的权利
  ID_C2S_CreateCorp = 16100,--创建帮会
  ID_S2C_CreateCorp = 16101,
  ID_C2S_RequestJoinCorp = 16102,--请求加入帮会
  ID_S2C_RequestJoinCorp = 16103,
  ID_C2S_DeleteJoinCorp = 16104,--删除加入帮会请求
  ID_S2C_DeleteJoinCorp = 16105,
  ID_C2S_QuitCorp = 16106,--退出帮会
  ID_S2C_QuitCorp = 16107,
  ID_C2S_SearchCorp = 16108,--查找帮会
  ID_S2C_SearchCorp = 16109,
  ID_C2S_ExchangeLeader = 16110,--弹劾军团长
  ID_S2C_ExchangeLeader = 16111,
  --以下为部分人的权利（军团长 副军团长）
  ID_C2S_ConfirmJoinCorp = 16200,--确认加入帮会
  ID_S2C_ConfirmJoinCorp = 16201,
  ID_C2S_ModifyCorp = 16202,--修改军团信息（内部公告，宣言，标识）
  ID_S2C_ModifyCorp = 16203,
  ID_C2S_DismissCorpMember = 16204,--踢人
  ID_S2C_DismissCorpMember = 16205,
  ID_C2S_GetCorpJoin= 16206,--查看军团申请
  ID_S2C_GetCorpJoin= 16207,
  ID_S2C_MyCorpChangedByCorpLeader = 16208,
  --军团长Only
  ID_C2S_DismissCorp = 16300,--解散帮会
  ID_S2C_DismissCorp = 16301,
  ID_C2S_CorpStaff = 16302,--任命
  ID_S2C_CorpStaff = 16303,
  ID_C2S_SetCorpChapterId = 16304,--设置军团副本ID
  ID_S2C_SetCorpChapterId = 16305,--设置军团副本ID
  --军团祭天
  ID_C2S_GetCorpWorship = 16400,--祭天信息
  ID_S2C_GetCorpWorship = 16401,
  ID_C2S_CorpContribute = 16402,--祭天
  ID_S2C_CorpContribute = 16403,
  ID_C2S_GetCorpContributeAward = 16404,--祭祀领奖
  ID_S2C_GetCorpContributeAward = 16405,
  --军团商店 (特殊)
  ID_C2S_GetCorpSpecialShop = 16500,--获取特殊军团商店信息
  ID_S2C_GetCorpSpecialShop = 16501,
  ID_C2S_CorpSpecialShopping = 16502,--特殊军团商店购买
  ID_S2C_CorpSpecialShopping = 16503,
  --军团副本
  ID_C2S_GetCorpChapter= 16600,--获取军团副本信息
  ID_S2C_GetCorpChapter = 16601,
  ID_C2S_GetCorpDungeonInfo= 16602,--获取军团副本信息
  ID_S2C_GetCorpDungeonInfo = 16603,
  ID_C2S_ExecuteCorpDungeon = 16604,--获取军团副本信息
  ID_S2C_ExecuteCorpDungeon = 16605,
  ID_S2C_FlushCorpDungeon =16606,--有信息刷新 通知
  ID_C2S_GetDungeonAwardList = 16607,--获取军团副本砸蛋信息
  ID_S2C_GetDungeonAwardList = 16608,--
  ID_C2S_GetDungeonAward = 16609,--砸蛋
  ID_S2C_GetDungeonAward = 16610,
  ID_C2S_GetDungeonCorpRank = 16611,--军团排行
  ID_S2C_GetDungeonCorpRank = 16612,
  ID_C2S_GetDungeonCorpMemberRank = 16613,--军团个人排行
  ID_S2C_GetDungeonCorpMemberRank = 16614,
  ID_C2S_GetDungeonAwardCorpPoint = 16615,--获取军团副本通关后的帮贡奖励
  ID_S2C_GetDungeonAwardCorpPoint = 16616,--
  ID_S2C_FlushDungeonAward = 16617,
  ID_C2S_ResetDungeonCount = 16618,--购买副本挑战次数
  ID_S2C_ResetDungeonCount = 16619,--购买副本挑战次数
  ID_C2S_GetCorpChapterRank = 16620,--军团副本总排行
  ID_S2C_GetCorpChapterRank = 16621,
  --跨服群英战
  ID_C2S_GetCorpCrossBattleInfo = 16700,--获取群英战信息
  ID_S2C_GetCorpCrossBattleInfo = 16701,--获取群英战信息
  ID_C2S_ApplyCorpCrossBattle = 16702,--报名--军团长 副军团长才有权限
  ID_S2C_ApplyCorpCrossBattle = 16703,--
  ID_C2S_QuitCorpCrossBattle = 16704,--退出报名
  ID_S2C_QuitCorpCrossBattle = 16705,
  ID_C2S_GetCorpCrossBattleList = 16706,--获取报名列表
  ID_S2C_GetCorpCrossBattleList = 16707,
  ID_C2S_GetCrossBattleEncourage = 16708,--鼓舞信息
  ID_S2C_GetCrossBattleEncourage = 16709,
  ID_C2S_CrossBattleEncourage = 16710,--鼓舞
  ID_S2C_CrossBattleEncourage = 16711,
  ID_C2S_GetCrossBattleField = 16712,--赛区信息
  ID_S2C_GetCrossBattleField = 16713,
  ID_C2S_GetCrossBattleEnemyCorp = 16714,--对方军团信息
  ID_S2C_GetCrossBattleEnemyCorp = 16715,
  ID_C2S_CrossBattleChallengeEnemy= 16718,--挑战
  ID_S2C_CrossBattleChallengeEnemy = 16719,
  ID_C2S_ResetCrossBattleChallengeCD= 16720,--重置挑战CD
  ID_S2C_ResetCrossBattleChallengeCD= 16721,
  ID_C2S_SetCrossBattleFireOn = 16722,--设置集火
  ID_S2C_SetCrossBattleFireOn = 16723,
  ID_C2S_CrossBattleMemberRank = 16724,--军团成员战绩
  ID_S2C_CrossBattleMemberRank = 16725,
  --ID_C2S_CrossBattleFieldReport = 16726,--查看战况
  --ID_S2C_CrossBattleFieldReport = 16727,
  ID_S2C_BroadCastState = 16728,--广播状态
  ID_C2S_GetCorpCrossBattleTime = 16729,--获取时间
  ID_S2C_GetCorpCrossBattleTime = 16730,--获取时间
  ID_S2C_FlushCorpCrossBattleList = 16731,--刷新
  ID_S2C_FlushCorpCrossBattleField  = 16732,--刷新通知分配成功
  ID_S2C_FlushCorpEncourage = 16733,--鼓舞了发消息
  ID_S2C_FlushCorpBattleResult = 16734,--军团战斗发消息
  ID_S2C_FlushFireOn = 16735,--军团集火
  ID_S2C_FlushBattleMemberInfo = 16736,--军团玩家信息
  --军团副本(新版)
  ID_C2S_GetNewCorpChapter= 16800,--获取军团副本信息
  ID_S2C_GetNewCorpChapter = 16801,
  ID_C2S_GetNewCorpDungeonInfo= 16802,--获取军团副本信息
  ID_S2C_GetNewCorpDungeonInfo = 16803,
  ID_C2S_ExecuteNewCorpDungeon = 16804,--获取军团副本信息
  ID_S2C_ExecuteNewCorpDungeon = 16805,
  ID_S2C_FlushNewCorpDungeon =16806,--有信息刷新 通知
  ID_C2S_GetNewDungeonAwardList = 16807,--获取军团副本砸蛋列表
  ID_S2C_GetNewDungeonAwardList = 16808,--
  ID_C2S_GetNewDungeonAward = 16809,--砸蛋
  ID_S2C_GetNewDungeonAward = 16810,
  ID_C2S_GetNewDungeonCorpMemberRank = 16811,--军团个人排行
  ID_S2C_GetNewDungeonCorpMemberRank = 16812,
  ID_S2C_FlushNewDungeonAward = 16813,
  ID_C2S_ResetNewDungeonCount = 16814,--购买副本挑战次数
  ID_S2C_ResetNewDungeonCount = 16815,--购买副本挑战次数
  ID_C2S_GetNewChapterAward = 16816,--获取章节奖励
  ID_S2C_GetNewChapterAward = 16817,--
  ID_C2S_GetNewDungeonAwardHint = 16818,--获取军团副本砸蛋领奖相关
  ID_S2C_GetNewDungeonAwardHint = 16819,--
  ID_C2S_GetNewCorpChapterRank = 16820,--军团副本总排行
  ID_S2C_GetNewCorpChapterRank = 16821,
  ID_C2S_SetNewCorpRollbackChapter = 16822, --设置回退军团副本
  ID_S2C_SetNewCorpRollbackChapter = 16823,

  ID_C2S_GetCorpTechInfo = 16900, --获取军团科技信息
  ID_S2C_GetCorpTechInfo = 16901,
  ID_C2S_DevelopCorpTech = 16902, --研发军团科技
  ID_S2C_DevelopCorpTech = 16903,
  ID_C2S_LearnCorpTech = 16904, -- 学习军团科技
  ID_S2C_LearnCorpTech = 16905,
  ID_C2S_CorpUpLevel = 16906, -- 军团手动升级
  ID_S2C_CorpUpLevel = 16907,
  ID_S2C_DevelopCorpTechBroadcast = 16908, --军团科技等级变化时广播
  ID_S2C_CorpUpLevelBroadcast = 16909, --军团升级广播

  --精英副本
  ID_C2S_Hard_GetChapterList = 14400,
  ID_S2C_Hard_GetChapterList = 14401,
  ID_C2S_Hard_GetChapterRank = 14402,
  ID_S2C_Hard_GetChapterRank = 14403,
  ID_S2C_Hard_AddStage = 14404,
  ID_C2S_Hard_ExecuteStage  = 14405,
  ID_S2C_Hard_ExecuteStage  = 14406,
  ID_C2S_Hard_FastExecuteStage  = 14407,
  ID_S2C_Hard_FastExecuteStage  = 14408,
  ID_C2S_Hard_FinishChapterBoxRwd  = 14409,--获取箱子奖励
  ID_S2C_Hard_FinishChapterBoxRwd  = 14410,
  ID_C2S_Hard_ResetDungeonExecution = 14411,--重置副本次数
  ID_S2C_Hard_ResetDungeonExecution = 14412,
  ID_S2C_Hard_ExecuteMultiStage = 14413,--副本战斗多战报协议
  ID_C2S_Hard_ExecuteMultiStage = 14414,
  ID_S2C_Hard_FirstEnterChapter = 14415,--第一次进入设置TAG
  ID_C2S_Hard_FirstEnterChapter = 14416,
  ID_S2C_Hard_GetChapterRoit = 14417,--获取精英副本暴动列表
  ID_C2S_Hard_GetChapterRoit = 14418,
  ID_S2C_Hard_FinishChapterRoit = 14419,--解决副本暴动
  ID_C2S_Hard_FinishChapterRoit = 14420,

  -- 赌博
  ID_C2S_WheelInfo = 14500,
  ID_S2C_WheelInfo = 14501,
  ID_C2S_PlayWheel = 14502,
  ID_S2C_PlayWheel = 14503,
  ID_C2S_WheelReward = 14504,
  ID_S2C_WheelReward = 14505,
  ID_C2S_WheelRankingList = 14506,
  ID_S2C_WheelRankingList = 14507,

	-- vip周礼包
  ID_C2S_VipDiscountInfo = 14600,
  ID_S2C_VipDiscountInfo = 14601,
  ID_C2S_BuyVipDiscount = 14602,
  ID_S2C_BuyVipDiscount = 14603,

  --单人跨服战
  ID_C2S_GetCrossBattleInfo = 14700,--获取跨服战信息
  ID_S2C_GetCrossBattleInfo = 14701,
  ID_C2S_GetCrossBattleTime = 14702,--获取跨服战时间
  ID_S2C_GetCrossBattleTime = 14703,
  --ID_C2S_GetCrossBattleGroup = 14704,--获取跨服战国家信息 --不用了
  --ID_S2C_GetCrossBattleGroup = 14705,
  ID_C2S_SelectCrossBattleGroup = 14706,--选择跨服战国家
  ID_S2C_SelectCrossBattleGroup = 14707,
  ID_C2S_EnterScoreBattle = 14708,--进入积分赛界面
  ID_S2C_EnterScoreBattle = 14709,
  ID_C2S_GetCrossBattleEnemy = 14710, --获取积分赛对手信息
  ID_S2C_GetCrossBattleEnemy = 14711,
  ID_C2S_ChallengeCrossBattleEnemy = 14712,--挑战对手
  ID_S2C_ChallengeCrossBattleEnemy = 14713,
  ID_C2S_GetWinsAwardInfo = 14714,--获取连胜信息
  ID_S2C_GetWinsAwardInfo= 14715,
  ID_C2S_FinishWinsAward = 14716,--获取连胜奖励
  ID_S2C_FinishWinsAward= 14717,
  ID_C2S_GetCrossBattleRank = 14718,--获取跨服战排名
  ID_S2C_GetCrossBattleRank = 14719,
  ID_C2S_CrossCountReset = 14720,--购买相关刷新次数
  ID_S2C_CrossCountReset = 14721,
  ID_S2C_FlushCrossContestScore = 14722,--跨服刷新积分
  ID_S2C_FlushCrossContestRank = 14723,--跨服刷新排名
  --争霸赛
  ID_C2S_GetCrossArenaInfo = 14724,--争霸赛信息
  ID_S2C_GetCrossArenaInfo = 14725,
  ID_C2S_GetCrossArenaInvitation = 14726,--邀请函信息
  ID_S2C_GetCrossArenaInvitation = 14727,
  ID_C2S_GetCrossArenaBetsInfo = 14728,--押注信息
  ID_S2C_GetCrossArenaBetsInfo = 14729,
  ID_C2S_GetCrossArenaBetsList = 14730,--押注列表
  ID_S2C_GetCrossArenaBetsList = 14731,
  ID_C2S_CrossArenaPlayBets = 14732,--押注玩家
  ID_S2C_CrossArenaPlayBets = 14733,
  ID_C2S_GetCrossArenaRankTop = 14734,--前十
  ID_S2C_GetCrossArenaRankTop = 14735,
  ID_C2S_GetCrossArenaRankUser = 14736,--自己周围的玩家信息
  ID_S2C_GetCrossArenaRankUser = 14737,
  ID_C2S_CrossArenaRankChallenge = 14738,--挑战
  ID_S2C_CrossArenaRankChallenge = 14739,--
  ID_C2S_CrossArenaCountReset = 14740,--购买相关刷新次数
  ID_S2C_CrossArenaCountReset = 14741,
  ID_C2S_GetCrossArenaBetsAward = 14742,--获取押注奖励
  ID_S2C_GetCrossArenaBetsAward = 14743,
  ID_C2S_CrossArenaServerAwardInfo = 14744,--获取全服奖励信息
  ID_S2C_CrossArenaServerAwardInfo = 14745,
  ID_C2S_FinishCrossArenaServerAward = 14746,--完成全服奖励
  ID_S2C_FinishCrossArenaServerAward = 14747,
  ID_C2S_FinishCrossArenaBetsAward = 14748,--完成押注奖励
  ID_S2C_FinishCrossArenaBetsAward = 14749,
  ID_C2S_CrossArenaAddBets = 14750,--押注
  ID_S2C_CrossArenaAddBets = 14751,
  ID_C2S_GetCrossUserDetail = 14752,--获取跨服玩家信息
  ID_S2C_GetCrossUserDetail = 14753,

	--打富翁活动
  ID_C2S_RichInfo = 14800,
  ID_S2C_RichInfo = 14801,
  ID_C2S_RichMove = 14804,
  ID_S2C_RichMove = 14805,
  ID_C2S_RichBuy = 14806,
  ID_S2C_RichBuy = 14807,
  ID_C2S_RichReward = 14808,
  ID_S2C_RichReward = 14809,
  ID_C2S_RichRankingList = 14810,
  ID_S2C_RichRankingList = 14811,

  --限时副本
  ID_C2S_GetTimeDungeonList = 14900, --取限时副本活动列表
  ID_S2C_GetTimeDungeonList = 14901,
  ID_S2C_FlushTimeDungeonList = 14902, --推送限时副本活动列表
  ID_C2S_GetTimeDungeonInfo = 14903, --取限时副本活动信息
  ID_S2C_GetTimeDungeonInfo = 14904,
  ID_C2S_AddTimeDungeonBuff = 14905, --鼓舞
  ID_S2C_AddTimeDungeonBuff = 14906,
  ID_C2S_AttackTimeDungeon = 14907, --挑战
  ID_S2C_AttackTimeDungeon = 14908,

  --动态代码ID
  ID_C2S_GetCodeId = 15000,
  ID_S2C_GetCodeId = 15001,
  ID_C2S_GetCode = 15002,
  ID_S2C_GetCode= 15003,
  ID_C2S_SetCDLevel = 15004,
  ID_S2C_SetCDLevel= 15005,
	
	--叛军BOSS
	ID_C2S_EnterRebelBossUI = 15101,
	ID_S2C_EnterRebelBossUI = 15102,
	--ID_C2S_RebelBossEncourage = 15103,
	--ID_S2C_RebleBossEncourage = 15104,
	ID_C2S_SelectAttackRebelBossGroup = 15105,
	ID_S2C_SelectAttackRebelBossGroup = 15106,
	ID_C2S_ChallengeRebelBoss = 15107,
	ID_S2C_ChallengeRebelBoss = 15108,
	ID_C2S_RebelBossRank = 15109,
	ID_S2C_RebelBossRank = 15110,
	ID_C2S_RebelBossAwardInfo = 15111,
	ID_S2C_RebelBossAwardInfo = 15112,
	ID_C2S_RebelBossAward = 15113,
	ID_S2C_RebelBossAward = 15114,
	ID_C2S_RefreshRebelBoss = 15115,
	ID_S2C_RefreshRebelBoss = 15116,
	ID_C2S_PurchaseAttackCount = 15117,
	ID_S2C_PurchaseAttackCount = 15118,
	ID_C2S_GetRebelBossReport = 15119,
	ID_S2C_GetRebelBossReport = 15120,
	ID_C2S_RebelBossCorpAwardInfo = 15121,
	ID_S2C_RebelBossCorpAwardInfo = 15122,
	ID_C2S_FlushBossACountTime = 15123,
	ID_S2C_FlushBossACountTime = 15124,

	ID_C2S_GetBlackcardWarning = 15200, --黑卡警告
	ID_S2C_GetBlackcardWarning = 15201, --黑卡警告

	--laxin
	ID_C2S_GetSpreadId = 15300,
	ID_S2C_GetSpreadId = 15301,
	 --invited req register
	ID_C2S_RegisterId = 15302,
	ID_S2C_RegisterId = 15303,

	--laxin 老玩家领奖
	ID_C2S_InvitorGetRewardInfo = 15304,
	ID_S2C_InvitorGetRewardInfo = 15305,
	ID_C2S_InvitorDrawLvlReward = 15306,
	ID_S2C_InvitorDrawLvlReward = 15307,
	ID_C2S_InvitorDrawScoreReward = 15308,
	ID_S2C_InvitorDrawScoreReward = 15309,
	--laxin  新玩家领奖
	ID_C2S_InvitedDrawReward = 15310,
	ID_S2C_InvitedDrawReward = 15311,
	ID_C2S_InvitedGetDrawReward = 15312,
	ID_S2C_InvitedGetDrawReward = 15313,

	ID_C2S_QueryRegisterRelation = 15314,
	ID_S2C_QueryRegisterRelation = 15315,
    --新玩家得到老玩家name
	ID_C2S_GetInvitorName = 15316,
	ID_S2C_GetInvitorName = 15317,

  --限时优惠
  ID_C2S_ShopTimeInfo = 15400,			--获取主界面信息
  ID_S2C_ShopTimeInfo = 15401,
  ID_C2S_ShopTimeRewardInfo = 15402,    --获取全服福利信息
  ID_S2C_ShopTimeRewardInfo = 15403,	
  ID_C2S_ShopTimeGetReward = 15404,		--领取全服福利
  ID_S2C_ShopTimeGetReward = 15405,
  ID_S2C_ShopTimePurchase = 15406,		--购买成功返回信息
  ID_C2S_ShopTimeStartTime = 15407,		--请求开服时间
  ID_S2C_ShopTimeStartTime = 15408,		

  -- vip日礼包
  ID_C2S_VipDailyInfo = 15500,
  ID_S2C_VipDailyInfo = 15501,
  ID_C2S_BuyVipDaily = 15502,
  ID_S2C_BuyVipDaily = 15503,

  --抢粮草
  ID_C2S_GetUserRice = 15600, --获取玩家粮草信息
  ID_S2C_GetUserRice = 15601,
  ID_S2C_UpdateUserRice = 15602, --更新客服端玩家粮草信息(包括对手信息)
  ID_C2S_FlushRiceRivals = 15603, --刷新对手
  ID_S2C_FlushRiceRivals = 15604,
  ID_C2S_RobRice = 15605, --抢粮
  ID_S2C_RobRice = 15606,
  ID_S2C_ChangeUserRice = 15607, --更新客户端玩家粮草数据
  ID_C2S_GetRiceEnemyInfo = 15608, --获取仇人列表
  ID_S2C_GetRiceEnemyInfo = 15609,
  ID_C2S_RevengeRiceEnemy = 15610, --复仇
  ID_S2C_RevengeRiceEnemy = 15611,
  ID_C2S_GetRiceAchievement = 15612, --获得成就
  ID_S2C_GetRiceAchievement = 15613,
  ID_C2S_GetRiceRankList = 15614, --获取排行榜
  ID_S2C_GetRiceRankList = 15615,
  ID_C2S_GetRiceRankAward = 15616, --获取排行奖励
  ID_S2C_GetRiceRankAward = 15617,
  ID_C2S_BuyRiceToken = 15618, --获取排行奖励
  ID_S2C_BuyRiceToken = 15619,
  ID_S2C_FlushRiceRank = 15620, --推送粮草排名
  -- GM 后台推送消息
  ID_C2S_PushSingleInfo = 15621,
  ID_S2C_PushSingleInfo = 15622,
  ID_C2S_GmChangeName   = 15623,  --后台改名,只修改跨服

  --月基金
  ID_C2S_GetMonthFundBaseInfo = 15700,
  ID_S2C_GetMonthFundBaseInfo = 15701,
  ID_C2S_GetMonthFundAwardInfo = 15702,
  ID_S2C_GetMonthFundAwardInfo = 15703,
  ID_C2S_GetMonthFundAward = 15704,
  ID_S2C_GetMonthFundAward = 15705,

  -- 限时抽卡
  ID_C2S_ThemeDropZY			= 15750,
  ID_S2C_ThemeDropZY			= 15751,
  ID_C2S_ThemeDropAstrology		= 15752,
  ID_S2C_ThemeDropAstrology		= 15753,
  ID_C2S_ThemeDropExtract		= 15754,
  ID_S2C_ThemeDropExtract		= 15755,

  -- 新日常副本
  ID_C2S_DungeonDailyInfo		= 15776,
  ID_S2C_DungeonDailyInfo		= 15777,
  ID_C2S_DungeonDailyChallenge  = 15778,
  ID_S2C_DungeonDailyChallenge  = 15779,

  --SpeXialScore(for tw)
  ID_C2S_GetSpeXialScoreInfo = 15800, --获取积分信息
  ID_S2C_GetSpeXialScoreInfo = 15801,
  ID_C2S_GetSpeXialScoreRank = 15802, --获取积分排名信息
  ID_S2C_GetSpeXialScoreRank = 15803,
  ID_C2S_GetSpeXialScoreAward = 15804, --获取积分成就奖励
  ID_S2C_GetSpeXialScoreAward = 15805,
  --社交账号绑定奖励(for sm)
  ID_C2S_GetAccountBindingInfo = 15810, --获取账号绑定信息
  ID_S2C_GetAccountBindingInfo = 15811,
  ID_C2S_GetAccountBindingAward = 15812, --获得绑定奖励
  ID_S2C_GetAccountBindingAward = 15813,

	--无双博士
  ID_C2S_WushBossInfo = 15900,
  ID_S2C_WushBossInfo = 15901,
  ID_C2S_WushBossChallenge = 15902,
  ID_S2C_WushBossChallenge = 15903,
  ID_C2S_WushBossBuy = 15904,
  ID_S2C_WushBossBuy = 15905,

  --限时团购
  ID_C2S_GetGroupBuyConfig	= 17000,		--获取配置
  ID_S2C_GetGroupBuyConfig	= 17001,
  ID_C2S_GetGroupBuyMainInfo	= 17002,		--主界面
  ID_S2C_GetGroupBuyMainInfo	= 17003,
  ID_C2S_GetGroupBuyRanking	= 17004,		--排行榜
  ID_S2C_GetGroupBuyRanking	= 17005,
  ID_C2S_GetGroupBuyTaskAwardInfo = 17006,	--任务奖励
  ID_S2C_GetGroupBuyTaskAwardInfo = 17007,
  ID_C2S_GetGroupBuyTaskAward	= 17008,	--领取奖励
  ID_S2C_GetGroupBuyTaskAward	= 17009,
  ID_C2S_GetGroupBuyEndInfo		= 17010,	--结束界面
  ID_S2C_GetGroupBuyEndInfo		= 17011,
  ID_C2S_GetGroupBuyRankAward	= 17012,	--排行奖励
  ID_S2C_GetGroupBuyRankAward	= 17013,
  ID_C2S_GroupBuyPurchaseGoods	= 17014,	--购买商品
  ID_S2C_GroupBuyPurchaseGoods	= 17015,
  ID_C2S_GetGroupBuyTimeInfo	= 17016,	--活动时间配置
  ID_S2C_GetGroupBuyTimeInfo	= 17017,

  --新手光环
  ID_C2S_RookieInfo = 17100,
  ID_S2C_RookieInfo = 17101,
  ID_C2S_GetRookieReward = 17102,
  ID_S2C_GetRookieReward = 17103,

  -- 人物头像框设置
  ID_C2S_SetPictureFrame = 17150,
  ID_S2C_SetPictureFrame = 17151,

  --百战沙场
  ID_C2S_GetBattleFieldInfo = 17200,
  ID_S2C_GetBattleFieldInfo = 17201,
  ID_C2S_BattleFieldDetail = 17202,
  ID_S2C_BattleFieldDetail = 17203,
  ID_C2S_ChallengeBattleField = 17204,
  ID_S2C_ChallengeBattleField = 17205,
  ID_C2S_BattleFieldAwardInfo = 17206,
  ID_S2C_BattleFieldAwardInfo = 17207,
  ID_C2S_GetBattleFieldAward = 17208,
  ID_S2C_GetBattleFieldAward = 17209,
  ID_C2S_BattleFieldShopInfo = 17210,
  ID_S2C_BattleFieldShopInfo = 17211,
  ID_C2S_BattleFieldShopRefresh = 17212,
  ID_S2C_BattleFieldShopRefresh = 17213,
  ID_C2S_GetBattleFieldRank = 17214,
  ID_S2C_GetBattleFieldRank = 17215,

  -- 奇门八卦活动
  ID_C2S_TrigramInfo = 17300,
  ID_S2C_TrigramInfo = 17301,
  ID_C2S_TrigramPlay = 17302,
  ID_S2C_TrigramPlay = 17303,
  ID_C2S_TrigramPlayAll = 17304,
  ID_S2C_TrigramPlayAll = 17305,
  ID_C2S_TrigramRefresh = 17306,
  ID_S2C_TrigramRefresh = 17307,
  ID_C2S_TrigramReward = 17308,
  ID_S2C_TrigramReward = 17309,

  ID_C2S_GetTrigramRank = 17310,
  ID_S2C_GetTrigramRank = 17311,

  -- 长假活动 中秋国庆
  ID_C2S_GetSpecialHolidayActivity = 17400,
  ID_S2C_GetSpecialHolidayActivity = 17401,
  ID_S2C_UpdateSpecialHolidayActivity = 17402,
  ID_C2S_GetSpecialHolidayActivityReward = 17403,
  ID_S2C_GetSpecialHolidayActivityReward = 17404,
  ID_C2S_GetSpecialHolidaySales = 17405,
  ID_S2C_GetSpecialHolidaySales = 17406,
  ID_C2S_BuySpecialHolidaySale = 17407,
  ID_S2C_BuySpecialHolidaySale = 17408,

  -- vip周商店
  ID_C2S_VipWeekShopInfo = 17500,
  ID_S2C_VipWeekShopInfo = 17501,
  ID_C2S_VipWeekShopBuy = 17502,
  ID_S2C_VipWeekShopBuy = 17503,

  --资料片副本
  ID_C2S_GetExpansiveDungeonChapterList = 17600,
  ID_S2C_GetExpansiveDungeonChapterList = 17601,
  ID_C2S_ExcuteExpansiveDungeonStage = 17602,
  ID_S2C_ExcuteExpansiveDungeonStage = 17603,
  ID_C2S_GetExpansiveDungeonChapterReward = 17604,
  ID_S2C_GetExpansiveDungeonChapterReward = 17605,
  ID_C2S_FirstEnterExpansiveDungeonChapter = 17606,
  ID_S2C_FirstEnterExpansiveDungeonChapter = 17607,
  ID_S2C_AddExpansiveDungeonNewStage = 17608,
  ID_C2S_PurchaseExpansiveDungeonShopItem = 17609,
  ID_S2C_PurchaseExpansiveDungeonShopItem = 17610,


  --宠物 18000 - 18099 为宠物
  ID_S2C_GetPet = 18000,
  ID_C2S_PetUpLvl = 18001,
  ID_S2C_PetUpLvl = 18002,
  ID_C2S_PetUpStar = 18003,
  ID_S2C_PetUpStar = 18004,
  ID_C2S_PetUpAddition = 18005,    --宠物神练
  ID_S2C_PetUpAddition = 18006,
  ID_C2S_ChangeFightPet = 18007,    --宠物上阵
  ID_S2C_ChangeFightPet = 18008,
  ID_C2S_RecyclePet = 18009,		--回收宠物（分解和重生）
  ID_S2C_RecyclePet = 18010,
  ID_C2S_PetFightValue = 18011,
  ID_S2C_PetFightValue = 18012,
  ID_C2S_GetPetProtect = 18013,
  ID_S2C_GetPetProtect = 18014,
  ID_C2S_SetPetProtect = 18015,
  ID_S2C_SetPetProtect = 18016,

  --跨服夺帅
  ID_C2S_GetCrossPvpSchedule = 19000,	-- 拉取所有配置信息
  ID_S2C_GetCrossPvpSchedule = 19001,
  ID_C2S_GetCrossPvpBaseInfo = 19002,	-- 拉取基本信息，round 和state主控
  ID_S2C_GetCrossPvpBaseInfo = 19003,
  ID_C2S_GetCrossPvpScheduleInfo = 19004, --每个战场信息（等级 人数...）
  ID_S2C_GetCrossPvpScheduleInfo = 19005,
  ID_C2S_ApplyCrossPvp = 19006,			--跨服夺帅报名
  ID_S2C_ApplyCrossPvp = 19007,
  --ID_C2S_GetAtcAndDefCrossPvp = 19008,  --鼓舞信息
  --ID_S2C_GetAtcAndDefCrossPvp = 19009,
  ID_C2S_ApplyAtcAndDefCrossPvp = 19010,--鼓舞
  ID_S2C_ApplyAtcAndDefCrossPvp = 19011,
  ID_C2S_GetCrossPvpRole = 19012,	--获取角色信息 (感觉没什么用啊)
  ID_S2C_GetCrossPvpRole = 19013,	
  ID_C2S_GetCrossPvpArena = 19015,		--获取跨服战坑位信息
  ID_S2C_GetCrossPvpArena = 19016,
  ID_C2S_GetCrossPvpRank = 19017,		--获取排行榜
  ID_S2C_GetCrossPvpRank = 19018,
  ID_C2S_CrossPvpBattle = 19019,		--攻打坑位
  ID_S2C_CrossPvpBattle = 19020,		
  ID_S2C_FlushCrossPvpArena = 19021,	--推送坑位变化信息同房间玩家
  ID_S2C_FlushCrossPvpSpecific = 19022,	--推送坑位变化信息给坑位上原玩家
  ID_S2C_FlushCrossPvpScore = 19023,	--推送积分变化
  ID_C2S_GetCrossPvpDetail = 19024,		--玩家战斗信息
  ID_S2C_GetCrossPvpDetail = 19025,
  ID_C2S_CrossPvpGetAward = 19026,		--领取排行奖励
  ID_S2C_CrossPvpGetAward = 19027,
  ID_C2S_CrossWaitInit = 19028,			--获取等待界面信息
  ID_S2C_CrossWaitInit = 19029,	
  ID_C2S_CrossWaitRank = 19030,			--获取上一轮的排行榜
  ID_S2C_CrossWaitRank = 19031,
  ID_C2S_CrossWaitFlower = 19032,		--送鲜花扔鸡蛋
  ID_S2C_CrossWaitFlower = 19033,	
  ID_C2S_CrossWaitFlowerRank = 19034,	--鲜花鸡蛋榜
  ID_S2C_CrossWaitFlowerRank = 19035,	
  ID_C2S_CrossWaitFlowerAward = 19036,	--投注奖励
  ID_S2C_CrossWaitFlowerAward = 19037,	
  ID_C2S_CrossWaitInitFlowerInfo = 19038, --一轮过后鲜花鸡蛋信息
  ID_S2C_CrossWaitInitFlowerInfo = 19039,
  ID_C2S_GetCrossPvpOb= 19040,--获取OB信息
  ID_S2C_GetCrossPvpOb = 19041,

  --弹幕系统
  ID_C2S_GetBulletScreenInfo = 20000,	--拉取弹幕信息
  ID_S2C_GetBulletScreenInfo = 20001,	
  ID_C2S_SendBulletScreenInfo = 20002,	--发送弹幕
  ID_S2C_SendBulletScreenInfo = 20003,	--发送弹幕
  ID_S2C_FlushBulletScreen = 20004,	

  -- 组队pvp
  ID_C2S_TeamPVPStatus = 21000, -- 组队pvp, 查询状态
  ID_S2C_TeamPVPStatus = 21001, -- 组队pvp，状态推送
  ID_C2S_TeamPVPCreateTeam = 21002, -- 组队pvp，创建队伍
  ID_S2C_TeamPVPCreateTeam = 21003,
  ID_C2S_TeamPVPJoinTeam = 21004, -- 组队pvp，加入队伍
  ID_S2C_TeamPVPJoinTeam = 21005,
  ID_C2S_TeamPVPLeave = 21008, --退出组队，及组队匹配
  ID_S2C_TeamPVPLeave = 21009,
  ID_C2S_TeamPVPChangePosition = 21010, -- 队长换位置
  ID_S2C_TeamPVPChangePosition = 21011,
  ID_C2S_TeamPVPKickTeamMember = 21012, -- 队长踢人
  ID_S2C_TeamPVPKickTeamMember = 21013,
  ID_C2S_TeamPVPSetTeamOnlyInvited = 21014, -- 队长设置房间是否开放
  ID_S2C_TeamPVPSetTeamOnlyInvited = 21015,
  ID_C2S_TeamPVPInvite = 21016, -- 邀请
  ID_S2C_TeamPVPInvite = 21017,
  ID_S2C_TeamPVPBeInvited = 21018, -- 被邀请
  ID_C2S_TeamPVPInvitedJoinTeam = 21019, -- 持邀请卡 加入队伍
  ID_S2C_TeamPVPInvitedJoinTeam = 21020,
  ID_S2C_TeamPVPInviteCanceled = 21021,
  ID_C2S_TeamPVPInviteNPC = 21022, --一键邀请
  ID_S2C_TeamPVPInviteNPC = 21023,
  ID_C2S_TeamPVPAgreeBattle = 21024, -- 组员准备好出战
  ID_S2C_TeamPVPAgreeBattle = 21025,
  ID_C2S_TeamPVPMatchOtherTeam = 21026, --队长 出战，组队完成，匹配其他队伍
  ID_S2C_TeamPVPMatchOtherTeam = 21027,
  ID_C2S_TeamPVPStopMatch = 21028, -- 队长取消 匹配其他队伍
  ID_S2C_TeamPVPStopMatch = 21029,
  ID_S2C_TeamPVPBattleResult = 21030, --战斗结果
  ID_C2S_TeamPVPHistoryBattleReport = 21031, -- 获取历史战报
  ID_S2C_TeamPVPHistoryBattleReport = 21032,
  ID_S2C_TeamPVPHistoryBattleReportEnd = 21033,
  ID_C2S_TeamPVPBattleTeamChange = 21034, --通知服务器布阵变化
  ID_S2C_TeamPVPBattleTeamChange = 21035,

  ID_S2C_TeamPVPCrossServerLost = 21040, -- 跨服服务器挂了

  ID_C2S_TeamPVPGetRank = 21041, -- 组队pvp排行版
  ID_S2C_TeamPVPGetRank = 21042,
  ID_C2S_TeamPVPGetUserInfo = 21043, -- 组队pvp玩家荣誉积分等信息
  ID_S2C_TeamPVPGetUserInfo = 21044,
  ID_C2S_TeamPVPBuyAwardCnt = 21045, -- 组队pvp，买奖励次数
  ID_S2C_TeamPVPBuyAwardCnt = 21046,
  ID_C2S_TeamPVPAcceptInvite = 21047, -- 组队pvp，是否接受邀请
  ID_S2C_TeamPVPAcceptInvite = 21048,
  ID_C2S_TeamPVPPopChat = 21049, -- 组队pvp，气泡聊天
  ID_S2C_TeamPVPPopChat = 21050,

  --商店标签,方便玩家购买合成所需材料
  ID_C2S_GetShopTag = 21100,
  ID_S2C_GetShopTag = 21101,
  ID_C2S_AddShopTag = 21102,
  ID_S2C_AddShopTag = 21103,
  ID_C2S_DelShopTag = 21104,
  ID_S2C_DelShopTag = 21105,

  --老玩家回归
  ID_C2S_GetOlderPlayerInfo = 21200,
  ID_S2C_GetOlderPlayerInfo = 21201,
  ID_C2S_GetOlderPlayerVipAward = 21202,
  ID_S2C_GetOlderPlayerVipAward = 21203,
  ID_C2S_GetOlderPlayerLevelAward = 21204,
  ID_S2C_GetOlderPlayerLevelAward = 21205,
  ID_C2S_GetOlderPlayerVipExp = 21206,
  ID_S2C_GetOlderPlayerVipExp = 21207,

  -- 充值翻牌
  ID_C2S_RCardInfo = 21300,
  ID_S2C_RCardInfo = 21301,
  ID_C2S_PlayRCard = 21302,
  ID_S2C_PlayRCard = 21303,
  ID_C2S_ResetRCard = 21304,
  ID_S2C_ResetRCard = 21305,

  ID_C2S_SetClothSwitch = 21311,
  ID_S2C_SetClothSwitch = 21312,

  ID_C2S_GetDays7CompInfo = 21316,
  ID_S2C_GetDays7CompInfo = 21317,
  ID_C2S_GetDays7CompAward = 21318,
  ID_S2C_GetDays7CompAward = 21319,

  ID_C2S_GetKsoul = 21400,--获取将灵信息
  ID_S2C_GetKsoul = 21401,
  ID_C2S_RecycleKsoul = 21402,--回收将灵
  ID_S2C_RecycleKsoul = 21403,
  ID_C2S_ActiveKsoulGroup = 21404,--激活阵图
  ID_S2C_ActiveKsoulGroup = 21405,
  ID_C2S_ActiveKsoulTarget = 21406,--激活成就
  ID_S2C_ActiveKsoulTarget = 21407,
  ID_C2S_SummonKsoul = 21408,--点将
  ID_S2C_SummonKsoul = 21409,
  ID_C2S_SummonKsoulExchange = 21410,--点将奇遇
  ID_S2C_SummonKsoulExchange  = 21411,
  ID_C2S_GetCommonRank =21412,--通用排行榜
  ID_S2C_GetCommonRank =21413,

  ID_C2S_KsoulShopInfo = 21450,
  ID_S2C_KsoulShopInfo = 21451,
  ID_C2S_KsoulShopBuy = 21452,
  ID_S2C_KsoulShopBuy = 21453,
  ID_C2S_KsoulShopRefresh = 21454,
  ID_S2C_KsoulShopRefresh = 21455,
  ID_C2S_KsoulDungeonInfo = 21456,
  ID_S2C_KsoulDungeonInfo = 21457,
  ID_C2S_KsoulDungeonRefresh = 21458,
  ID_S2C_KsoulDungeonRefresh = 21459,
  ID_C2S_KsoulDungeonChallenge = 21460,
  ID_S2C_KsoulDungeonChallenge = 21461,
  ID_C2S_KsoulSetFightBase = 21462,
  ID_S2C_KsoulSetFightBase = 21463,

  --新马服FB分享协议
  ID_C2S_ShareFriendAwardInfo = 21470,
  ID_S2C_ShareFriendAwardInfo = 21471,
  ID_C2S_ShareFriendGetAward = 21472,
  ID_S2C_ShareFriendGetAward = 21473,

  -- 招财
  ID_C2S_FortuneInfo	= 21480,
  ID_S2C_FortuneInfo	= 21481,
  ID_C2S_FortuneBuySilver = 21482,
  ID_S2C_FortuneBuySilver = 21483,
  ID_C2S_FortuneGetBox	= 21484,
  ID_S2C_FortuneGetBox	= 21485,

}
return NetMsg_ID
