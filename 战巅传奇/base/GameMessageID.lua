local GameMessageID={

--注释掉的为已经弃用的消息

cReqAuthenticate = 0x7000,
cResAuthenticate = 0x7001,

cNotifyCharacterLoad = 0x7003,

cReqMapChat = 0x7010,
cResMapChat = 0x7011,
cNotifyMapChat = 0x7012,

cReqPrivateChat = 0x7020,
cResPrivateChat = 0x7021,
cNotifyPrivateChat = 0x7022,

cReqWalk = 0x7030,
cResWalk = 0x7031,
cNotifyWalk = 0x7032,

cReqRun = 0x7040,
cResRun = 0x7041,
cNotifyRun = 0x7042,

cReqNPCTalk = 0x7050,
cResNPCTalk = 0x7051,

cReqTurn = 0x7060,
cResTurn = 0x7061,
cNotifyTurn = 0x7062,

cReqAttack = 0x7070,
cResAttack = 0x7071,
cNotifyAttack = 0x7072,

cReqPickUp = 0x7080,
cResPickUp = 0x7081,

cReqBagUseItem = 0x7090,
cResBaguseItem = 0x7091,

cReqUndressItem = 0x70A0,
cResUndressItem = 0x70A1,

cReqItemPositionExchange = 0x70B0,
cResItemPositionExchange = 0x70B1,

cReqUseSkill = 0x70C0,
cResUseSkill = 0x70C1,
cNotifyUseSkill = 0x70C2,

cReqNPCShop = 0x70D0,
cResNPCShop = 0x70D1,

cReqNPCBuy = 0x70E0,
cResNPCBuy = 0x70E1,

cReqCancelTask = 0x70F0,

cReqForceMove = 0x7100,
cReqChangeCloth = 0x7110,

cReqListCharacter = 0x7120,
cResListCharacter = 0x7121,

cReqCreateCharacter = 0x7130,
cResCreateCharacter = 0x7131,

cReqEnterGame = 0x7140,
cResEnterGame = 0x7141,

cReqDeleteCharacter = 0x7150,
cResDeleteCharacter = 0x7151,

cReqNPCSell = 0x7160,
cResNPCSell = 0x7161,

cReqDropItem = 0x7170,
cResDropItem = 0x7171,

cReqListGuild = 0x7180,
cResListGuild = 0x7181,

cReqGetGuildInfo = 0x7190,
cResGetGuildInfo = 0x7191,

cReqSaveShortcut = 0x71A0,
cNotifyLoadShortcut = 0x71A2,

cReqCreateGuild = 0x71B0,
cResCreateGuild = 0x71B1,

cReqJoinGuild = 0x71C0,
cResJoinGuild = 0x71C1,

cReqSetGuildInfo = 0x71D0,
cResSetGuildInfo = 0x71D1,

cReqListGuildMember = 0x71E0,
cResListGuildMember = 0x71E1,
cNotifyGuildMemberChange = 0x71E2,

cReqListGuildEnemy = 0x71F0,
cResListGuildEnemy = 0x71F1,

cReqListGuildFriend = 0x7200,
cResListGuildFriend = 0x7201,

cReqChangeGuildMemberTitle = 0x7210,
cReqChangeEnemyGuild = 0x7220,
cReqChangeFriendGuild = 0x7230,

cReqGuildChat = 0x7240,
cResGuildChat = 0x7241,
cNotifyGuildChat = 0x7242,

cReqChangeAttackMode = 0x7250,
cResChangeAttackMode = 0x7251,

cReqVcoinShopList = 0x7260,
cResVcoinShopList = 0x7261,

cReqNPCRepair = 0x7280,
cResNPCRepair = 0x7281,

cReqRelive = 0x7290,
cResRelive = 0x7291,

cReqKuafuAuth = 0x72B0,
cResKuafuAuth = 0x72B1,

cReqTaskDesp = 0x7300,
cResTaskDesp = 0x7301,

cReqInfoPlayer = 0x7310,
cResInfoPlayer = 0x7311,

cReqCreateGroup = 0x7320,
cResCreateGroup = 0x7321,

cReqLeaveGroup = 0x7330,
cResLeaveGroup = 0x7331,

cReqJoinGroup = 0x7340,
cResJoinGroup = 0x7341,

cReqAgreeJoinGroup = 0x7350,
cResAgreeJoinGroup = 0x7351,

cReqInviteGroup = 0x7360,
cResInviteGroup = 0x7361,

cReqAgreeInviteGroup = 0x7370,
cResAgreeInviteGroup = 0x7371,

cReqTaskClick = 0x7380,

cReqGroupChat = 0x7390,
cResGroupChat = 0x7391,

cReqNormalChat = 0x7400,
cResNormalChat = 0x7401,

cReqTradeInvite = 0x7410,

cReqAgreeTradeInvite = 0x7420,

cReqCloseTrade = 0x7430,

cReqTradeAddGameMoney = 0x7440,

cReqTradeAddVcoin = 0x7450,

cReqTradeSubmit = 0x7460,

cReqGroupSetLeader = 0x7470,

cReqTradeAddItem = 0x7480,
cReqTradeBuyItem = 0x7481,

cReqDestoryItem = 0x7490,

cReqSortItem = 0x7500,

cReqItemTalk = 0x7510,

-- cReqMergeSteel = 0x7520,
-- cResMergeSteel = 0x7521,

-- cReqUpgradeEquip = 0x7530,
-- cResUpgradeEquip = 0x7531,

cReqWorldChat = 0x7540,
cResWorldChat = 0x7541,

cReqFreshVcoin = 0x7550,

cReqLeaveGuild = 0x7560,

cReqAddDepotSlot = 0x7570,

cReqGroupPickMode = 0x7580,

cReqSwithSlaveAIMode = 0x7590,

cReqPing = 0x7600,
cResPing = 0x7601,

cReqFreshHPMP = 0x7610,

cReqUpdateTicket = 0x7620,
cResUpdateTicket = 0x7621,

-- cReqUpdateChinaLimit = 0x7630,

-- cReqBuyOfflineExp = 0x7640,

-- cReqSteelEquip = 0x7650,

cReqPlayerTalk = 0x7660,

cReqGetChartInfo = 0x7670,
cResGetChartInfo = 0x7671,

-- cReqInfoItemExchange = 0x7680,
-- cResInfoItemExchange = 0x7681,

-- cReqItemExchange = 0x7690,
-- cResItemExchange = 0x7691,

cReqGetItemDesp = 0x7700,

cReqHornChat = 0x7710,
cResHornChat = 0x7711,
cNotifyHornChat = 0x7712,

cCountDownFinish = 0x7720,

cReqFriendChange = 0x7730,
cResFriendChange = 0x7731,

cResFriendApply = 0x7732,
cReqFriendApplyAgree = 0x7733,

cReqFriendFresh = 0x7740,
cResFriendFresh = 0x7741,

-- cReqEquipReRandAdd = 0x7750,
-- cResEquipReRandAdd = 0x7751,

-- cReqEquipExchangeUpgrade = 0x7760,
-- cResEquipExchangeUpgrade = 0x7761,

cReqServerScript = 0x7770,

cReqOpenRong = 0x7780,

cReqProtectItem = 0x7790,
cResProtectItem = 0x7791,

cReqGroupKickMember = 0x7800,

cReqFreshGift = 0x7810,

-- cReqMergeEquip = 0x7820,

cReqOpenAchieve = 0x7850,

cReqOpenPK = 0x7860,

cReqCollectStart = 0x7901,
cReqDirectFly = 0x7904,

cReqAddBagSlot = 0x7861,
-- cReqMarryInvite = 0x7870,
-- cNotifyMarryInvite = 0x7872,
cReqGetTaskList = 0x7873,
-- cNotifyDailyTaskList = 0x7874,
-- cNotifyInstanceTaskList = 0x7875,
-- cNotifyEverydayTaskList = 0x7876,
-- cNotifyBossFreshList = 0x7877,

cReqFindMapGhost = 0x7878,
cResFindMapGhost = 0x7879,

-- cReqAgreeOrNotMarryInvite = 0x7880,
-- cReqDivorceInvite = 0x7890,
-- cReqAgreeOrNotDivorceInvite = 0x7900,

-- cReqReincarnate = 0x7940,
-- cReqResetReinAttr = 0x7950,
-- cReqBuyReinTimes = 0x7960,
-- cReqUpdateReinAttr = 0x7970,

cReqChangeMount = 0x7980,

cReqPushLuaTable = 0x7910,
cNotifyPushLuaTable = 0x7911,

-- cReqAs2Lua = 0x79A0,
-- cNotifyLua2As = 0x79A2,

cReqUpEquipInfo = 0x79E0,
cNotifyUpEquipInfo = 0x79E2,

cReqUpEquipItem = 0x79F0,

cReqLoginFormAward = 0x7A00,

cReqChangeFashionShow = 0x7A10,

cReqMergeFashionEquip = 0x7A20,

cReqSplitItem = 0x7A30,

-- cReqAs2LuaInfo = 0x7A40,

cNotifyMapEnter = 0x7F00,
cNotifyMapMeet = 0x7F01,
cNotifyMapLeave = 0x7F02,
cNotifyMapBye = 0x7F03,
cNotifyInjury = 0x7F04,
cNotifyDie = 0x7F05,
cNotifyItemChange = 0x7F06,
cNotifyAvatarChange = 0x7F07,
cNotifySkillChange = 0x7F08,
cNotifyAttributeChange = 0x7F09,
cNotifyKuafuInfo = 0x7F0A,
cNotifyKuafuEnterMainServer = 0x7F0B,
cNotifyGameMoneyChange = 0x7F10,
cNotifyHPMPChange = 0x7F11,
cNotifyTaskChange = 0x7F12,
cNotifyExpChange = 0x7F13,
cNotifyLevelChange = 0x7F14,
cNotifyForceMove = 0x7F15,
cNotifyItemDesp = 0x7F17,
cNotifyGuildInfo = 0x7F18,
cNotifyGhostGuildInfo = 0x7F19,
cNotifyGhostMode = 0x7F20,
cNotifyAlert = 0x7F21,
cNotifyRelive = 0x7F22,
cNotifyGroupInfoChange = 0x7F23,
cNotifyGroupState = 0x7F24,
cNotifyGroupInfo = 0x7F25,
cNotifySkillDesp = 0x7F26,
cNotifyYouKeSessionID = 0x7F27,
cNotifyMapConn = 0x7F28,
cNotifyMapSafeArea = 0x7F29,
cNotifyNpcShowFlags = 0x7F30,
cNotifyJoinGroupToLeader = 0x7F31,
cNotifyInviteGroupToMember = 0x7F32,
cNotifyFindRoadGotoNotify = 0x7F33,
cNotifyGroupChat = 0x7F34,
cNotifyNoramlChat = 0x7F35,
cNotifyTradeInvite = 0x7F36,
cNotifyTradeInfo = 0x7F37,
cNotifyTradeItemChange = 0x7F38,
cNotifyMapItemOwner = 0x7F39,
cNotifyPKStateChange = 0x7F40,
cNotifyMonsterAddInfo = 0x7F41,
cNotifyStatusChange = 0x7F42,
cNotifyItemTalk = 0x7F43,
cNotifyPlayerAddInfo = 0x7F44,
cNotifyCountDown = 0x7F45,
cNotifyMiniMapConn = 0x7F46,
cNotifyPlayEffect = 0x7F47,
cNotifyGameParam = 0x7F48,
cNotifyInfoItemChange = 0x7F49,
cNotifyWorldChat = 0x7F50,
cNotifySessionClosed = 0x7F51,
cNotifySessionDelayReauth = 0x7F52,
cNotifyWarInfo = 0x7F53,
cNotifyMapOption = 0x7F54,
cNotifyGuildCondition = 0x7F55,
cNotifySlotAdd = 0x7F56,
cNotifyNameAdd = 0x7F57,
cNotifyURL = 0x7F58,
cNotifyFreeReliveLevel = 0x7F59,
cNotifyGUIShowTag = 0x7F60,
cNotifySetModel = 0x7F61,
cNotifyChinaLimitLv = 0x7F62,
cNotifyMonsterChat = 0x7F63,
cNotifyMapMiniNpc = 0x7F64,
cNotifyOfflineExpInfo = 0x7F65,
cNotifyTeamInfo = 0x7F66,
cNotifyPlayerTalk = 0x7F67,
cNotifyProsperityChange = 0x7F68,
-- cNotifyGUIOpenPanel = 0x7F69,
cNotifyBlackBoard = 0x7F70,
cNotifyListGuildBegin = 0x7F71,
cNotifyListGuildEnd = 0x7F72,
cNotifyListGuildItem = 0x7F73,
cNotifyItemPlusDesp = 0x7F74,
cNotifyItemPlusDespGroup = 0x7FF4,
-- cNotifyHighFocus = 0x7F75,
cNotifyGuiShowMergeEquip = 0x7F76,
cNotifyListTalkList = 0x7F77,
cNotifyListTalkContent = 0x7F78,
cNotifyListTalkTitle = 0x7F79,
cNotifyAchieveDone = 0x7F80,
cNotifyPKConfirm = 0x7F81,
-- cNotifyEnterMarryInvite = 0x7F83,
-- cNotifyDivorceInvite = 0x7F84,
-- cNotifyMarrySuc = 0x7F85,
cNotifyDefaultSkill = 0x7F86,
-- cNotifyTaskTimes = 0x7F87,
cNotifyFreeDirectFly = 0x7F88,
cNotifyGotoEndNotify = 0x7F89,
cNotifyStatusHpMpChange = 0x7F90,
cNotifyVipChange = 0x7F91,
cNotifySlaveState = 0x7F92,
cNotifyCapacityChange = 0x7F93,
-- cNotifyReinInfoChange = 0x7F94,
cNotifyTotalAttrParam = 0x7F95,
cNotifyGiftList = 0x7F96,
cNotifyBibleContent = 0x7F97,
cNotifyCollectBreak = 0x7F99,		
cNotifyOnSaleItemChange = 0x7F98,
-- cNotifyXinFaList = 0x7FA0,
-- cNotifyXinFaData = 0x7FA1,
cNotifyAttackMiss = 0x7FA2,
cNotifyLoginItemList = 0x7FA3,
cNotifyParamData = 0x7FA4,
cNotifySpeed = 0x7FA5,
cNotifyLableInfo = 0x7FA6,
cNotifyDoAction = 0x7FA7,
cNotifyShowEmotion = 0x7FA8,
cNotifyShowProgressBar = 0x7FA9,
cNotifyScriptItemChange = 0x7FAA,
cNotifyScriptItemInfoChange = 0x7FAB,
cNotifyItemPanelFresh = 0x7FAC,
cNotifyPowerChange = 0x7FAD,
cNotifyStatusDef = 0x7FAE,
cNotifyBuffDesp = 0x7FB1,
cNotifyBuffChange = 0x7FB2,
cNotifyListItemDesp = 0x7FB3,
cNotifyListItemChange = 0x7FB4,
cNotifyListUpgradeDesp = 0x7FB5,
cNotifyMonExpHiterChange = 0x7FB6,
cNotifyListBuff = 0x7FB7,

cNotifyParamDataLsit = 0x7FF1,
cNotifyListStatus = 0x7FF2,
cNotifyListChargeDart = 0x7FF3,

cReqListGuildDepot = 0x7243,
cResListGuildDepot = 0x7244,

cReqGetMails = 0x7A70,
cResGetMails = 0x7A71,
cReqOpenMail = 0x7A72,
cReqReceiveMailItems = 0x7A73,
cReqDeleteMail = 0x7A74,
cNotifyMailNum = 0x7A75,

cNotifyMailReceiveSuccess = 0x7A76,
-- cNotifyQiangHuaAllValue = 0x7FF5,
-- cNotifyQiangHuaEquip = 0x7FF6,

--寄售相关
cReqConsignItem = 0x7B00,
cResConsignItem = 0x7B01,
cReqGetConsignableItems = 0x7B02,
cResGetConsignableItems = 0x7B03,
cReqBuyConsignableItem = 0x7B04,
cResBuyConsignableItem = 0x7B05,

cReqTakeBackConsignableItem = 0x7B06,
cResTakeBackConsignableItem = 0x7B07,

cReqTakeBackVCoin = 0x7B08,
cResTakeBackVCoin = 0x7B09,

cReqGuildRedPacketLog = 0x7245,
cResGuildRedPacketLog = 0x7246,
cNotifyGuildRedPacketLog = 0x7247,

cReqGuildItemLog = 0x7248,
cResGuildItemLog = 0x7249,

cNotifyGuildWar = 0x724A,

cNotifyMapMonGen = 0x7FC1,

cNotifyCollectEnd = 0x7902,

--魂环
cNotifyShadowAdd = 0x7FC2,
--观察掉落
cNotifyDropListPre = 0x7FC3,

log={
	[0x7000]="cReqAuthenticate",
	[0x7001]="cResAuthenticate",

	[0x7003]="cNotifyCharacterLoad",

	[0x7010]="cReqMapChat",
	[0x7011]="cResMapChat",
	[0x7012]="cNotifyMapChat",
	
	[0x7020]="cReqPrivateChat",
	[0x7021]="cResPrivateChat",
	[0x7022]="cNotifyPrivateChat",
	
	[0x7030]="cReqWalk",
	[0x7031]="cResWalk",
	[0x7032]="cNotifyWalk",
	
	[0x7040]="cReqRun",
	[0x7041]="cResRun",
	[0x7042]="cNotifyRun",
	
	[0x7050]="cReqNPCTalk",
	[0x7051]="cResNPCTalk",
	
	[0x7060]="cReqTurn",
	[0x7061]="cResTurn",
	[0x7062]="cNotifyTurn",
	
	[0x7070]="cReqAttack",
	[0x7071]="cResAttack",
	[0x7072]="cNotifyAttack",
	
	[0x7080]="cReqPickUp",
	[0x7081]="cResPickUp",
	
	[0x7090]="cReqBagUseItem",
	[0x7091]="cResBaguseItem",
	
	[0x70A0]="cReqUndressItem",
	[0x70A1]="cResUndressItem",
	
	[0x70B0]="cReqItemPositionExchange",
	[0x70B1]="cResItemPositionExchange",
	
	[0x70C0]="cReqUseSkill",
	[0x70C1]="cResUseSkill",
	[0x70C2]="cNotifyUseSkill",
	
	[0x70D0]="cReqNPCShop",
	[0x70D1]="cResNPCShop",
	
	[0x70E0]="cReqNPCBuy",
	[0x70E1]="cResNPCBuy",
	
	[0x70F0]="cReqCancelTask",
	
	[0x7100]="cReqForceMove",
	[0x7110]="cReqChangeCloth",
	
	[0x7120]="cReqListCharacter",
	[0x7121]="cResListCharacter",
	
	[0x7130]="cReqCreateCharacter",
	[0x7131]="cResCreateCharacter",
	
	[0x7140]="cReqEnterGame",
	[0x7141]="cResEnterGame",
	
	[0x7150]="cReqDeleteCharacter",
	[0x7151]="cResDeleteCharacter",
	
	[0x7160]="cReqNPCSell",
	[0x7161]="cResNPCSell",
	
	[0x7170]="cReqDropItem",
	[0x7171]="cResDropItem",
	
	[0x7180]="cReqListGuild",
	[0x7181]="cResListGuild",
	
	[0x7190]="cReqGetGuildInfo",
	[0x7191]="cResGetGuildInfo",
	
	[0x71A0]="cReqSaveShortcut",
	[0x71A2]="cNotifyLoadShortcut",
	
	[0x71B0]="cReqCreateGuild",
	[0x71B1]="cResCreateGuild",
	
	[0x71C0]="cReqJoinGuild",
	[0x71C1]="cResJoinGuild",
	
	[0x71D0]="cReqSetGuildInfo",
	[0x71D1]="cResSetGuildInfo",
	
	[0x71E0]="cReqListGuildMember",
	[0x71E1]="cResListGuildMember",
	[0x71E2]="cNotifyGuildMemberChange",

	
	[0x71F0]="cReqListGuildEnemy",
	[0x71F1]="cResListGuildEnemy",
	
	[0x7200]="cReqListGuildFriend",
	[0x7201]="cResListGuildFriend",
	
	[0x7210]="cReqChangeGuildMemberTitle",
	[0x7220]="cReqChangeEnemyGuild",
	[0x7230]="cReqChangeFriendGuild",
	
	[0x7240]="cReqGuildChat",
	[0x7241]="cResGuildChat",
	[0x7242]="cNotifyGuildChat",
	
	[0x7250]="cReqChangeAttackMode",
	[0x7251]="cResChangeAttackMode",
	
	[0x7260]="cReqVcoinShopList",
	[0x7261]="cResVcoinShopList",
	
	[0x7280]="cReqNPCRepair",
	[0x7281]="cResNPCRepair",
	
	[0x7290]="cReqRelive",
	[0x7291]="cResRelive",
	
	[0x72B0]= "cReqKuafuAuth",
	[0x72B1]= "cResKuafuAuth",

	[0x7300]="cReqTaskDesp",
	[0x7301]="cResTaskDesp",
	
	[0x7310]="cReqInfoPlayer",
	[0x7311]="cResInfoPlayer",
	
	[0x7320]="cReqCreateGroup",
	[0x7321]="cResCreateGroup",
	
	[0x7330]="cReqLeaveGroup",
	[0x7331]="cResLeaveGroup",
	
	[0x7340]="cReqJoinGroup",
	[0x7341]="cResJoinGroup",
	
	[0x7350]="cReqAgreeJoinGroup",
	[0x7351]="cResAgreeJoinGroup",
	
	[0x7360]="cReqInviteGroup",
	[0x7361]="cResInviteGroup",
	
	[0x7370]="cReqAgreeInviteGroup",
	[0x7371]="cResAgreeInviteGroup",
	
	[0x7380]="cReqTaskClick",
	
	[0x7390]="cReqGroupChat",
	[0x7391]="cResGroupChat",
	
	[0x7400]="cReqNormalChat",
	[0x7401]="cResNormalChat",
	
	[0x7410]="cReqTradeInvite",
	
	[0x7420]="cReqAgreeTradeInvite",
	
	[0x7430]="cReqCloseTrade",
	
	[0x7440]="cReqTradeAddGameMoney",
	
	[0x7450]="cReqTradeAddVcoin",
	
	[0x7460]="cReqTradeSubmit",
	
	[0x7470]="cReqGroupSetLeader",
	
	[0x7480]="cReqTradeAddItem",

	[0x7481]="cReqTradeBuyItem",
	
	[0x7490]="cReqDestoryItem",
	
	[0x7500]="cReqSortItem",
	
	[0x7510]="cReqItemTalk",
	
	-- [0x7520]="cReqMergeSteel",
	-- [0x7521]="cResMergeSteel",
	
	-- [0x7530]="cReqUpgradeEquip",
	-- [0x7531]="cResUpgradeEquip",
	
	[0x7540]="cReqWorldChat",
	[0x7541]="cResWorldChat",
	
	[0x7550]="cReqFreshVcoin",
	
	[0x7560]="cReqLeaveGuild",
	
	[0x7570]="cReqAddDepotSlot",
	
	[0x7580]="cReqGroupPickMode",
	
	[0x7590]="cReqSwithSlaveAIMode",
	
	[0x7600]="cReqPing",
	[0x7601]="cResPing",
	
	[0x7610]="cReqFreshHPMP",
	
	[0x7620]="cReqUpdateTicket",
	[0x7621]="cResUpdateTicket",
	
	-- [0x7630]="cReqUpdateChinaLimit",
	
	-- [0x7640]="cReqBuyOfflineExp",
	
	-- [0x7650]="cReqSteelEquip",
	
	[0x7660]="cReqPlayerTalk",
	
	[0x7670]="cReqGetChartInfo",
	[0x7671]="cResGetChartInfo",
	
	[0x7680]="cReqInfoItemExchange",
	[0x7681]="cResInfoItemExchange",
	
	[0x7690]="cReqItemExchange",
	[0x7691]="cResItemExchange",
	
	[0x7700]="cReqGetItemDesp",
	
	[0x7710]="cReqHornChat",
	[0x7711]="cResHornChat",
	[0x7712]="cNotifyHornChat",
	
	[0x7720]="cCountDownFinish",
	
	[0x7730]="cReqFriendChange",
	[0x7731]="cResFriendChange",
	
	[0x7732]="cReqFriendApplyAgree",
	[0x7733]="cResFriendApply",

	[0x7740]="cReqFriendFresh",
	[0x7741]="cResFriendFresh",
	
	-- [0x7750]="cReqEquipReRandAdd",
	-- [0x7751]="cResEquipReRandAdd",
	
	-- [0x7760]="cReqEquipExchangeUpgrade",
	-- [0x7761]="cResEquipExchangeUpgrade",
	
	[0x7770]="cReqServerScript",
	
	[0x7780]="cReqOpenRong",
	
	[0x7790]="cReqProtectItem",
	[0x7791]="cResProtectItem",
	
	[0x7800]="cReqGroupKickMember",
	
	[0x7810]="cReqFreshGift",
	
	-- [0x7820]="cReqMergeEquip",
	
	[0x7850]="cReqOpenAchieve",
	
	[0x7860]="cReqOpenPK",
	
	[0x7901]="cReqCollectStart",
	[0x7904]="cReqDirectFly",
	
	[0x7910]="cReqPushLuaTable",
	[0x7911]="cNotifyPushLuaTable",
	
	[0x7861]="cReqAddBagSlot",
	-- [0x7870]="cReqMarryInvite",
	-- [0x7872]="cNotifyMarryInvite",
	[0x7873]="cReqGetTaskList",
	-- [0x7874]="cNotifyDailyTaskList",
	-- [0x7875]="cNotifyInstanceTaskList",
	-- [0x7876]="cNotifyEverydayTaskList",
	-- [0x7877]="cNotifyBossFreshList",
	
	-- [0x7880]="cReqAgreeOrNotMarryInvite",
	-- [0x7890]="cReqDivorceInvite",
	-- [0x7900]="cReqAgreeOrNotDivorceInvite",

	[0x7878]="cReqFindMapGhost",
	[0x7879]="cResFindMapGhost",
	
	[0x7931]="cReqLotteryList",
	[0x7932]="cResLotteryList",
	
	[0x7933]="cReqLotteryTimes",
	[0x7934]="cReqLotterydepot_To_Bag",
	
	-- [0x7940]="cReqReincarnate",
	-- [0x7950]="cReqResetReinAttr",
	-- [0x7960]="cReqBuyReinTimes",
	-- [0x7970]="cReqUpdateReinAttr",
	
	[0x7980]="cReqChangeMount",
	
	[0x7990]="cReqNearbyPlayers",
	[0x7991]="cResNearbyPlayers",
	
	[0x7992]="cReqUpLevelXinfa",
	[0x7993]="cReqOpenXinfa",
	
	-- [0x79A0]="cReqAs2Lua",
	-- [0x79A2]="cNotifyLua2As",
	
	[0x79B0]="cReqOnSaleList",
	[0x79B1]="cNotifyOnSaleList",
	
	[0x79C0]="cReqOnSaleBuyItem",
	[0x79C2]="cNotifyOnSaleBuyItemSuc",
	
	[0x79D0]="cReqOnSalePutItem",
	
	[0x79E0]="cReqUpEquipInfo",
	[0x79E2]="cNotifyUpEquipInfo",
	
	[0x79F0]="cReqUpEquipItem",
	
	[0x7A00]="cReqLoginFormAward",
	
	[0x7A10]="cReqChangeFashionShow",
	
	[0x7A20]="cReqMergeFashionEquip",
	
	[0x7A30]="cReqSplitItem",
	
	-- [0x7A40]="cReqAs2LuaInfo",

	[0x7F00]="cNotifyMapEnter",
	[0x7F01]="cNotifyMapMeet",
	[0x7F02]="cNotifyMapLeave",
	[0x7F03]="cNotifyMapBye",
	[0x7F04]="cNotifyInjury",
	[0x7F05]="cNotifyDie",
	[0x7F06]="cNotifyItemChange",
	[0x7F07]="cNotifyAvatarChange",
	[0x7F08]="cNotifySkillChange",
	[0x7F09]="cNotifyAttributeChange",
	[0x7F0A]="cNotifyKuafuInfo",
	[0x7F10]="cNotifyGameMoneyChange",
	[0x7F11]="cNotifyHPMPChange",
	[0x7F12]="cNotifyTaskChange",
	[0x7F13]="cNotifyExpChange",
	[0x7F14]="cNotifyLevelChange",
	[0x7F15]="cNotifyForceMove",
	[0x7F17]="cNotifyItemDesp",
	[0x7F18]="cNotifyGuildInfo",
	[0x7F19]="cNotifyGhostGuildInfo",
	[0x7F20]="cNotifyGhostMode",
	[0x7F21]="cNotifyAlert",
	[0x7F22]="cNotifyRelive",
	[0x7F23]="cNotifyGroupInfoChange",
	[0x7F24]="cNotifyGroupState",
	[0x7F25]="cNotifyGroupInfo",
	[0x7F26]="cNotifySkillDesp",
	[0x7F27]="cNotifyYouKeSessionID",
	[0x7F28]="cNotifyMapConn",
	[0x7F29]="cNotifyMapSafeArea",
	[0x7F30]="cNotifyNpcShowFlags",
	[0x7F31]="cNotifyJoinGroupToLeader",
	[0x7F32]="cNotifyInviteGroupToMember",
	[0x7F33]="cNotifyFindRoadGotoNotify",
	[0x7F34]="cNotifyGroupChat",
	[0x7F35]="cNotifyNoramlChat",
	[0x7F36]="cNotifyTradeInvite",
	[0x7F37]="cNotifyTradeInfo",
	[0x7F38]="cNotifyTradeItemChange",
	[0x7F39]="cNotifyMapItemOwner",
	[0x7F40]="cNotifyPKStateChange",
	[0x7F41]="cNotifyMonsterAddInfo",
	[0x7F42]="cNotifyStatusChange",
	[0x7F43]="cNotifyItemTalk",
	[0x7F44]="cNotifyPlayerAddInfo",
	[0x7F45]="cNotifyCountDown",
	[0x7F46]="cNotifyMiniMapConn",
	[0x7F47]="cNotifyPlayEffect",
	[0x7F48]="cNotifyGameParam",
	[0x7F49]="cNotifyInfoItemChange",
	[0x7F50]="cNotifyWorldChat",
	[0x7F51]="cNotifySessionClosed",
	[0x7F52]="cNotifySessionDelayReauth",
	[0x7F53]="cNotifyWarInfo",
	[0x7F54]="cNotifyMapOption",
	[0x7F55]="cNotifyGuildCondition",
	[0x7F56]="cNotifySlotAdd",
	[0x7F57]="cNotifyNameAdd",
	[0x7F58]="cNotifyURL",
	[0x7F59]="cNotifyFreeReliveLevel",
	[0x7F60]="cNotifyGUIShowTag",
	[0x7F61]="cNotifySetModel",
	[0x7F62]="cNotifyChinaLimitLv",
	[0x7F63]="cNotifyMonsterChat",
	[0x7F64]="cNotifyMapMiniNpc",
	[0x7F65]="cNotifyOfflineExpInfo",
	[0x7F66]="cNotifyTeamInfo",
	[0x7F67]="cNotifyPlayerTalk",
	[0x7F68]="cNotifyProsperityChange",
	-- [0x7F69]="cNotifyGUIOpenPanel",
	[0x7F70]="cNotifyBlackBoard",
	[0x7F71]="cNotifyListGuildBegin",
	[0x7F72]="cNotifyListGuildEnd",
	[0x7F73]="cNotifyListGuildItem",
	[0x7F74]="cNotifyItemPlusDesp",
	[0x7FF4]="cNotifyItemPlusDespGroup",
	-- [0x7F75]="cNotifyHighFocus",
	[0x7F76]="cNotifyGuiShowMergeEquip",
	[0x7F77]="cNotifyListTalkList",
	[0x7F78]="cNotifyListTalkContent",
	[0x7F79]="cNotifyListTalkTitle",
	[0x7F80]="cNotifyAchieveDone",
	[0x7F81]="cNotifyPKConfirm",
	-- [0x7F83]="cNotifyEnterMarryInvite",
	-- [0x7F84]="cNotifyDivorceInvite",
	-- [0x7F85]="cNotifyMarrySuc",
	[0x7F86]="cNotifyDefaultSkill",
	-- [0x7F87]="cNotifyTaskTimes",
	[0x7F88]="cNotifyFreeDirectFly",
	[0x7F89]="cNotifyGotoEndNotify",
	[0x7F90]="cNotifyStatusHpMpChange",
	[0x7F91]="cNotifyVipChange",
	[0x7F92]="cNotifySlaveState",
	[0x7F93]="cNotifyCapacityChange",
	-- [0x7F94]="cNotifyReinInfoChange",
	[0x7F95]="cNotifyTotalAttrParam",
	[0x7F96]="cNotifyGiftList",
	[0x7F97]="cNotifyBibleContent",
	[0x7F99]="cNotifyCollectBreak	",
	[0x7F98]="cNotifyOnSaleItemChange",
	-- [0x7FA0]="cNotifyXinFaList",
	-- [0x7FA1]="cNotifyXinFaData",
	[0x7FA2]="cNotifyAttackMiss",
	[0x7FA3]="cNotifyLoginItemList",
	[0x7FA4]="cNotifyParamData",
	[0x7FA5]="cNotifySpeed",
	[0x7FA6]="cNotifyLableInfo",
	[0x7FA7]="cNotifyDoAction",
	[0x7FA8]="cNotifyShowEmotion",
	[0x7FA9]="cNotifyShowProgressBar",
	[0x7FAA]="cNotifyScriptItemChange",
	[0x7FAB]="cNotifyScriptItemInfoChange",
	[0x7FAC]="cNotifyItemPanelFresh",
	[0x7FAD]="cNotifyTiliChange",
	[0x7FAE]="cNotifyStatusDef",
	[0x7FB1]="cNotifyBuffDesp",
	[0x7FB2]="cNotifyBuffChange",
	[0x7FB3]="cNotifyListItemDesp",
	[0x7FB4]="cNotifyListItemChange",
	[0x7FB5]="cNotifyListUpgradeDesp",
	[0x7FB6]="cNotifyMonExpHiterChange",
	[0x7FB7]="cNotifyListBuff",

	[0x7FF1]="cNotifyParamDataLsit",
	[0x7FF2]="cNotifyListStatus",
	[0x7FF3]="cNotifyListChargeDart",
	[0x7243]="cReqListGuildDepot",
	[0x7244]="cResListGuildDepot",

	[0x7A70]="cReqGetMails",
	[0x7A71]="cResGetMails",
	[0x7A72]="cReqOpenMail",
	[0x7A73]="cReqReceiveMailItems",
	[0x7A74]="cReqDeleteMail",
	[0x7A75]="cNotifyMailNum",
	[0x7A76]="cNotifyMailReceiveSuccess",
	-- [0x7FF5]="cNotifyQiangHuaAllValue",
	-- [0x7FF6]="cNotifyQiangHuaEquip",
	
	[0x7B00]="cReqConsignItem",
	[0x7B01]="cResConsignItem",
	[0x7B02]="cReqGetConsignableItems",
	[0x7B03]="cResGetConsignableItems",
	[0x7B04]="cReqBuyConsignableItem",
	[0x7B05]="cResBuyConsignableItem",
	[0x7B06]="cReqTakeBackConsignableItem",
	[0x7B07]="cResTakeBackConsignableItem",
	[0x7B08]="cReqTakeBackVCoin",
	[0x7B09]="cResTakeBackVCoin",

	[0x7245]="cReqGuildRedPacketLog",
	[0x7246]="cResGuildRedPacketLog",
	[0x7247]="cNotifyGuildRedPacketLog",
	[0x7248]="cReqGuildItemLog",
	[0x7249]="cResGuildItemLog",
	[0x724A]="cNotifyGuildWar",

	[0x7FC1]="cNotifyMapMonGen",
	[0x7902]="cNotifyCollectEnd",
	}
}

return GameMessageID