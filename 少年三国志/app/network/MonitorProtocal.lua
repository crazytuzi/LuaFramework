--MonitorProtocal.lua


local MonitorProtocal = {
	--[NetMsg_ID.ID_C2S_FightKnight] 				= NetMsg_ID.ID_S2C_FightKnight,
    --阵容
	[NetMsg_ID.ID_C2S_ChangeFormation] 			= NetMsg_ID.ID_S2C_ChangeFormation,
	[NetMsg_ID.ID_C2S_ChangeTeamKnight] 		= NetMsg_ID.ID_S2C_ChangeTeamKnight,
	[NetMsg_ID.ID_C2S_AddTeamKnight] 			= NetMsg_ID.ID_S2C_AddTeamKnight,
    [NetMsg_ID.ID_C2S_Create]            = NetMsg_ID.ID_S2C_Create,   
    [NetMsg_ID.ID_C2S_AddFightEquipment]        = NetMsg_ID.ID_S2C_AddFightEquipment,
    [NetMsg_ID.ID_C2S_ClearFightEquipment]      = NetMsg_ID.ID_S2C_ClearFightEquipment,
    [NetMsg_ID.ID_C2S_AddFightTreasure]         = NetMsg_ID.ID_S2C_AddFightTreasure,
    [NetMsg_ID.ID_C2S_ClearFightTreasure]       = NetMsg_ID.ID_S2C_ClearFightTreasure,


	[NetMsg_ID.ID_C2S_UpgradeKnight] 			= NetMsg_ID.ID_S2C_UpgradeKnight,	
	[NetMsg_ID.ID_C2S_AdvancedKnight] 			= NetMsg_ID.ID_S2C_AdvancedKnight,
	[NetMsg_ID.ID_C2S_TrainingKnight] 			= NetMsg_ID.ID_S2C_TrainingKnight,
	[NetMsg_ID.ID_C2S_SaveTrainingKnight] 		= NetMsg_ID.ID_S2C_SaveTrainingKnight,
	[NetMsg_ID.ID_C2S_GiveupTrainingKnight] 	= NetMsg_ID.ID_S2C_GiveupTrainingKnight,
	[NetMsg_ID.ID_C2S_UpgradeKnightHalo] 		= NetMsg_ID.ID_S2C_UpgradeKnightHalo,
        [NetMsg_ID.ID_C2S_EnterShop] 		= NetMsg_ID.ID_S2C_EnterShop,
        [NetMsg_ID.ID_C2S_RecruitInfo] 		= NetMsg_ID.ID_S2C_RecruitInfo,
    [NetMsg_ID.ID_C2S_Login] 		= NetMsg_ID.ID_S2C_Login,
    [NetMsg_ID.ID_C2S_Flush] 		= NetMsg_ID.ID_S2C_Flush,
    [NetMsg_ID.ID_C2S_FragmentCompound] = NetMsg_ID.ID_S2C_FragmentCompound,
        [NetMsg_ID.ID_C2S_GetTreasureFragmentRobList] = NetMsg_ID.ID_S2C_GetTreasureFragmentRobList,
        [NetMsg_ID.ID_C2S_GetArenaInfo] = NetMsg_ID.ID_S2C_GetArenaInfo,
        [NetMsg_ID.ID_C2S_UpgradeTreasure] = NetMsg_ID.ID_S2C_UpgradeTreasure,
        [NetMsg_ID.ID_C2S_RefiningTreasure] = NetMsg_ID.ID_S2C_RefiningTreasure,
        [NetMsg_ID.ID_C2S_UpgradeEquipment] = NetMsg_ID.ID_S2C_UpgradeEquipment,
        [NetMsg_ID.ID_C2S_RefiningEquipment] = NetMsg_ID.ID_S2C_RefiningEquipment,
        [NetMsg_ID.ID_C2S_FastRefineEquipment] = NetMsg_ID.ID_S2C_FastRefineEquipment,
        [NetMsg_ID.ID_C2S_TreasureSmelt] = NetMsg_ID.ID_S2C_TreasureSmelt,
        [NetMsg_ID.ID_C2S_TreasureForge] = NetMsg_ID.ID_S2C_TreasureForge,
        [NetMsg_ID.ID_C2S_UpStarEquipment] = NetMsg_ID.ID_S2C_UpStarEquipment,
        
        [NetMsg_ID.ID_C2S_GetChapterList] = NetMsg_ID.ID_S2C_GetChapterList,
        [NetMsg_ID.ID_C2S_FastExecuteStage] = NetMsg_ID.ID_S2C_FastExecuteStage,
        [NetMsg_ID.ID_C2S_FinishChapterAchvRwd] = NetMsg_ID.ID_S2C_FinishChapterAchvRwd,
        [NetMsg_ID.ID_C2S_GetChapterRank] = NetMsg_ID.ID_S2C_GetChapterRank,
        [NetMsg_ID.ID_C2S_ExecuteMultiStage] = NetMsg_ID.ID_S2C_ExecuteMultiStage,
        [NetMsg_ID.ID_C2S_ExecuteStage] = {NetMsg_ID.ID_S2C_ExecuteMultiStage, NetMsg_ID.ID_S2C_ExecuteStage},
        [NetMsg_ID.ID_C2S_ChapterAchvRwdInfo] = NetMsg_ID.ID_S2C_ChapterAchvRwdInfo,
        [NetMsg_ID.ID_C2S_FinishChapterAchvRwd] = NetMsg_ID.ID_S2C_FinishChapterAchvRwd,
        [NetMsg_ID.ID_C2S_FinishChapterBoxRwd] = NetMsg_ID.ID_S2C_FinishChapterBoxRwd,
        [NetMsg_ID.ID_C2S_ResetDungeonExecution] = NetMsg_ID.ID_S2C_ResetDungeonExecution,
        [NetMsg_ID.ID_C2S_FirstEnterChapter] = NetMsg_ID.ID_S2C_FirstEnterChapter,
        
        
        [NetMsg_ID.ID_C2S_GetStoryList] = NetMsg_ID.ID_S2C_GetStoryList,
        [NetMsg_ID.ID_C2S_ExecuteBarrier] = NetMsg_ID.ID_S2C_ExecuteBarrier,
        [NetMsg_ID.ID_C2S_FastExecuteBarrier] = NetMsg_ID.ID_S2C_FastExecuteBarrier,
        [NetMsg_ID.ID_C2S_SanguozhiAwardInfo] = NetMsg_ID.ID_S2C_SanguozhiAwardInfo,
        [NetMsg_ID.ID_C2S_FinishSanguozhiAward] = NetMsg_ID.ID_S2C_FinishSanguozhiAward,
        [NetMsg_ID.ID_C2S_ResetStoryFastTimeCd] = NetMsg_ID.ID_S2C_ResetStoryFastTimeCd,
            
        -- 神秘商店
        [NetMsg_ID.ID_C2S_MysticalShopInfo] = NetMsg_ID.ID_S2C_MysticalShopInfo,
        [NetMsg_ID.ID_C2S_MysticalShopRefresh] = NetMsg_ID.ID_S2C_MysticalShopRefresh,
        
        -- 武将归隐和装备重铸
        [NetMsg_ID.ID_C2S_RecycleKnight] = NetMsg_ID.ID_S2C_RecycleKnight,
        [NetMsg_ID.ID_C2S_RecycleEquipment] = NetMsg_ID.ID_S2C_RecycleEquipment,
        [NetMsg_ID.ID_C2S_RebornEquipment] = NetMsg_ID.ID_S2C_RebornEquipment,

        -- 碎片出售
        [NetMsg_ID.ID_C2S_FragmentSale] = NetMsg_ID.ID_S2C_FragmentSale,
        
        -- 闯关
        [NetMsg_ID.ID_C2S_TowerInfo] = NetMsg_ID.ID_S2C_TowerInfo,
        [NetMsg_ID.ID_C2S_TowerChallenge] = NetMsg_ID.ID_S2C_TowerChallenge,
        [NetMsg_ID.ID_C2S_TowerStartCleanup] = NetMsg_ID.ID_S2C_TowerStartCleanup,
        [NetMsg_ID.ID_C2S_TowerStopCleanup] = NetMsg_ID.ID_S2C_TowerStopCleanup,
        [NetMsg_ID.ID_C2S_TowerReset] = NetMsg_ID.ID_S2C_TowerReset,
        [NetMsg_ID.ID_C2S_TowerGetBuff] = NetMsg_ID.ID_S2C_TowerGetBuff,
        [NetMsg_ID.ID_C2S_TowerRfBuff] = NetMsg_ID.ID_S2C_TowerRfBuff,
        [NetMsg_ID.ID_C2S_TowerRequestReward] = NetMsg_ID.ID_S2C_TowerRequestReward,
        [NetMsg_ID.ID_C2S_TowerRankingList] = NetMsg_ID.ID_S2C_TowerRankingList,

        [NetMsg_ID.ID_C2S_WushInfo] = NetMsg_ID.ID_S2C_WushInfo,
        [NetMsg_ID.ID_C2S_WushGetBuff] = NetMsg_ID.ID_S2C_WushGetBuff,
        [NetMsg_ID.ID_C2S_WushChallenge] = NetMsg_ID.ID_S2C_WushChallenge,
        [NetMsg_ID.ID_C2S_WushApplyBuff] = NetMsg_ID.ID_S2C_WushApplyBuff,
        [NetMsg_ID.ID_C2S_WushReset] = NetMsg_ID.ID_S2C_WushReset,
        [NetMsg_ID.ID_C2S_WushBuy] = NetMsg_ID.ID_S2C_WushBuy,

        --购买道具
        [NetMsg_ID.ID_C2S_Shopping] = NetMsg_ID.ID_S2C_Shopping,
        [NetMsg_ID.ID_C2S_UseItem] = NetMsg_ID.ID_S2C_UseItem,
        [NetMsg_ID.ID_C2S_UseMonthCard] = NetMsg_ID.ID_S2C_UseMonthCard,
        --月卡
        
        --夺宝
        
        [NetMsg_ID.ID_C2S_RobTreasureFragment] = NetMsg_ID.ID_S2C_RobTreasureFragment,
        [NetMsg_ID.ID_C2S_ComposeTreasure] = NetMsg_ID.ID_S2C_ComposeTreasure,
        [NetMsg_ID.ID_C2S_TreasureFragmentForbidBattle] = NetMsg_ID.ID_S2C_TreasureFragmentForbidBattle,
        [NetMsg_ID.ID_C2S_FastRobTreasureFragment] = NetMsg_ID.ID_S2C_FastRobTreasureFragment,
        [NetMsg_ID.ID_C2S_OneKeyRobTreasureFragment] = NetMsg_ID.ID_S2C_OneKeyRobTreasureFragment,
        
        -- 图鉴
        [NetMsg_ID.ID_C2S_GetHandbookInfo] = NetMsg_ID.ID_S2C_GetHandbookInfo,

        -- chat
        [NetMsg_ID.ID_C2S_ChatRequest] = NetMsg_ID.ID_S2C_ChatRequest,

        --抽卡
        [NetMsg_ID.ID_C2S_RecruitJpTen] = NetMsg_ID.ID_S2C_RecruitJpTen,
        [NetMsg_ID.ID_C2S_RecruitJp] = NetMsg_ID.ID_S2C_RecruitJp,
        [NetMsg_ID.ID_C2S_RecruitLp] = NetMsg_ID.ID_S2C_RecruitLp,
        [NetMsg_ID.ID_C2S_RecruitLpTen] = NetMsg_ID.ID_S2C_RecruitLpTen,
        [NetMsg_ID.ID_C2S_RecruitJpTen] = NetMsg_ID.ID_S2C_RecruitJpTen,

        --20连抽
        
        [NetMsg_ID.ID_C2S_RecruitJpTw] = NetMsg_ID.ID_S2C_RecruitJpTw,
        --阵营抽将
        [NetMsg_ID.ID_C2S_RecruitZy] = NetMsg_ID.ID_S2C_RecruitZy,
        
        --竞技场
        [NetMsg_ID.ID_C2S_GetArenaUserInfo] = NetMsg_ID.ID_S2C_GetArenaUserInfo,
        [NetMsg_ID.ID_C2S_GetArenaTopInfo] = NetMsg_ID.ID_S2C_GetArenaTopInfo,
        [NetMsg_ID.ID_C2S_ChallengeArena] = NetMsg_ID.ID_S2C_ChallengeArena,
        
        
        -- 领奖中心
        [NetMsg_ID.ID_C2S_ProcessGiftMail] = NetMsg_ID.ID_S2C_ProcessGiftMail,
        [NetMsg_ID.ID_C2S_GetGiftMail] = NetMsg_ID.ID_S2C_GetGiftMail,
        --邮件
        [NetMsg_ID.ID_C2S_GetMail] = NetMsg_ID.ID_S2C_GetMail,

        -- 好友
       -- [NetMsg_ID.ID_C2S_GetFriendList] = NetMsg_ID.ID_S2C_GetFriendList,
        [NetMsg_ID.ID_C2S_ConfirmAddFriend] = NetMsg_ID.ID_S2C_ConfirmAddFriend,
        [NetMsg_ID.ID_C2S_GetPlayerInfo] = NetMsg_ID.ID_S2C_GetPlayerInfo,
        [NetMsg_ID.ID_C2S_KillFriend] = NetMsg_ID.ID_S2C_KillFriend,
        [NetMsg_ID.ID_C2S_ChooseFriend] = NetMsg_ID.ID_S2C_ChooseFriend,
        [NetMsg_ID.ID_C2S_GetFriendReqList] = NetMsg_ID.ID_S2C_GetFriendReqList,
        [NetMsg_ID.ID_C2S_RequestAddFriend] = NetMsg_ID.ID_S2C_RequestAddFriend,
        [NetMsg_ID.ID_C2S_FriendPresent] = NetMsg_ID.ID_S2C_FriendPresent,
        [NetMsg_ID.ID_C2S_GetFriendPresent] = NetMsg_ID.ID_S2C_GetFriendPresent,

        --活动
         [NetMsg_ID.ID_C2S_Drink] = NetMsg_ID.ID_S2C_Drink,
        [NetMsg_ID.ID_C2S_Worship] = NetMsg_ID.ID_S2C_Worship,
        [NetMsg_ID.ID_C2S_LoginReward] = NetMsg_ID.ID_S2C_LoginReward,
        [NetMsg_ID.ID_C2S_LoginRewardInfo] = NetMsg_ID.ID_S2C_LoginRewardInfo,
        

        [NetMsg_ID.ID_C2S_GetHolidayEventInfo] = NetMsg_ID.ID_S2C_GetHolidayEventInfo,
        [NetMsg_ID.ID_C2S_GetHolidayEventAward] = NetMsg_ID.ID_S2C_GetHolidayEventAward,
        [NetMsg_ID.ID_C2S_GetCustomActivityAward] = NetMsg_ID.ID_S2C_GetCustomActivityAward,
        
        --首冲

        [NetMsg_ID.ID_C2S_GetRechargeBonus] = NetMsg_ID.ID_S2C_GetRechargeBonus,
        --每日任务
        [NetMsg_ID.ID_C2S_GetDailyMission] = NetMsg_ID.ID_S2C_GetDailyMission,
        [NetMsg_ID.ID_C2S_FinishDailyMission] = NetMsg_ID.ID_S2C_FinishDailyMission,
        [NetMsg_ID.ID_C2S_GetDailyMissionAward] = NetMsg_ID.ID_S2C_GetDailyMissionAward,
        
        -- 成就
        [NetMsg_ID.ID_C2S_TargetInfo] = NetMsg_ID.ID_S2C_TargetInfo,
        [NetMsg_ID.ID_C2S_TargetGetReward] = NetMsg_ID.ID_S2C_TargetGetReward,

        --叛军
        [NetMsg_ID.ID_C2S_GetExploitAward] = NetMsg_ID.ID_S2C_GetExploitAward,
        [NetMsg_ID.ID_C2S_AttackRebel] = NetMsg_ID.ID_S2C_AttackRebel,
        [NetMsg_ID.ID_C2S_EnterRebelUI] = NetMsg_ID.ID_S2C_EnterRebelUI,
        
        --礼品码
        
        [NetMsg_ID.ID_C2S_GiftCode] = NetMsg_ID.ID_S2C_GiftCode,

        -- vip副本
        [NetMsg_ID.ID_C2S_ExecuteVipDungeon] = NetMsg_ID.ID_S2C_ExecuteVipDungeon,

        --基金
        [NetMsg_ID.ID_C2S_GetFundInfo] = NetMsg_ID.ID_S2C_GetFundInfo,
        [NetMsg_ID.ID_C2S_GetUserFund] = NetMsg_ID.ID_S2C_GetUserFund,
        [NetMsg_ID.ID_C2S_BuyFund] = NetMsg_ID.ID_S2C_BuyFund,
        [NetMsg_ID.ID_C2S_GetFundAward] = NetMsg_ID.ID_S2C_GetFundAward,
        [NetMsg_ID.ID_C2S_GetFundWeal] = NetMsg_ID.ID_S2C_GetFundWeal,

        --月基金
        [NetMsg_ID.ID_C2S_GetMonthFundBaseInfo] = NetMsg_ID.ID_S2C_GetMonthFundBaseInfo,
        [NetMsg_ID.ID_C2S_GetMonthFundAwardInfo] = NetMsg_ID.ID_S2C_GetMonthFundAwardInfo,
        [NetMsg_ID.ID_C2S_GetMonthFundAward] = NetMsg_ID.ID_S2C_GetMonthFundAward,

        --名人堂
         [NetMsg_ID.ID_C2S_HOF_UIInfo] = NetMsg_ID.ID_S2C_HOF_UIInfo,
         [NetMsg_ID.ID_C2S_HOF_Confirm] = NetMsg_ID.ID_S2C_HOF_Confirm,
         [NetMsg_ID.ID_C2S_HOF_Sign] = NetMsg_ID.ID_S2C_HOF_Sign,
         [NetMsg_ID.ID_C2S_HOF_RankInfo] = NetMsg_ID.ID_S2C_HOF_RankInfo,

         [NetMsg_ID.ID_C2S_GetDaysActivityInfo] = NetMsg_ID.ID_S2C_GetDaysActivityInfo,
         [NetMsg_ID.ID_C2S_FinishDaysActivity] = NetMsg_ID.ID_S2C_FinishDaysActivity,
         [NetMsg_ID.ID_C2S_GetDaysActivitySell] = NetMsg_ID.ID_S2C_GetDaysActivitySell,
         [NetMsg_ID.ID_C2S_PurchaseActivitySell] = NetMsg_ID.ID_S2C_PurchaseActivitySell,
         [NetMsg_ID.ID_C2S_BuyVipDiscount] = NetMsg_ID.ID_S2C_BuyVipDiscount,
         [NetMsg_ID.ID_C2S_VipDiscountInfo] = NetMsg_ID.ID_S2C_VipDiscountInfo,
         [NetMsg_ID.ID_C2S_BuyVipDaily] = NetMsg_ID.ID_S2C_BuyVipDaily,
         [NetMsg_ID.ID_C2S_VipDailyInfo] = NetMsg_ID.ID_S2C_VipDailyInfo,
         [NetMsg_ID.ID_C2S_VipWeekShopInfo] = NetMsg_ID.ID_S2C_VipWeekShopInfo,
         [NetMsg_ID.ID_C2S_VipWeekShopBuy] = NetMsg_ID.ID_S2C_VipWeekShopBuy,

         [NetMsg_ID.ID_C2S_GetSpreadId] = NetMsg_ID.ID_S2C_GetSpreadId,
         [NetMsg_ID.ID_C2S_RegisterId] = NetMsg_ID.ID_S2C_RegisterId,
         [NetMsg_ID.ID_C2S_InvitorGetRewardInfo] = NetMsg_ID.ID_S2C_InvitorGetRewardInfo,
         [NetMsg_ID.ID_C2S_InvitorDrawLvlReward] = NetMsg_ID.ID_S2C_InvitorDrawLvlReward,
         [NetMsg_ID.ID_C2S_InvitorDrawScoreReward] = NetMsg_ID.ID_S2C_InvitorDrawScoreReward,
         [NetMsg_ID.ID_C2S_InvitedDrawReward] = NetMsg_ID.ID_S2C_InvitedDrawReward,
         [NetMsg_ID.ID_C2S_InvitedGetDrawReward] = NetMsg_ID.ID_S2C_InvitedGetDrawReward,
         [NetMsg_ID.ID_C2S_QueryRegisterRelation] = NetMsg_ID.ID_S2C_QueryRegisterRelation,
         [NetMsg_ID.ID_C2S_GetInvitorName] = NetMsg_ID.ID_S2C_GetInvitorName,

         -- 领地征讨
        [NetMsg_ID.ID_C2S_CityInfo] = NetMsg_ID.ID_S2C_CityInfo,
        [NetMsg_ID.ID_C2S_CityAttack] = NetMsg_ID.ID_S2C_CityAttack,
        [NetMsg_ID.ID_C2S_CityPatrol] = NetMsg_ID.ID_S2C_CityPatrol,
        [NetMsg_ID.ID_C2S_CityCheck] = NetMsg_ID.ID_S2C_CityCheck,
        [NetMsg_ID.ID_C2S_CityReward] = NetMsg_ID.ID_S2C_CityReward,
        [NetMsg_ID.ID_C2S_CityAssist] = NetMsg_ID.ID_S2C_CityAssist,
        [NetMsg_ID.ID_C2S_CityOneKeyReward] = NetMsg_ID.ID_S2C_CityOneKeyReward,
        [NetMsg_ID.ID_C2S_CityOneKeyPatrolSet] = NetMsg_ID.ID_S2C_CityOneKeyPatrolSet,
        [NetMsg_ID.ID_C2S_CityTechUp] = NetMsg_ID.ID_S2C_CityTechUp,

        -- 军团
        [NetMsg_ID.ID_C2S_GetCorpList] = NetMsg_ID.ID_S2C_GetCorpList,        
        --[NetMsg_ID.ID_C2S_GetCorpMember] = NetMsg_ID.ID_S2C_GetCorpMember,
        [NetMsg_ID.ID_C2S_CreateCorp] = NetMsg_ID.ID_S2C_CreateCorp,
        [NetMsg_ID.ID_C2S_RequestJoinCorp] = NetMsg_ID.ID_S2C_RequestJoinCorp,
        [NetMsg_ID.ID_C2S_DeleteJoinCorp] = NetMsg_ID.ID_S2C_DeleteJoinCorp,
        [NetMsg_ID.ID_C2S_QuitCorp] = NetMsg_ID.ID_S2C_QuitCorp,
        [NetMsg_ID.ID_C2S_SearchCorp] = NetMsg_ID.ID_S2C_SearchCorp,
        [NetMsg_ID.ID_C2S_ExchangeLeader] = NetMsg_ID.ID_S2C_ExchangeLeader,
        [NetMsg_ID.ID_C2S_ConfirmJoinCorp] = NetMsg_ID.ID_S2C_ConfirmJoinCorp,
        [NetMsg_ID.ID_C2S_ModifyCorp] = NetMsg_ID.ID_S2C_ModifyCorp,
        [NetMsg_ID.ID_C2S_DismissCorpMember] = NetMsg_ID.ID_S2C_DismissCorpMember,
        [NetMsg_ID.ID_C2S_GetCorpJoin] = NetMsg_ID.ID_S2C_GetCorpJoin,
        [NetMsg_ID.ID_C2S_DismissCorp] = NetMsg_ID.ID_S2C_DismissCorp,
        [NetMsg_ID.ID_C2S_CorpStaff] = NetMsg_ID.ID_S2C_CorpStaff,
        [NetMsg_ID.ID_C2S_GetCorpWorship] = NetMsg_ID.ID_S2C_GetCorpWorship,
        [NetMsg_ID.ID_C2S_CorpContribute] = NetMsg_ID.ID_S2C_CorpContribute,
        [NetMsg_ID.ID_C2S_GetCorpContributeAward] = NetMsg_ID.ID_S2C_GetCorpContributeAward,
        [NetMsg_ID.ID_C2S_GetCorpSpecialShop] = NetMsg_ID.ID_S2C_GetCorpSpecialShop,
        [NetMsg_ID.ID_C2S_CorpSpecialShopping] = NetMsg_ID.ID_S2C_CorpSpecialShopping,

        [NetMsg_ID.ID_C2S_ExecuteCorpDungeon] = NetMsg_ID.ID_S2C_ExecuteCorpDungeon,
        [NetMsg_ID.ID_C2S_SetCorpChapterId] = NetMsg_ID.ID_S2C_SetCorpChapterId,
        [NetMsg_ID.ID_C2S_GetDungeonAward] = NetMsg_ID.ID_S2C_GetDungeonAward,
        [NetMsg_ID.ID_C2S_GetDungeonCorpRank] = NetMsg_ID.ID_S2C_GetDungeonCorpRank,
        [NetMsg_ID.ID_C2S_GetDungeonCorpMemberRank] = NetMsg_ID.ID_S2C_GetDungeonCorpMemberRank,
        [NetMsg_ID.ID_C2S_GetCorpDungeonInfo] = NetMsg_ID.ID_S2C_GetCorpDungeonInfo,

        [NetMsg_ID.ID_C2S_GetDungeonAwardCorpPoint] = NetMsg_ID.ID_S2C_GetDungeonAwardCorpPoint,

        [NetMsg_ID.ID_C2S_GetNewCorpChapter] = NetMsg_ID.ID_S2C_GetNewCorpChapter,
        [NetMsg_ID.ID_C2S_GetNewCorpDungeonInfo] = NetMsg_ID.ID_S2C_GetNewCorpDungeonInfo,
        [NetMsg_ID.ID_C2S_ExecuteNewCorpDungeon] = NetMsg_ID.ID_S2C_ExecuteNewCorpDungeon,
        [NetMsg_ID.ID_C2S_GetNewDungeonAwardList] = NetMsg_ID.ID_S2C_GetNewDungeonAwardList,
        [NetMsg_ID.ID_C2S_GetNewDungeonAward] = NetMsg_ID.ID_S2C_GetNewDungeonAward,
        [NetMsg_ID.ID_C2S_GetNewDungeonCorpMemberRank] = NetMsg_ID.ID_S2C_GetNewDungeonCorpMemberRank,
        [NetMsg_ID.ID_C2S_ResetNewDungeonCount] = NetMsg_ID.ID_S2C_ResetNewDungeonCount,
        [NetMsg_ID.ID_C2S_GetNewChapterAward] = NetMsg_ID.ID_S2C_GetNewChapterAward,
        [NetMsg_ID.ID_C2S_GetNewDungeonAwardHint] = NetMsg_ID.ID_S2C_GetNewDungeonAwardHint,
        [NetMsg_ID.ID_C2S_SetNewCorpRollbackChapter] = NetMsg_ID.ID_S2C_SetNewCorpRollbackChapter,

        [NetMsg_ID.ID_C2S_DevelopCorpTech] = NetMsg_ID.ID_S2C_DevelopCorpTech,
        [NetMsg_ID.ID_C2S_LearnCorpTech] = NetMsg_ID.ID_S2C_LearnCorpTech,
        [NetMsg_ID.ID_C2S_CorpUpLevel] = NetMsg_ID.ID_S2C_CorpUpLevel,

        -- 跨服战
        [NetMsg_ID.ID_C2S_GetCorpCrossBattleInfo] = NetMsg_ID.ID_S2C_GetCorpCrossBattleInfo,
        [NetMsg_ID.ID_C2S_ApplyCorpCrossBattle] = NetMsg_ID.ID_S2C_ApplyCorpCrossBattle,
        [NetMsg_ID.ID_C2S_QuitCorpCrossBattle] = NetMsg_ID.ID_S2C_QuitCorpCrossBattle,
        [NetMsg_ID.ID_C2S_GetCorpCrossBattleList] = NetMsg_ID.ID_S2C_GetCorpCrossBattleList,
        [NetMsg_ID.ID_C2S_GetCrossBattleEncourage] = NetMsg_ID.ID_S2C_GetCrossBattleEncourage,
        [NetMsg_ID.ID_C2S_CrossBattleEncourage] = NetMsg_ID.ID_S2C_CrossBattleEncourage,
        [NetMsg_ID.ID_C2S_GetCrossBattleField] = NetMsg_ID.ID_S2C_GetCrossBattleField,
        [NetMsg_ID.ID_C2S_GetCrossBattleEnemyCorp] = NetMsg_ID.ID_S2C_GetCrossBattleEnemyCorp,
        [NetMsg_ID.ID_C2S_ResetCrossBattleChallengeCD] = NetMsg_ID.ID_S2C_ResetCrossBattleChallengeCD,
        [NetMsg_ID.ID_C2S_SetCrossBattleFireOn] = NetMsg_ID.ID_S2C_SetCrossBattleFireOn,
        [NetMsg_ID.ID_C2S_CrossBattleMemberRank] = NetMsg_ID.ID_S2C_CrossBattleMemberRank,
        [NetMsg_ID.ID_C2S_CrossBattleChallengeEnemy] = NetMsg_ID.ID_S2C_CrossBattleChallengeEnemy,


        --时装
        [NetMsg_ID.ID_C2S_AddFightDress] = NetMsg_ID.ID_S2C_AddFightDress,    
        [NetMsg_ID.ID_C2S_ClearFightDress] = NetMsg_ID.ID_S2C_ClearFightDress,    
        [NetMsg_ID.ID_C2S_UpgradeDress] = NetMsg_ID.ID_S2C_UpgradeDress,  
        [NetMsg_ID.ID_C2S_RecycleDress] = NetMsg_ID.ID_S2C_RecycleDress,  

        --军团商店
        [NetMsg_ID.ID_C2S_GetCorpSpecialShop] = NetMsg_ID.ID_S2C_GetCorpSpecialShop,  
        [NetMsg_ID.ID_C2S_CorpSpecialShopping] = NetMsg_ID.ID_S2C_CorpSpecialShopping,  

        --可配置活动
        [NetMsg_ID.ID_C2S_GetCustomActivityAward] = NetMsg_ID.ID_S2C_GetCustomActivityAward,  

        --新手光环
        [NetMsg_ID.ID_C2S_RookieInfo] = NetMsg_ID.ID_S2C_RookieInfo,  
        [NetMsg_ID.ID_C2S_GetRookieReward] = NetMsg_ID.ID_S2C_GetRookieReward,  

        --设置头像框
        [NetMsg_ID.ID_C2S_SetPictureFrame] = NetMsg_ID.ID_S2C_SetPictureFrame,  
        
        -- 微信分享
        [NetMsg_ID.ID_C2S_GetShareState] = NetMsg_ID.ID_S2C_GetShareState,
        [NetMsg_ID.ID_C2S_Share] = NetMsg_ID.ID_S2C_Share,

        [NetMsg_ID.ID_C2S_GetRechargeBack] = NetMsg_ID.ID_S2C_GetRechargeBack,
        [NetMsg_ID.ID_C2S_RechargeBackGold] = NetMsg_ID.ID_S2C_RechargeBackGold,
        [NetMsg_ID.ID_C2S_GetPhoneBindNotice] = NetMsg_ID.ID_S2C_GetPhoneBindNotice,

        -- 精英副本
        [NetMsg_ID.ID_C2S_Hard_GetChapterList] = NetMsg_ID.ID_S2C_Hard_GetChapterList,
        [NetMsg_ID.ID_C2S_Hard_FastExecuteStage] = NetMsg_ID.ID_S2C_Hard_FastExecuteStage,
        [NetMsg_ID.ID_C2S_Hard_GetChapterRank] = NetMsg_ID.ID_S2C_Hard_GetChapterRank,
        [NetMsg_ID.ID_C2S_Hard_ExecuteMultiStage] = NetMsg_ID.ID_S2C_Hard_ExecuteMultiStage,
        [NetMsg_ID.ID_C2S_Hard_ExecuteStage] = {NetMsg_ID.ID_S2C_Hard_ExecuteMultiStage, NetMsg_ID.ID_S2C_Hard_ExecuteStage},
        [NetMsg_ID.ID_C2S_Hard_FinishChapterBoxRwd] = NetMsg_ID.ID_S2C_Hard_FinishChapterBoxRwd,
        [NetMsg_ID.ID_C2S_Hard_ResetDungeonExecution] = NetMsg_ID.ID_S2C_Hard_ResetDungeonExecution,
        [NetMsg_ID.ID_C2S_Hard_FirstEnterChapter] = NetMsg_ID.ID_S2C_Hard_FirstEnterChapter,

        --轮盘
        [NetMsg_ID.ID_C2S_WheelInfo] = NetMsg_ID.ID_S2C_WheelInfo,
        [NetMsg_ID.ID_C2S_PlayWheel] = NetMsg_ID.ID_S2C_PlayWheel,
        [NetMsg_ID.ID_C2S_WheelReward] = NetMsg_ID.ID_S2C_WheelReward,
        [NetMsg_ID.ID_C2S_WheelRankingList] = NetMsg_ID.ID_S2C_WheelRankingList,

        --大富翁
        [NetMsg_ID.ID_C2S_RichInfo] = NetMsg_ID.ID_S2C_RichInfo,
        [NetMsg_ID.ID_C2S_RichMove] = NetMsg_ID.ID_S2C_RichMove,
        [NetMsg_ID.ID_C2S_RichReward] = NetMsg_ID.ID_S2C_RichReward,
        [NetMsg_ID.ID_C2S_RichRankingList] = NetMsg_ID.ID_S2C_RichRankingList,
        [NetMsg_ID.ID_C2S_RichBuy] = NetMsg_ID.ID_S2C_RichBuy,

        [NetMsg_ID.ID_C2S_RCardInfo] = NetMsg_ID.ID_S2C_RCardInfo,
        [NetMsg_ID.ID_C2S_PlayRCard] = NetMsg_ID.ID_S2C_PlayRCard,
        [NetMsg_ID.ID_C2S_ResetRCard] = NetMsg_ID.ID_S2C_ResetRCard,
        
        -- 觉醒相关
        [NetMsg_ID.ID_C2S_ComposeAwakenItem] = NetMsg_ID.ID_S2C_ComposeAwakenItem,
        [NetMsg_ID.ID_C2S_FastComposeAwakenItem] = NetMsg_ID.ID_S2C_FastComposeAwakenItem,
        [NetMsg_ID.ID_C2S_PutonAwakenItem] = NetMsg_ID.ID_S2C_PutonAwakenItem,
        [NetMsg_ID.ID_C2S_AwakenKnight] = NetMsg_ID.ID_S2C_AwakenKnight,
        
        [NetMsg_ID.ID_C2S_AwakenShopInfo] = NetMsg_ID.ID_S2C_AwakenShopInfo,
        [NetMsg_ID.ID_C2S_AwakenShopRefresh] = NetMsg_ID.ID_S2C_AwakenShopRefresh,
        
        -- 觉醒商店相关
        [NetMsg_ID.ID_C2S_AwakenShopInfo] = NetMsg_ID.ID_S2C_AwakenShopInfo,
        [NetMsg_ID.ID_C2S_AwakenShopRefresh] = NetMsg_ID.ID_S2C_AwakenShopRefresh,
        
        -- 跨服演武
        [NetMsg_ID.ID_C2S_GetCrossBattleInfo] = NetMsg_ID.ID_S2C_GetCrossBattleInfo,
        [NetMsg_ID.ID_C2S_GetCrossBattleTime] = NetMsg_ID.ID_S2C_GetCrossBattleTime,
        -- [NetMsg_ID.ID_C2S_GetCrossBattleGroup] = NetMsg_ID.ID_S2C_GetCrossBattleGroup,
        [NetMsg_ID.ID_C2S_SelectCrossBattleGroup] = NetMsg_ID.ID_S2C_SelectCrossBattleGroup,
        [NetMsg_ID.ID_C2S_EnterScoreBattle] = NetMsg_ID.ID_S2C_EnterScoreBattle,
        [NetMsg_ID.ID_C2S_GetCrossBattleEnemy] = NetMsg_ID.ID_S2C_GetCrossBattleEnemy,
        [NetMsg_ID.ID_C2S_ChallengeCrossBattleEnemy] = NetMsg_ID.ID_S2C_ChallengeCrossBattleEnemy,
        [NetMsg_ID.ID_C2S_GetWinsAwardInfo] = NetMsg_ID.ID_S2C_GetWinsAwardInfo,
        [NetMsg_ID.ID_C2S_FinishWinsAward] = NetMsg_ID.ID_S2C_FinishWinsAward,
        [NetMsg_ID.ID_C2S_GetCrossBattleRank] = NetMsg_ID.ID_S2C_GetCrossBattleRank,
        [NetMsg_ID.ID_C2S_CrossCountReset] = NetMsg_ID.ID_S2C_CrossCountReset,

        [NetMsg_ID.ID_C2S_GetCrossArenaInfo] = NetMsg_ID.ID_S2C_GetCrossArenaInfo,
        [NetMsg_ID.ID_C2S_GetCrossArenaInvitation] = NetMsg_ID.ID_S2C_GetCrossArenaInvitation,
        [NetMsg_ID.ID_C2S_GetCrossArenaBetsInfo] = NetMsg_ID.ID_S2C_GetCrossArenaBetsInfo,
        [NetMsg_ID.ID_C2S_GetCrossArenaBetsList] = NetMsg_ID.ID_S2C_GetCrossArenaBetsList,
        [NetMsg_ID.ID_C2S_CrossArenaPlayBets] = NetMsg_ID.ID_S2C_CrossArenaPlayBets,
        [NetMsg_ID.ID_C2S_CrossArenaAddBets] = NetMsg_ID.ID_S2C_CrossArenaAddBets,
        [NetMsg_ID.ID_C2S_GetCrossArenaRankTop] = NetMsg_ID.ID_S2C_GetCrossArenaRankTop,
        [NetMsg_ID.ID_C2S_GetCrossArenaRankUser] = NetMsg_ID.ID_S2C_GetCrossArenaRankUser,
        [NetMsg_ID.ID_C2S_CrossArenaRankChallenge] = NetMsg_ID.ID_S2C_CrossArenaRankChallenge,
        [NetMsg_ID.ID_C2S_CrossArenaCountReset] = NetMsg_ID.ID_S2C_CrossArenaCountReset,
        [NetMsg_ID.ID_C2S_CrossArenaServerAwardInfo] = NetMsg_ID.ID_S2C_CrossArenaServerAwardInfo,
        [NetMsg_ID.ID_C2S_FinishCrossArenaServerAward] = NetMsg_ID.ID_S2C_FinishCrossArenaServerAward,
        [NetMsg_ID.ID_C2S_GetCrossArenaBetsAward] = NetMsg_ID.ID_S2C_GetCrossArenaBetsAward,
        [NetMsg_ID.ID_C2S_FinishCrossArenaBetsAward] = NetMsg_ID.ID_S2C_FinishCrossArenaBetsAward,
        [NetMsg_ID.ID_C2S_GetCrossUserDetail] = NetMsg_ID.ID_S2C_GetCrossUserDetail,

        -- 限时挑战
        [NetMsg_ID.ID_C2S_GetTimeDungeonList] = NetMsg_ID.ID_S2C_GetTimeDungeonList,
        [NetMsg_ID.ID_C2S_GetTimeDungeonInfo] = NetMsg_ID.ID_S2C_GetTimeDungeonInfo,
        [NetMsg_ID.ID_C2S_AddTimeDungeonBuff] = NetMsg_ID.ID_S2C_AddTimeDungeonBuff,
        [NetMsg_ID.ID_C2S_AttackTimeDungeon] = NetMsg_ID.ID_S2C_AttackTimeDungeon,

        -- 精英暴动
        [NetMsg_ID.ID_C2S_Hard_GetChapterRoit] = NetMsg_ID.ID_S2C_Hard_GetChapterRoit,
        [NetMsg_ID.ID_C2S_Hard_FinishChapterRoit] = NetMsg_ID.ID_S2C_Hard_FinishChapterRoit,

        
        -- 世界boss
        [NetMsg_ID.ID_C2S_EnterRebelBossUI] = NetMsg_ID.ID_S2C_EnterRebelBossUI,
        [NetMsg_ID.ID_C2S_SelectAttackRebelBossGroup] = NetMsg_ID.ID_S2C_SelectAttackRebelBossGroup,
        [NetMsg_ID.ID_C2S_ChallengeRebelBoss] = NetMsg_ID.ID_S2C_ChallengeRebelBoss,
        [NetMsg_ID.ID_C2S_RebelBossRank] = NetMsg_ID.ID_S2C_RebelBossRank,
        [NetMsg_ID.ID_C2S_RebelBossAwardInfo] = NetMsg_ID.ID_S2C_RebelBossAwardInfo,
        [NetMsg_ID.ID_C2S_RebelBossAward] = NetMsg_ID.ID_S2C_RebelBossAward,
        [NetMsg_ID.ID_C2S_RefreshRebelBoss] = NetMsg_ID.ID_S2C_RefreshRebelBoss,
        [NetMsg_ID.ID_C2S_PurchaseAttackCount] = NetMsg_ID.ID_S2C_PurchaseAttackCount,
        [NetMsg_ID.ID_C2S_GetRebelBossReport] = NetMsg_ID.ID_S2C_GetRebelBossReport,
        [NetMsg_ID.ID_C2S_RebelBossCorpAwardInfo] = NetMsg_ID.ID_S2C_RebelBossCorpAwardInfo,
        [NetMsg_ID.ID_C2S_FlushBossACountTime] = NetMsg_ID.ID_S2C_FlushBossACountTime,

        --百战沙场
        [NetMsg_ID.ID_C2S_GetBattleFieldInfo] = NetMsg_ID.ID_S2C_GetBattleFieldInfo,
        [NetMsg_ID.ID_C2S_BattleFieldDetail] = NetMsg_ID.ID_S2C_BattleFieldDetail,
        [NetMsg_ID.ID_C2S_ChallengeBattleField] = NetMsg_ID.ID_S2C_ChallengeBattleField,
        [NetMsg_ID.ID_C2S_BattleFieldAwardInfo] = NetMsg_ID.ID_S2C_BattleFieldAwardInfo,
        [NetMsg_ID.ID_C2S_GetBattleFieldAward] = NetMsg_ID.ID_S2C_GetBattleFieldAward,
        [NetMsg_ID.ID_C2S_BattleFieldShopInfo] = NetMsg_ID.S2C_BattleFieldShopInfo,
        [NetMsg_ID.ID_C2S_BattleFieldShopRefresh] = NetMsg_ID.ID_S2C_BattleFieldShopRefresh,
        [NetMsg_ID.ID_C2S_GetBattleFieldRank] = NetMsg_ID.ID_S2C_GetBattleFieldRank,


        -- 限时优惠
        [NetMsg_ID.ID_C2S_ShopTimeInfo] = NetMsg_ID.ID_S2C_ShopTimeInfo,
        [NetMsg_ID.ID_C2S_ShopTimeRewardInfo] = NetMsg_ID.ID_S2C_ShopTimeRewardInfo,
        [NetMsg_ID.ID_C2S_ShopTimeGetReward] = NetMsg_ID.ID_S2C_ShopTimeGetReward,
        [NetMsg_ID.ID_C2S_ShopTimeStartTime] = NetMsg_ID.ID_S2C_ShopTimeStartTime,

        -- 夺粮战 
        [NetMsg_ID.ID_C2S_RobRice] = NetMsg_ID.ID_S2C_RobRice, 
        [NetMsg_ID.ID_C2S_RevengeRiceEnemy] = NetMsg_ID.ID_S2C_RevengeRiceEnemy,       
        [NetMsg_ID.ID_C2S_GetRiceAchievement] = NetMsg_ID.ID_S2C_GetRiceAchievement,        
        [NetMsg_ID.ID_C2S_GetRiceRankAward] = NetMsg_ID.ID_S2C_GetRiceRankAward,        
        [NetMsg_ID.ID_C2S_BuyRiceToken] = NetMsg_ID.ID_S2C_BuyRiceToken,
        [NetMsg_ID.ID_C2S_FlushRiceRivals] = NetMsg_ID.ID_S2C_FlushRiceRivals,
        
        
        -- 橙将变身
        [NetMsg_ID.ID_C2S_KnightTransform] = NetMsg_ID.ID_S2C_KnightTransform,

        -- 限时抽将
        [NetMsg_ID.ID_C2S_ThemeDropZY] = NetMsg_ID.ID_S2C_ThemeDropZY,
        [NetMsg_ID.ID_C2S_ThemeDropAstrology] = NetMsg_ID.ID_S2C_ThemeDropAstrology,
        [NetMsg_ID.ID_C2S_ThemeDropExtract] = NetMsg_ID.ID_S2C_ThemeDropExtract,

        -- 三国无双精英boss
        [NetMsg_ID.ID_C2S_WushBossInfo] = NetMsg_ID.ID_S2C_WushBossInfo,
        [NetMsg_ID.ID_C2S_WushBossChallenge] = NetMsg_ID.ID_S2C_WushBossChallenge,
        [NetMsg_ID.ID_C2S_WushBossBuy] = NetMsg_ID.ID_S2C_WushBossBuy,
        
        -- 限时团购
        [NetMsg_ID.ID_C2S_GetGroupBuyMainInfo]      = NetMsg_ID.ID_S2C_GetGroupBuyMainInfo,
        [NetMsg_ID.ID_C2S_GetGroupBuyRanking]       = NetMsg_ID.ID_S2C_GetGroupBuyRanking,
        [NetMsg_ID.ID_C2S_GetGroupBuyTaskAwardInfo] = NetMsg_ID.ID_S2C_GetGroupBuyTaskAwardInfo,
        [NetMsg_ID.ID_C2S_GetGroupBuyTaskAward]     = NetMsg_ID.ID_S2C_GetGroupBuyTaskAward,
        [NetMsg_ID.ID_C2S_GetGroupBuyEndInfo]       = NetMsg_ID.ID_S2C_GetGroupBuyEndInfo,
        [NetMsg_ID.ID_C2S_GetGroupBuyRankAward]     = NetMsg_ID.ID_S2C_GetGroupBuyRankAward,
        [NetMsg_ID.ID_C2S_GroupBuyPurchaseGoods]    = NetMsg_ID.ID_S2C_GroupBuyPurchaseGoods,

        -- 新版日常副本
        [NetMsg_ID.ID_C2S_DungeonDailyInfo] = NetMsg_ID.ID_S2C_DungeonDailyInfo,
        [NetMsg_ID.ID_C2S_DungeonDailyChallenge] = NetMsg_ID.ID_S2C_DungeonDailyChallenge,

        -- 战宠
        [NetMsg_ID.ID_C2S_RecyclePet] = NetMsg_ID.ID_S2C_RecyclePet,
        [NetMsg_ID.ID_C2S_PetUpLvl] = NetMsg_ID.ID_S2C_PetUpLvl,
        [NetMsg_ID.ID_C2S_PetUpStar] = NetMsg_ID.ID_S2C_PetUpStar,
        [NetMsg_ID.ID_C2S_PetUpAddition] = NetMsg_ID.ID_S2C_PetUpAddition,
        [NetMsg_ID.ID_C2S_ChangeFightPet] = NetMsg_ID.ID_S2C_ChangeFightPet,

        --奇门八卦
        [NetMsg_ID.ID_C2S_TrigramInfo] = NetMsg_ID.ID_S2C_TrigramInfo,
        [NetMsg_ID.ID_C2S_TrigramPlay] = NetMsg_ID.ID_S2C_TrigramPlay,
        [NetMsg_ID.ID_C2S_TrigramPlayAll] = NetMsg_ID.ID_S2C_TrigramPlayAll,
        [NetMsg_ID.ID_C2S_TrigramRefresh] = NetMsg_ID.ID_S2C_TrigramRefreshn,
        [NetMsg_ID.ID_C2S_TrigramReward] = NetMsg_ID.ID_S2C_TrigramReward,
        [NetMsg_ID.ID_C2S_GetTrigramRank] = NetMsg_ID.ID_S2C_GetTrigramRank,

        -- 跨服夺帅
        [NetMsg_ID.ID_C2S_GetCrossPvpSchedule]      = NetMsg_ID.ID_S2C_GetCrossPvpSchedule,
        [NetMsg_ID.ID_C2S_GetCrossPvpBaseInfo]      = NetMsg_ID.ID_S2C_GetCrossPvpBaseInfo,
        [NetMsg_ID.ID_C2S_GetCrossPvpScheduleInfo]  = NetMsg_ID.ID_S2C_GetCrossPvpScheduleInfo,
        [NetMsg_ID.ID_C2S_ApplyCrossPvp]            = NetMsg_ID.ID_S2C_ApplyCrossPvp,
        [NetMsg_ID.ID_C2S_ApplyAtcAndDefCrossPvp]   = NetMsg_ID.ID_S2C_ApplyAtcAndDefCrossPvp,
        [NetMsg_ID.ID_C2S_GetCrossPvpOb]            = NetMsg_ID.ID_S2C_GetCrossPvpOb,
        [NetMsg_ID.ID_C2S_GetCrossPvpRole]          = NetMsg_ID.ID_S2C_GetCrossPvpRole,
        [NetMsg_ID.ID_C2S_GetCrossPvpArena]         = NetMsg_ID.ID_S2C_GetCrossPvpArena,
    --    [NetMsg_ID.ID_C2S_GetCrossPvpRank]          = NetMsg_ID.ID_S2C_GetCrossPvpRank,
        [NetMsg_ID.ID_C2S_CrossPvpBattle]           = NetMsg_ID.ID_S2C_CrossPvpBattle,
        [NetMsg_ID.ID_C2S_GetCrossPvpDetail]        = NetMsg_ID.ID_S2C_GetCrossPvpDetail,
        [NetMsg_ID.ID_C2S_CrossPvpGetAward]         = NetMsg_ID.ID_S2C_CrossPvpGetAward,
        [NetMsg_ID.ID_C2S_CrossWaitInit]            = NetMsg_ID.ID_S2C_CrossWaitInit,
        [NetMsg_ID.ID_C2S_CrossWaitRank]            = NetMsg_ID.ID_S2C_CrossWaitRank,
        [NetMsg_ID.ID_C2S_CrossWaitFlower]          = NetMsg_ID.ID_S2C_CrossWaitFlower,
        [NetMsg_ID.ID_C2S_CrossWaitFlowerRank]      = NetMsg_ID.ID_S2C_CrossWaitFlowerRank,
        [NetMsg_ID.ID_C2S_CrossWaitFlowerAward]     = NetMsg_ID.ID_S2C_CrossWaitFlowerAward,
        [NetMsg_ID.ID_C2S_CrossWaitInitFlowerInfo]  = NetMsg_ID.ID_S2C_CrossWaitInitFlowerInfo,
        [NetMsg_ID.ID_C2S_GetBulletScreenInfo]      = NetMsg_ID.ID_S2C_GetBulletScreenInfo,
        [NetMsg_ID.ID_C2S_SendBulletScreenInfo]     = NetMsg_ID.ID_S2C_SendBulletScreenInfo,

        -- 道具合成
        [NetMsg_ID.ID_C2S_ItemCompose]      = NetMsg_ID.ID_S2C_ItemCompose,

        --战宠护佑
        [NetMsg_ID.ID_C2S_GetPetProtect]      = NetMsg_ID.ID_S2C_GetPetProtect,
        [NetMsg_ID.ID_C2S_SetPetProtect]      = NetMsg_ID.ID_S2C_SetPetProtect,

        --中秋活动
        [NetMsg_ID.ID_C2S_GetSpecialHolidayActivity]      = NetMsg_ID.ID_S2C_GetSpecialHolidayActivity,
        [NetMsg_ID.ID_C2S_GetSpecialHolidayActivityReward]      = NetMsg_ID.ID_S2C_GetSpecialHolidayActivityReward,
        [NetMsg_ID.ID_C2S_GetSpecialHolidaySales]      = NetMsg_ID.ID_S2C_GetSpecialHolidaySales,
        [NetMsg_ID.ID_C2S_BuySpecialHolidaySale]      = NetMsg_ID.ID_S2C_BuySpecialHolidaySale,

        --日常pvp
        [NetMsg_ID.ID_C2S_TeamPVPStatus]      = NetMsg_ID.ID_S2C_TeamPVPStatus,
        [NetMsg_ID.ID_C2S_TeamPVPCreateTeam]      = NetMsg_ID.ID_S2C_TeamPVPCreateTeam,
        [NetMsg_ID.ID_C2S_TeamPVPJoinTeam]      = NetMsg_ID.ID_S2C_TeamPVPJoinTeam,
        [NetMsg_ID.ID_C2S_TeamPVPLeave]      = NetMsg_ID.ID_S2C_TeamPVPLeave,
        [NetMsg_ID.ID_C2S_TeamPVPKickTeamMember]      = NetMsg_ID.ID_S2C_TeamPVPKickTeamMember,
        [NetMsg_ID.ID_C2S_TeamPVPSetTeamOnlyInvited]      = NetMsg_ID.ID_S2C_TeamPVPSetTeamOnlyInvited,
        [NetMsg_ID.ID_C2S_TeamPVPInvite]      = NetMsg_ID.ID_S2C_TeamPVPInvite,
        [NetMsg_ID.ID_C2S_TeamPVPInvitedJoinTeam]      = NetMsg_ID.ID_S2C_TeamPVPInvitedJoinTeam,
        [NetMsg_ID.ID_C2S_TeamPVPInviteNPC]      = NetMsg_ID.ID_S2C_TeamPVPInviteNPC,
        [NetMsg_ID.ID_C2S_TeamPVPAgreeBattle]      = NetMsg_ID.ID_S2C_TeamPVPAgreeBattle,
        [NetMsg_ID.ID_C2S_TeamPVPMatchOtherTeam]      = NetMsg_ID.ID_S2C_TeamPVPMatchOtherTeam,
        [NetMsg_ID.ID_C2S_TeamPVPChangePosition]      = NetMsg_ID.ID_S2C_TeamPVPChangePosition,
        [NetMsg_ID.ID_C2S_TeamPVPStopMatch]      = NetMsg_ID.ID_S2C_TeamPVPStopMatch,
        [NetMsg_ID.ID_C2S_TeamPVPAcceptInvite]      = NetMsg_ID.ID_S2C_TeamPVPAcceptInvite,
        [NetMsg_ID.ID_C2S_TeamPVPHistoryBattleReport]      = NetMsg_ID.ID_S2C_TeamPVPHistoryBattleReportEnd,
        [NetMsg_ID.ID_C2S_TeamPVPGetRank]      = NetMsg_ID.ID_S2C_TeamPVPGetRank,
        [NetMsg_ID.ID_C2S_TeamPVPGetUserInfo]      = NetMsg_ID.ID_S2C_TeamPVPGetUserInfo,
        [NetMsg_ID.ID_C2S_TeamPVPBuyAwardCnt]      = NetMsg_ID.ID_S2C_TeamPVPBuyAwardCnt,
        [NetMsg_ID.ID_C2S_TeamPVPPopChat]      = NetMsg_ID.ID_S2C_TeamPVPPopChat,
        
        -- 过关斩将
        [NetMsg_ID.ID_C2S_GetExpansiveDungeonChapterList]      = NetMsg_ID.ID_S2C_GetExpansiveDungeonChapterList,
        [NetMsg_ID.ID_C2S_ExcuteExpansiveDungeonStage]         = NetMsg_ID.ID_S2C_ExcuteExpansiveDungeonStage,
        [NetMsg_ID.ID_C2S_GetExpansiveDungeonChapterReward]    = NetMsg_ID.ID_S2C_GetExpansiveDungeonChapterReward,
        [NetMsg_ID.ID_C2S_FirstEnterExpansiveDungeonChapter]   = NetMsg_ID.ID_S2C_FirstEnterExpansiveDungeonChapter,
        [NetMsg_ID.ID_C2S_PurchaseExpansiveDungeonShopItem]    = NetMsg_ID.ID_S2C_PurchaseExpansiveDungeonShopItem,

        
        
        -- 武将化神
        [NetMsg_ID.ID_C2S_KnightOrangeToRed]      = NetMsg_ID.ID_S2C_KnightOrangeToRed,

        -- 老玩家回归
        [NetMsg_ID.ID_C2S_GetOlderPlayerInfo]       = NetMsg_ID.ID_S2C_GetOlderPlayerInfo,
        [NetMsg_ID.ID_C2S_GetOlderPlayerVipAward]   = NetMsg_ID.ID_S2C_GetOlderPlayerVipAward,
        [NetMsg_ID.ID_C2S_GetOlderPlayerLevelAward] = NetMsg_ID.ID_S2C_GetOlderPlayerLevelAward,
        [NetMsg_ID.ID_C2S_GetOlderPlayerVipExp]     = NetMsg_ID.ID_S2C_GetOlderPlayerVipExp,

        -- 觉醒道具标记
        [NetMsg_ID.ID_C2S_GetShopTag]  =  NetMsg_ID.ID_S2C_GetShopTag,
        [NetMsg_ID.ID_C2S_AddShopTag]  =  NetMsg_ID.ID_S2C_AddShopTag,
        [NetMsg_ID.ID_C2S_DelShopTag]  =  NetMsg_ID.ID_S2C_DelShopTag,

        -- 改名功能
        [NetMsg_ID.ID_C2S_ChangeName] = NetMsg_ID.ID_S2C_ChangeName,
        -- 开服7日战力榜领奖协议
        [NetMsg_ID.ID_C2S_GetDays7CompAward] = NetMsg_ID.ID_S2C_GetDays7CompAward,
		[NetMsg_ID.ID_C2S_SetClothSwitch]  =  NetMsg_ID.ID_S2C_SetClothSwitch,
        -- 将灵
        [NetMsg_ID.ID_C2S_GetKsoul] = NetMsg_ID.ID_S2C_GetKsoul,
        [NetMsg_ID.ID_C2S_RecycleKsoul] = NetMsg_ID.ID_S2C_RecycleKsoul,
        [NetMsg_ID.ID_C2S_ActiveKsoulGroup] = NetMsg_ID.ID_S2C_ActiveKsoulGroup,
        [NetMsg_ID.ID_C2S_ActiveKsoulTarget] = NetMsg_ID.ID_S2C_ActiveKsoulTarget,
        [NetMsg_ID.ID_C2S_SummonKsoul] = NetMsg_ID.ID_S2C_SummonKsoul,
        [NetMsg_ID.ID_C2S_SummonKsoulExchange] = NetMsg_ID.ID_S2C_SummonKsoulExchange,

        [NetMsg_ID.ID_C2S_KsoulDungeonInfo] = NetMsg_ID.ID_S2C_KsoulDungeonInfo,
        [NetMsg_ID.ID_C2S_KsoulDungeonRefresh] = NetMsg_ID.ID_S2C_KsoulDungeonRefresh,
        [NetMsg_ID.ID_C2S_KsoulDungeonChallenge] = NetMsg_ID.ID_S2C_KsoulDungeonChallenge,

        [NetMsg_ID.ID_C2S_KsoulShopInfo] = NetMsg_ID.ID_S2C_KsoulShopInfo,
        [NetMsg_ID.ID_C2S_KsoulShopRefresh] = NetMsg_ID.ID_S2C_KsoulShopRefresh,
        [NetMsg_ID.ID_C2S_KsoulShopBuy] = NetMsg_ID.ID_S2C_KsoulShopBuy,
        [NetMsg_ID.ID_C2S_KsoulSetFightBase] = NetMsg_ID.ID_S2C_KsoulSetFightBase,

        [NetMsg_ID.ID_C2S_GetCommonRank] = NetMsg_ID.ID_S2C_GetCommonRank,

        -- 招财符
        [NetMsg_ID.ID_C2S_FortuneBuySilver] = NetMsg_ID.ID_S2C_FortuneBuySilver,
        [NetMsg_ID.ID_C2S_FortuneGetBox] = NetMsg_ID.ID_S2C_FortuneGetBox,
}

return MonitorProtocal