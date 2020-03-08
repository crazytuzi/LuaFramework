Require("CommonScript/Kin/KinDef.lua");
LingTuZhan.tbConst = {
	--地图类型
	MAP_TYPE_CITY = 1;
	MAP_TYPE_TOWN = 2;
	MAP_TYPE_FIELD = 3;
	MAP_TYPE_VILLAGE = 4;	
};
local tbConst = LingTuZhan.tbConst

LingTuZhan.define =
{
	szOpenTimeFrame = "OpenLevel139";
	szBattleZone = "LingTuZhan"; --战区
	SAVE_GROUP = 193;
	KEY_CUR_HONOR = 1;
	nMinLevel = 120; --最小参与等级
	nDelareKinMinRank = 10; --能宣战的最小家族排名
	nNeedLevelRankFromKinRank = 7; --从家族排名7开始往后的玩家参战需要玩家等级在前500名。
	szNewSeasonOpenWorldNotify = "新一季度的跨服领土战开启了！";
	szDeclartWarWorldNotify = "今日跨服领土战开启宣战了！";
	szOpenWarWorldNotify = "今日跨服领土战战斗开启了！";
	tbGlobleOpenMail = {  --新一季度活动开启时的全局邮件
		Title = "跨服领土战",
		Text = "本季度的跨服领土战开启了，每季度会清空之前的所有领土数据，包含占领领地，领土资金等，详情可在跨服领土战的帮助页面查看，快打开世界地图的领土战分页看看吧！[FFFE0D]每个季度首月1-7日不开启跨服领土战[-]。",  
		From = "系统",
		LevelLimit = 120, 
		tbAttach = {
		{ "Coin", 1000 }
		},
	};

	--各种周目标活动的配置，对应key 是和日历里一样
	tbWeekTargetsLimit = {
		Battle = { nCount = 1; nAddFound = 18 };
		Boss = { nCount = 1; nAddFound = 10 };
		WhiteTigerFuben = { nCount = 1; nAddFound = 10 };
	};

	--战斗主界面上显示的可用资源顺序，都要配置一个道具id,分别对应前线营地和攻城车
	tbBattleApplyIdOrder = {
		10606, --前线营地 道具class 是 LTZItemCamp
		10607, --攻城车 道具class 是 LTZItemCar
	};
	--战斗资源默认可用次数目
	tbBattleApplyIdDefaultCount = {
		[10606] = 5; --前线营地默认5次
	};
	-- 建造花费的家族资金 （攻城车）
	tbBattleApplyAddCountCost = {
		[10607] = 1000;--资金
	};
	--使用时花费的家族资金，（前线营地）
	tbBattleApplyUseCountCost = {
		[10606] = 300;--资金
	};	
	--同时最多可用个数限制（攻城车）
	tbBattleApplyCurTotalLimit = {
		[10607] = 5;
	};
	--使用确认框提示
	tbBattleApplyUseConfirmMsg = {
		[10606] = "是否在当前位置树立前线旗帜（会自动删除上一个旗帜），今日还可使用%d次";
	};

	--建造权限，（会增加次数，攻城车）
	tbBattleApplyBuildCarrer = {
		[10607] = {
			[Kin.Def.Career_Master] 		= 1,
			[Kin.Def.Career_ViceMaster] 	= 1,
			[Kin.Def.Career_Commander] 		= 1,
		};
	};
	--使用权限（会减少次数，营地、攻城车）
	tbBattleApplyUseCarrer = {
		[10606] = {
			[Kin.Def.Career_Master] 		= 1,
			[Kin.Def.Career_ViceMaster] 	= 1,
			[Kin.Def.Career_Commander] 		= 1,				
			[Kin.Def.Career_Elder] 		    = 1,				
		};
		[10607] = {
			[Kin.Def.Career_Leader] 		= 1,
			[Kin.Def.Career_Master] 		= 1,
			[Kin.Def.Career_ViceMaster] 	= 1,
			[Kin.Def.Career_Commander] 		= 1,
			[Kin.Def.Career_Elder] 		    = 1,
			[Kin.Def.Career_Mascot] 		= 1,
			[Kin.Def.Career_Elite] 			= 1,
			[Kin.Def.Career_Normal] 		= 1,
		};
	};
	--物资使用的调用参数
	tbBattleApplyCallBack = {
		[10606] = { "OnUseBuildCamp" }; --搭建前线营地
		[10607] = { "OnUseChangeCar","攻城车",4907,3600 }; --变身攻城车,技能id，持续时间
	};

	--不同时间轴等级前线营地Npc基础血量的配置,从低到高
	tbQuickCampNpcHpBase = {
		[1]=2000000;
		[2]=115000000;
		[3]=150000000;
		[4]=180000000;
		[5]=220638888;
		[6]=253030554;
		[7]=289694166;
		[8]=331160194;
		[9]=378022486;
	};
	nQuickCampNpcId = 3678;--前线营地npcid

	--战报最多缓存的家族消息数
	nMaxCacheKinMsg = 50;

	--未连接主城达连续2次以上时，该领地丢失
	nConnMasterMapCountNeed = 2;

	--防止小号进，不同时间轴限制进入地图等级,从小到大填
	tbEnterFightLevelLimit = {
		{ "OpenLevel139", 120 };
	};

	-- 功勋前5%的玩家，会在家族频道公告：
	fRateFinalRankKinNotify = 0.05;
	szFinalRankKinNotify = "「%s」在本次领土战中表现卓越，荣获第%d名！";
	
	----荣誉兑换宝箱
	tbExchangeBoxHonor = { 
			{"OpenLevel139",  10636, 800}, --时间轴， 荣誉兑换的黄金宝箱id, 所需要的荣誉
	};

	--家族内的排名奖励
	tbMemberAwardSetting = {
		{nPos = 1,   Award = {{"LTZ_Honor", 3200}, {"BasicExp", 180},},},
		{nPos = 2,   Award = {{"LTZ_Honor", 3000}, {"BasicExp", 170},},},
		{nPos = 3,   Award = {{"LTZ_Honor", 2800}, {"BasicExp", 160},},},
		{fPos = 0.1, Award = {{"LTZ_Honor", 2600}, {"BasicExp", 150},},},
		{fPos = 0.2, Award = {{"LTZ_Honor", 2400}, {"BasicExp", 140},},},
		{fPos = 0.3, Award = {{"LTZ_Honor", 2200}, {"BasicExp", 130},},},
		{fPos = 0.5, Award = {{"LTZ_Honor", 2000}, {"BasicExp", 120},},},
		{fPos = 0.7, Award = {{"LTZ_Honor", 1800}, {"BasicExp", 110},},},
		{fPos = 0.9, Award = {{"LTZ_Honor", 1600}, {"BasicExp", 105},},},
		{fPos = 1, 	 Award = {{"LTZ_Honor", 1400}, {"BasicExp", 100},},},
	};
	--占领领地 星级对应的价值量
	tbMapAuctionAwardValue = {
		[1] = 3000000;
		[2] = 4500000;
		[3] = 6000000;
	};
	--设置是主城时价值量增加的系数
	nSetMasterAddAwardValueFlag = 3.3 ;
	--没有领地的家族每个参与人增加的拍卖价值量
	nNoOwnMapRoleBaseAwardValue = 150000;
	--没有领地的家族能获得的最大拍卖价值
	nNoOwnMapMaxAuctionValue = 8000000;
	--拍卖价值量的总范围，最小值就是没领土时对应的价值,注意最大最小值都要设2份人数一样的
	--获得不同价值范围需要的基准人数，不足时打对应折扣
	tbAuctionValueBaseRoleNum = {
		--价值，人数，中间的自动插值
	 	{600000,  1}; 
	 	{1200000,  2}; 
	 	{6000000,  10};
	 	{60000000, 100};
	 	{60000000, 200};
	};

	tbAuctionAwardSetting = { -- 龙柱占领分决定的奖励分配
		{
			szTimeFrame = "OpenLevel139", 
			tbAward = {--对应奖励道具，积分占比，对应奖励的消耗积分数
				{10626, 2/12, 4050000,false,false, false, false},
				{10627, 2/12, 4050000,false,false, false, false},  
				{7394, 1/12, 500000,false,false, false, false},
				{1397, 3.5/12, 3600000,false,true, false, true}, 
				{10142, 1/12, 3000000,false,true, false, true}, 
				{4056, 1.5/12, 18000000,false,false, false, false},
				{10635, 1/12, 10000000,false,false, false, false},
			};
		};
		{
			szTimeFrame = "OpenLevel159", 
			tbAward = {--对应奖励道具，积分占比，对应奖励的消耗积分数
				{10626, 2/12, 4050000,false,false, false, false},
				{10627, 2/12, 4050000,false,false, false, false},  
				{7394, 1/12, 500000,false,false, false, false},
				{1397, 3.5/12, 3600000,false,true, false, true}, 
				{10142, 1/12, 3000000,false,true, false, true}, 
				{4056, 0.5/12, 18000000,false,false, false, false},
				{10635, 1/12, 10000000,false,false, false, false},
				{3557, 1/12, 18000000,false,true, false, true}, 
			};
		};
	};

	--赛季结算时占领城市的全体成员奖励
	tbSeasonFinalCityOwnAward = {
	 	{ "AddTimeTitle", 6836 };
	};
	--赛季结算的邮件内容
	tbSeasonFinalAwardMailDesc = {
		tbPersonAward = {
			Title = "领土战赛季个人奖励";
			Text = "本季度的跨服领土战结束了，您的家族排在第[FFFE0D]%d[-]名，额外获得以下奖励。下一季领土战即将开始，祝贵家族再创辉煌。[FFFE0D]每个季度首月1-7日不开启跨服领土战[-]。";
		};
		tbLeaderAward = {
			Title = "领土战赛季领袖奖励";
			Text = "本季度的跨服领土战结束了，您的家族排在第[FFFE0D]%d[-]名，获得了专属聊天前缀奖励。下一季领土战即将开始，在您的领导下，贵家族定可再创辉煌！[FFFE0D]每个季度首月1-7日不开启跨服领土战[-]。";
		};
		tbOwnCityAwrd = {
			Title = "领土战占领城市奖励";
			Text = "本季度的跨服领土战结束了，您的家族占领了城市，您获得了专属橙色极品称号奖励。下一季领土战即将开始，祝贵家族再创辉煌。[FFFE0D]每个季度首月1-7日不开启跨服领土战[-]。";
		};

	};
	--赛季结算排名奖励
	tbSeasonFinalAwardSetting  = {
		{ 
		  nRankEnd = 1; 
		  tbPersonAward  = {{"LTZ_Honor", 8000},{ "AddTimeTitle", 6833 }}; 
		  tbLeaderAward  = {{"item", 10999,1 }};
		  tbLeaderRedBagType = { 189 } ; 
		};
		{ 
		  nRankEnd = 2; 
		  tbPersonAward  = {{"LTZ_Honor", 6400},{ "AddTimeTitle", 6834 }}; 
		  tbLeaderAward  = {{"item", 11000,1 }};
		  tbLeaderRedBagType = { 190 } ; 
		};
		{ 
		  nRankEnd = 3; 
		  tbPersonAward  = {{"LTZ_Honor", 4800},{ "AddTimeTitle", 6834 }}; 
		  tbLeaderAward  = {{"item", 11000,1 }};
		  tbLeaderRedBagType = { 190 } ; 
		};
		{ 
		  nRankEnd = 4; 
		  tbPersonAward  = {{"LTZ_Honor", 4000},{ "AddTimeTitle", 6835 }}; 
		  tbLeaderAward  = {{"item", 11001,1 }};
		  tbLeaderRedBagType = { 190 } ; 
		};
		{ 
		  nRankEnd = 5; 
		  tbPersonAward  = {{"LTZ_Honor", 4000},{ "AddTimeTitle", 6835 }}; 
		  tbLeaderAward  = {{"item", 11001,1 }};
		  tbLeaderRedBagType = { 191 } ; 
		};
		{
		  nRankEnd = 6; 
		  tbPersonAward  = {{"LTZ_Honor", 4000}}; 
		  tbLeaderRedBagType = { 191 } ; 
		};
		{
		  nRankEnd = 9; 
		  tbPersonAward  = {{"LTZ_Honor", 4000}}; 
		  tbLeaderRedBagType = { 192 } ; 
		};
		{ 
		  nRankEnd = 11; 
		  tbPersonAward  = {{"LTZ_Honor", 3200}}; 
		  tbLeaderRedBagType = { 192 } ; 
		};
		{ 
		  nRankEnd = 21; 
		  tbPersonAward  = {{"LTZ_Honor", 2400}}; 
		};
		{ 
		  nRankEnd = 999; 
		  tbPersonAward  = {{"LTZ_Honor", 2400}}; 
		};
	};

	--战斗流程
	STATE_TRANS = {
		{nSeconds = 60*5,   	szFunc = "StartFight",  szDesc = "准备阶段"},
		{nSeconds = 60*25, 	szFunc = "StopFight",   szDesc = "战斗阶段"},
		{nSeconds = 60*1,   	szFunc = "CloseBattle", szDesc = "结算阶段"},
		{nSeconds = 1,   	szFunc = "ClearData", szDesc = "清数据阶段"}, --因为踢出onleave触发是下一帧，所以下秒再清除
	};
	nDynamicObstacleNpcId = 104; --动态障碍墙 的npcid

	tbDoorBuff = {1717, 1}; --城门，龙柱的buff id，level，加了以后就只能被有攻城buff的 打伤害很高
	tbFlagBuff = {1065, 5}; --龙柱 周围人越多抗性越强的buff
	tbBaoDongNpBuff = {2320, 10};--流寇的攻击建筑buff

	--在自己的主城时获得的额外保护buff
	-- tbMasterMapDefendBuff = { 1, 1 }; --buffid,Level
	--刚进战斗时的保护buff
	tbFightSafeBuff = { 1517,1,0,5*15 };


	--龙柱的范围距离，这里没有做不能叠加的操作，这里半径控制好不要叠加了
	nOwnFlagAddPlayerScoreRadius = 200;
	nOwnFlagAddPlayerScore = 10; --增加积分

	--隔多少秒已占领的龙柱增加统治力，给周围的玩家加积分
	nOwnFlagAddPowerInterval = 12;
	--每次龙柱增加的统治力，随活动时间增加，自动插值
	tbOwnFlagAddPowerValue = {
		{0, 50};
		{300, 70};
		{600, 95};
		{900, 120};
		{1200, 160};
		{1500, 190};
	};

	--王座对话npc
	nThroneNormalNpcId = 3687;  --Class TLZthrone
	--王座战斗npc
	nThroneFightNpcId = 3688;
	--每次王座增加的统治力，随活动时间增加，自动差值
	tbOwnThroneAddPowerValue = {
		{0, 150};
		{300, 210};
		{600, 285};
		{900, 360};
		{1200, 480};
		{1500, 570};	
	};
	nThoneAddPowerInterval = 12; --王座每隔多久加次统治力
	nThoneOccupyAddPlayerScroe = 100;--占领增加的玩家积分

	--龙柱被攻击时的通知间隔CD
	nFlagHpChangeNotifyInterval = 120;

	--击杀龙柱获得的统治力
	nKillFlagAddPowerValue = 300;

	--城门升级资金, [星级][等级] = 资金
	tbLevelUpWallCostFound = {
		[1] = {
			[1] = 0; --默认是从1星开始，所以对应资金需要是0
			[2] = 2000;
			[3] = 5000;
		};
		[2] = {
			[1] = 0;
			[2] = 2000;
			[3] = 5000;
		};
		[3] = {
			[1] = 0;
			[2] = 3000;
			[3] = 7500;
		};
	};
	--龙柱升级资金, [星级][等级] = 资金
	tbLevelUpDragonFlagCostFound = {
		[1] = {
			[1] = 0; --默认是从1星开始，所以对应资金需要是0
			[2] = 1000;
			[3] = 3000;
		};
		[2] = {
			[1] = 0;
			[2] = 1500;
			[3] = 4500;
		};
		[3] = {
			[1] = 0;
			[2] = 2000;
			[3] = 6000;
		};
	};

	--默认稳定度
	nDefaultStable = 50; 
	nMinStable = 20; --最小稳定度
	nMaxStable =  100; --最大稳定值
	tbControlStableCostFound = { --不同星级维稳一次消耗的资金数
		[1] = 200;
		[2] = 300;
		[3] = 400;
	};
	nControlAddStable =  10;--每次维稳加的稳定值
	nMinuStableEveryDay = 10; --每天会降低的稳定值
	nNotifyControlStable = 50; --提醒需要维稳定的值
	szNotifyControlStableMsg = "今晚21：05分将进行跨服领土战，请尽快对:「%s」进行维持稳定操作，这些领地有较高概率招致流寇入侵。";
	tbNotifyControlStableAttach = { {"Coin", 1000} };

	--暴动npcid
	nBaoDongNpcId = 3679;
	nMaxBaoDongMapCount = 20; --最多的暴动地图数
	nBaodDongNpcRevieTime = 50; --暴动npc 的重生时间
	szBaoDongKinName = "流寇";
	nKillBaoDongNpcScore = 8;--击杀一个流寇增加的功勋
	tbTimeFrameNpcLevel = { --时间轴等级 对应npc Level
		[1] = 30;
		[2] = 95;
		[3] = 105;
		[4] = 115;
		[5] = 125;
		[6] = 135;
		[7] = 145;
		[8] = 155;
		[9] = 165;
	};

	--地图类型
	tbMapTypeName = {
		[tbConst.MAP_TYPE_CITY] 	= "城市";
		[tbConst.MAP_TYPE_TOWN] 	= "县镇";
		[tbConst.MAP_TYPE_FIELD] 	= "野外";
		[tbConst.MAP_TYPE_VILLAGE] 	= "乡村";
	};

	--不可以直接宣战的地图类型
	tbCannotDirDeclareMapType = {
		[tbConst.MAP_TYPE_CITY] = 1;
	};

	--能宣战的权限
	tbCanDeclareCareer = {  
		[Kin.Def.Career_Master] 		= 1,
		[Kin.Def.Career_ViceMaster] 	= 1,
		[Kin.Def.Career_Commander] 	= 1,
	};
	--可以维持稳定的权限
	tbCanControlStableCareer = {
		[Kin.Def.Career_Master] 		= 1,
		[Kin.Def.Career_ViceMaster] 	= 1,
		[Kin.Def.Career_Commander] 	= 1,
	};
	--可以升级建筑的权限
	tbCanUpgradeBuildCareer = {
		[Kin.Def.Career_Master] 		= 1,
		[Kin.Def.Career_ViceMaster] 	= 1,
		[Kin.Def.Career_Commander] 	= 1,	
	};
	--可以设置主城的权限
	tbCanSetMasterCityCareer = {
		[Kin.Def.Career_Master] 		= 1,
		[Kin.Def.Career_ViceMaster] 	= 1,
		[Kin.Def.Career_Commander] 	= 1,
	};
	--禁止进入活动的权限
	tbForbitEnterGameCarrer = {
		[Kin.Def.Career_New] = 1;--见习禁止进入
	};
	
	tbCanSpeakCareer = --能上麦的权限
	{
		[Kin.Def.Career_Master] 	= 1,
		[Kin.Def.Career_ViceMaster] = 1,
		[Kin.Def.Career_Elder] = 1,
		[Kin.Def.Career_Commander] = 1,
	};

	--不同类型地图开启的轮数要求
	tbMapTypeOpenRound = {
		[tbConst.MAP_TYPE_VILLAGE] 	= 1;
		[tbConst.MAP_TYPE_FIELD] 	= 2;
		[tbConst.MAP_TYPE_TOWN] 	= 3;
		[tbConst.MAP_TYPE_CITY] 	= 6;
	};

	--根据时间轴决定的等级，现在用到的有
	-- 龙柱城门buff等级，龙柱、城门的血量基准，暴动流寇npc等级，变身攻城车buff等级，前线营地血量等级	
	tbTimeFramLevel = {
		39,
		109,
		119,
		129,
		139,
		149,
		159,
		169,
		179,
	};

	--不同等级城门npcid 
	tbDoorNpcTemplateSetting = {
		[1] = {
			[tbConst.MAP_TYPE_CITY] = 3673;
			[tbConst.MAP_TYPE_TOWN] = 3680;
		};
		[2] = {
			[tbConst.MAP_TYPE_CITY] = 3674;
			[tbConst.MAP_TYPE_TOWN] = 3681;
		};
		[3] = {
			[tbConst.MAP_TYPE_CITY] = 3675;
			[tbConst.MAP_TYPE_TOWN] = 3682;
		};
	};
	--不同时间轴等级城门基础血量
	tbDoorNpcHpSettingBase = {
		[1] = 30000000;
		[2] = 184000000;
		[3] = 240000000;
		[4] = 288000000;
		[5] = 353022222;
		[6] = 404848888;
		[7] = 463510666;
		[8] = 529856311;
		[9] = 604835977;
	};
	--不同城门等级血量的增幅系数
	tbDoorNpcLevelHpFactor = {
		[1] = 1 ;
		[2] = 1.5 ;
		[3] = 2 ;
	};
	--不同等级对应的龙柱npcid 和血量增幅系数
	tbDragonNpcLevelSetting = {
		[1] = { nTemplateId = 3667, nFactor = 1 };
		[2] = { nTemplateId = 3668, nFactor = 1.5 };
		[3] = { nTemplateId = 3669, nFactor = 2 };
	};
	--不同时间轴等级龙柱基础血量的配置,从低到高
	tbDragonNpcHpSettingBase = {
		[1]=1500000;
		[2]=86250000;
		[3]=112500000;
		[4]=135000000;
		[5]=165479166;
		[6]=189772915;
		[7]=217270624;
		[8]=248370145;
		[9]=283516864;
	};

	--玩家击杀积分配置必须连续 根据对方减去自己头衔插 决定击杀积分，超过最大或最小的就直接俄取最大或最小值
	tbKillAddScreOnHonor = { 
		[10] = 100;
		[9] = 100;
		[8] = 85;
		[7] = 80;
		[6] = 75;
		[5] = 70;
		[4] = 65;
		[3] = 60;
		[2] = 55;
		[1] = 50;
		[0] = 50;
		[-1] = 50;
		[-2] = 45;
		[-3] = 40;
		[-4] = 35;
		[-5] = 30;
		[-6] = 25;
		[-7] = 20;
		[-8] = 15;
		[-9] = 10;
		[-10] = 5;
	 };

	 --活动结束后对有领地家族的系统消息
	 szEndActKinOwnMaoNotiyf = "本场领土战已经结束，请尽快设置主城。设置主城后才有拍卖奖励。";
	 --自动设置主城的时间间隔
	 nIntervalAutoSetMasterMap = 1800;

	 nNewsInformationTimeLast = 3600 * 24* 7;--最新消息持续时间


	 

	--地图的基础属性
	tbMapSeting = {
		[10001] = {
			nType = tbConst.MAP_TYPE_CITY;
			nStar = 3; --星级
			--王座配置，没有就不用填;
			tbThroneInfo = {
				tbPos = {16257, 12495, 32}; --王座npc的位置
				szMapTxtIndex = "Throne";
			};

			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门（外）";
				 	tbPos = {16227, 16533, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{15893, 16800}, {16185, 16800}, {16603, 16800}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{15893, 16300}, {16185, 16300}, {16603, 16300}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门（外）";
				 	tbPos = {16227, 8425, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{15864, 8180}, {16185, 8180}, {16603, 8180}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{15864, 8600}, {16185, 8600}, {16603, 8600}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门（外）";
				 	tbPos = {12186, 12479, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{11900, 12835}, {11900, 12505}, {11900, 12195}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{12400, 12835}, {12400, 12505}, {12400, 12195}};  
			 	 };
				 {	
				 	szNpcName  = "北城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {16213, 14999, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north_inner",--动态障碍名
				 	szMapTxtIndex = "gate_north_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{16002, 15175}, {16180, 15175}, {16400, 15175}}; 
			 	 	szGateTrapNameIn = "trap_northin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{16002, 14800}, {16180, 14800}, {16400, 14800}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {16213, 10012, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south_inner",--动态障碍名
				 	szMapTxtIndex = "gate_south_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{16002, 9814}, {16180, 9814}, {16400, 9814}}; 
			 	 	szGateTrapNameIn = "trap_southin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{16002, 10208}, {16180, 10208}, {16400, 10208}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {13786, 12454, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west_inner",--动态障碍名
				 	szMapTxtIndex = "gate_west_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{13562, 12681}, {13562, 12480}, {13562, 12277}}; 
			 	 	szGateTrapNameIn = "trap_westin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{14000, 12681}, {14000, 12480}, {14000, 12277}}; 
			 	 };
				 {	
				 	szNpcName  = "东城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {18714, 12454, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_east_inner",--动态障碍名
				 	szMapTxtIndex = "gate_east_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_east_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{18928, 12649}, {18928, 12451}, {18928, 12238}}; 
			 	 	szGateTrapNameIn = "trap_eastin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{18504, 12649}, {18504, 12451}, {18504, 12238}}; 
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {13069, 15690, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {19391, 15690, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {19391, 9219, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {13069, 9219, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10387, 20900 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10039 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8336, 19462 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10035 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5866, 17386 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10003 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3850, 12641 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10046 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4843, 6808 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10019 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10794, 4365 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 22042, 12352 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{11410,4613,20},
				{11063,4754,20},
				{10689,4895,20},
				{5688,7187,26},
				{5818,6937,26},
				{4523,12681,32},
				{4523,12296,32},
				{6165,16674,12},
				{6495,16804,12},
				{6837,16967,12},
				{7113,17151,12},
				{8342,19000,15},
				{8654,19000,15},
				{8937,19000,15},
				{9213,19000,15},
				{9463,19000,15},
				{9655,19176,32},
				{9655,19390,32},
				{9961,20235,13},
				{10253,20313,13},
				{10552,20381,13},
				{10854,20466,13},
				{11143,20544,13},
				{11381,20602,13},
				{21604, 12951, 32},
				{21604, 12751, 32},
				{21604, 12551, 32},
				{21604, 12351, 32},
				{21604, 12151, 32},
				{21604, 11951, 32},
				{21604, 11751, 32},
				{21604, 11551, 32},
			};
			tbBaoDongNpcPos = {
				{13056,15939},
				{12887,15641},
				{13225,15601},
				{19411,15890},
				{19588,15705},
				{19314,15609},
				{19365,9427},
				{19576,9235},
				{19288,9168},
				{13063,9436},
				{12880,9235},
				{13178,9120},
				{12411,12780},
				{12411,12518},
				{12395,12216},
				{15918,8598},
				{16193,8592},
				{16497,8582},
				{15923,16353},
				{16224,16353},
				{16513,16362},
			};

		};
		[10002] = {
			nType = tbConst.MAP_TYPE_CITY;
			nStar = 3; --星级
			--王座配置，没有就不用填;
			tbThroneInfo = {
				tbPos = {16257, 12495, 32}; --王座npc的位置
				szMapTxtIndex = "Throne";
			};
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门（外）";
				 	tbPos = {16227, 16533, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{15893, 16800}, {16185, 16800}, {16603, 16800}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{15893, 16300}, {16185, 16300}, {16603, 16300}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门（外）";
				 	tbPos = {16227, 8425, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{15864, 8180}, {16185, 8180}, {16603, 8180}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{15864, 8600}, {16185, 8600}, {16603, 8600}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门（外）";
				 	tbPos = {12186, 12479, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{11900, 12835}, {11900, 12505}, {11900, 12195}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{12400, 12835}, {12400, 12505}, {12400, 12195}};  
			 	 };
				 {	
				 	szNpcName  = "北城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {16213, 14999, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north_inner",--动态障碍名
				 	szMapTxtIndex = "gate_north_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{16002, 15175}, {16180, 15175}, {16400, 15175}}; 
			 	 	szGateTrapNameIn = "trap_northin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{16002, 14800}, {16180, 14800}, {16400, 14800}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {16213, 10012, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south_inner",--动态障碍名
				 	szMapTxtIndex = "gate_south_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{16002, 9814}, {16180, 9814}, {16400, 9814}}; 
			 	 	szGateTrapNameIn = "trap_southin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{16002, 10208}, {16180, 10208}, {16400, 10208}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {13786, 12454, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west_inner",--动态障碍名
				 	szMapTxtIndex = "gate_west_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{13562, 12681}, {13562, 12480}, {13562, 12277}}; 
			 	 	szGateTrapNameIn = "trap_westin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{14000, 12681}, {14000, 12480}, {14000, 12277}}; 
			 	 };
				 {	
				 	szNpcName  = "东城门（内）";
				 	nUseDoorNpcId = 3676; --指定门的npc时就不使用城门升级的对应的npc了
				 	tbPos = {18714, 12454, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_east_inner",--动态障碍名
				 	szMapTxtIndex = "gate_east_inner", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_east_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{18928, 12649}, {18928, 12451}, {18928, 12238}}; 
			 	 	szGateTrapNameIn = "trap_eastin_inner"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{18504, 12649}, {18504, 12451}, {18504, 12238}}; 
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {13069, 15690, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {19391, 15690, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {19391, 9219, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {13069, 9219, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10387, 20900 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10027 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8336, 19462 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10005 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5866, 17386 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10029 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3850, 12641 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10031 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4843, 6808 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10048 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10794, 4365 }; --复活点位置
					tbConnetMap = {"trap_tomap_6", 10041 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 22042, 12352 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{11410,4613,20},
				{11063,4754,20},
				{10689,4895,20},
				{5688,7187,26},
				{5818,6937,26},
				{4523,12681,32},
				{4523,12296,32},
				{6165,16674,12},
				{6495,16804,12},
				{6837,16967,12},
				{7113,17151,12},
				{8342,19000,15},
				{8654,19000,15},
				{8937,19000,15},
				{9213,19000,15},
				{9463,19000,15},
				{9655,19176,32},
				{9655,19390,32},
				{9961,20235,13},
				{10253,20313,13},
				{10552,20381,13},
				{10854,20466,13},
				{11143,20544,13},
				{11381,20602,13},
				{21604, 12951, 32},
				{21604, 12751, 32},
				{21604, 12551, 32},
				{21604, 12351, 32},
				{21604, 12151, 32},
				{21604, 11951, 32},
				{21604, 11751, 32},
				{21604, 11551, 32},
			};
			tbBaoDongNpcPos = {
				{13056,15939},
				{12887,15641},
				{13225,15601},
				{19411,15890},
				{19588,15705},
				{19314,15609},
				{19365,9427},
				{19576,9235},
				{19288,9168},
				{13063,9436},
				{12880,9235},
				{13178,9120},
				{12411,12780},
				{12411,12518},
				{12395,12216},
				{15918,8598},
				{16193,8592},
				{16497,8582},
				{15923,16353},
				{16224,16353},
				{16513,16362},
			};

		};
		[10003] = {
			nType = tbConst.MAP_TYPE_TOWN;
			nStar = 2; --星级
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门";
				 	tbPos = {8372, 9771, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{8228, 9956}, {8372, 9956}, {8561, 9956}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{8217, 9611}, {8386, 9611}, {8586, 9611}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门";
				 	tbPos = {7828, 4347, 39}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{7556, 4295}, {7690, 4200}, {7836, 4098}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7785, 4611}, {7923, 4544}, {8128, 4410}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门";
				 	tbPos = {6850, 6919, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{6653, 7068}, {6653, 6932}, {6653, 6725}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7048, 7068}, {7048, 6932}, {7048, 6725}};  
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8242, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10761, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10766, 4480, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8397, 5692, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6660, 13191 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10035 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4087, 12039 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2237, 9924 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10008 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1228, 6721 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10046 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1529, 3776 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10001 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3848, 1927 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6438, 1213 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 12195, 6947 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{6747,2123,15},
				{6561,2123,15},
				{6406,2123,15},
				{6252,2123,15},
				{4492,2358,23},
				{4347,2466,23},
				{4221,2558,23},
				{4116,2624,23},
				{3987,2690,23},
				{2676,3845,29},
				{2583,4005,29},
				{2498,4192,29},
				{2424,4381,29},
				{2341,6996,32},
				{2341,6815,32},
				{2341,6618,32},
				{2341,6423,32},
				{2341,6207,32},
				{2657,9350,7},
				{2787,9523,7},
				{2888,9679,7},
				{2980,9829,7},
				{4286,11090,9},
				{4468,11204,9},
				{4635,11311,9},
				{4762,11452,9},
				{6313,12185,15},
				{6529,12185,15},
				{6724,12185,15},
				{6897,12185,15},
				{11773,7536,32},
				{11773,7319,32},
				{11773,7112,32},
				{11773,6869,32},
				{11773,6592,32},

			};
			tbBaoDongNpcPos = {
				{8302,8543},
				{8439,8220},
				{8060,8293},
				{10786,8567},
				{10964,8220},
				{10609,8245},
				{10754,4752},
				{11012,4437},
				{10665,4413},
				{8407,5897},
				{8576,5679},
				{8278,5574},
				{8254,9612},
				{8522,9606},
				{8393,9612},
				{7040,7032},
				{7050,6885},
				{7049,6719},
				{7835,4589},
				{7931,4528},
				{8055,4462},
			};

		};
		[10004] = {
			nType = tbConst.MAP_TYPE_TOWN;
			nStar = 2; --星级
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门";
				 	tbPos = {8372, 9771, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{8228, 9956}, {8372, 9956}, {8561, 9956}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{8217, 9611}, {8386, 9611}, {8586, 9611}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门";
				 	tbPos = {7828, 4347, 39}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{7556, 4295}, {7690, 4200}, {7836, 4098}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7785, 4611}, {7923, 4544}, {8128, 4410}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门";
				 	tbPos = {6850, 6919, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{6653, 7068}, {6653, 6932}, {6653, 6725}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7048, 7068}, {7048, 6932}, {7048, 6725}};  
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8242, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10761, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10766, 4480, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8397, 5692, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6660, 13191 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10011 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4087, 12039 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10010 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2237, 9924 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10020 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1228, 6721 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10034 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1529, 3776 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10008 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3848, 1927 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6438, 1213 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 12195, 6947 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{6747,2123,15},
				{6561,2123,15},
				{6406,2123,15},
				{6252,2123,15},
				{4492,2358,23},
				{4347,2466,23},
				{4221,2558,23},
				{4116,2624,23},
				{3987,2690,23},
				{2676,3845,29},
				{2583,4005,29},
				{2498,4192,29},
				{2424,4381,29},
				{2341,6996,32},
				{2341,6815,32},
				{2341,6618,32},
				{2341,6423,32},
				{2341,6207,32},
				{2657,9350,7},
				{2787,9523,7},
				{2888,9679,7},
				{2980,9829,7},
				{4286,11090,9},
				{4468,11204,9},
				{4635,11311,9},
				{4762,11452,9},
				{6313,12185,15},
				{6529,12185,15},
				{6724,12185,15},
				{6897,12185,15},
				{11773,7536,32},
				{11773,7319,32},
				{11773,7112,32},
				{11773,6869,32},
				{11773,6592,32},
			};
			tbBaoDongNpcPos = {
				{8302,8543},
				{8439,8220},
				{8060,8293},
				{10786,8567},
				{10964,8220},
				{10609,8245},
				{10754,4752},
				{11012,4437},
				{10665,4413},
				{8407,5897},
				{8576,5679},
				{8278,5574},
				{8254,9612},
				{8522,9606},
				{8393,9612},
				{7040,7032},
				{7050,6885},
				{7049,6719},
				{7835,4589},
				{7931,4528},
				{8055,4462},
			};

		};
		[10005] = {
			nType = tbConst.MAP_TYPE_TOWN;
			nStar = 2; --星级
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门";
				 	tbPos = {8372, 9771, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{8228, 9956}, {8372, 9956}, {8561, 9956}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{8217, 9611}, {8386, 9611}, {8586, 9611}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门";
				 	tbPos = {7828, 4347, 39}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{7556, 4295}, {7690, 4200}, {7836, 4098}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7785, 4611}, {7923, 4544}, {8128, 4410}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门";
				 	tbPos = {6850, 6919, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{6653, 7068}, {6653, 6932}, {6653, 6725}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7048, 7068}, {7048, 6932}, {7048, 6725}};  
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8242, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10761, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10766, 4480, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8397, 5692, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6660, 13191 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10027 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4087, 12039 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10026 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2237, 9924 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10018 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1228, 6721 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1529, 3776 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10002 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3848, 1927 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6438, 1213 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 12195, 6947 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{6747,2123,15},
				{6561,2123,15},
				{6406,2123,15},
				{6252,2123,15},
				{4492,2358,23},
				{4347,2466,23},
				{4221,2558,23},
				{4116,2624,23},
				{3987,2690,23},
				{2676,3845,29},
				{2583,4005,29},
				{2498,4192,29},
				{2424,4381,29},
				{2341,6996,32},
				{2341,6815,32},
				{2341,6618,32},
				{2341,6423,32},
				{2341,6207,32},
				{2657,9350,7},
				{2787,9523,7},
				{2888,9679,7},
				{2980,9829,7},
				{4286,11090,9},
				{4468,11204,9},
				{4635,11311,9},
				{4762,11452,9},
				{6313,12185,15},
				{6529,12185,15},
				{6724,12185,15},
				{6897,12185,15},
				{11773,7536,32},
				{11773,7319,32},
				{11773,7112,32},
				{11773,6869,32},
				{11773,6592,32},
			};
			tbBaoDongNpcPos = {
				{8302,8543},
				{8439,8220},
				{8060,8293},
				{10786,8567},
				{10964,8220},
				{10609,8245},
				{10754,4752},
				{11012,4437},
				{10665,4413},
				{8407,5897},
				{8576,5679},
				{8278,5574},
				{8254,9612},
				{8522,9606},
				{8393,9612},
				{7040,7032},
				{7050,6885},
				{7049,6719},
				{7835,4589},
				{7931,4528},
				{8055,4462},
			};

		};
		[10006] = {
			nType = tbConst.MAP_TYPE_TOWN;
			nStar = 2; --星级
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门";
				 	tbPos = {8372, 9771, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{8228, 9956}, {8372, 9956}, {8561, 9956}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{8217, 9611}, {8386, 9611}, {8586, 9611}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门";
				 	tbPos = {7828, 4347, 39}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{7556, 4295}, {7690, 4200}, {7836, 4098}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7785, 4611}, {7923, 4544}, {8128, 4410}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门";
				 	tbPos = {6850, 6919, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{6653, 7068}, {6653, 6932}, {6653, 6725}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7048, 7068}, {7048, 6932}, {7048, 6725}};  
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8242, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10761, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10766, 4480, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8397, 5692, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6660, 13191 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10046 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4087, 12039 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10045 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2237, 9924 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1228, 6721 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10028 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1529, 3776 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10044 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3848, 1927 }; --复活点位置
					tbConnetMap = {"trap_tomap_6", 10019 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6438, 1213 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 12195, 6947 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{6747,2123,15},
				{6561,2123,15},
				{6406,2123,15},
				{6252,2123,15},
				{4492,2358,23},
				{4347,2466,23},
				{4221,2558,23},
				{4116,2624,23},
				{3987,2690,23},
				{2676,3845,29},
				{2583,4005,29},
				{2498,4192,29},
				{2424,4381,29},
				{2341,6996,32},
				{2341,6815,32},
				{2341,6618,32},
				{2341,6423,32},
				{2341,6207,32},
				{2657,9350,7},
				{2787,9523,7},
				{2888,9679,7},
				{2980,9829,7},
				{4286,11090,9},
				{4468,11204,9},
				{4635,11311,9},
				{4762,11452,9},
				{6313,12185,15},
				{6529,12185,15},
				{6724,12185,15},
				{6897,12185,15},
				{11773,7536,32},
				{11773,7319,32},
				{11773,7112,32},
				{11773,6869,32},
				{11773,6592,32},
			};
			tbBaoDongNpcPos = {
				{8302,8543},
				{8439,8220},
				{8060,8293},
				{10786,8567},
				{10964,8220},
				{10609,8245},
				{10754,4752},
				{11012,4437},
				{10665,4413},
				{8407,5897},
				{8576,5679},
				{8278,5574},
				{8254,9612},
				{8522,9606},
				{8393,9612},
				{7040,7032},
				{7050,6885},
				{7049,6719},
				{7835,4589},
				{7931,4528},
				{8055,4462},
			};
		};
		[10007] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5400, 10753, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10725, 10720, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {6288, 6283, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {10791, 6283, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10099, 14601 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10020 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 16329, 8295 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10033 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7151, 2973 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10032 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2728, 9189 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13247, 14100 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14156, 5320 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7808, 8472 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{13558,5248,32},
				{13558,5018,32},
				{13562,4799,32},
				{13574,4604,32},
				{13585,4389,32},
				{7630,3112,32},
				{7622,3350,32},
				{7626,3589,32},
				{7615,3792,32},
				{7615,3987,32},
				{7443,4108,15},
				{7205,4104,15},
				{7009,4104,15},
				{6811,4125,15},
				{6330,3634,32},
				{6338,3442,32},
				{6330,3228,32},
				{3391,9321,32},
				{3380,8984,32},
				{3380,8723,32},
				{3391,8424,32},
				{3386,8153,32},
				{8980,13461,15},
				{9248,13449,15},
				{9484,13457,15},
				{9716,13461,15},
				{9941,13457,15},
				{10169,13453,15},
				{10401,13457,15},
				{10657,13433,15},
				{10881,13437,15},
				{11172,14184,32},
				{11175,13943,32},
				{13245,13386,15},
				{13370,13390,15},
				{13506,13388,15},
				{13640,13386,15},
				{14426,8022,32},
				{8178,7198,14},
				{8327,7238,14},
				{8498,7270,14},
				{8660,7319,14},
				{6883,7905,27},
				{6971,7792,27},
				{7056,7645,27},
				{9041,8490,31},
				{9072,8315,31},
				{9102,8107,31},

			};
			tbBaoDongNpcPos = {
				{5364,11100},
				{5140,10750},
				{5589,10638},
				{10764,11058},
				{11016,10722},
				{10582,10638},
				{10736,6542},
				{10540,6276},
				{10820,6107},
				{6262,6584},
				{6528,6332},
				{6192,6164},
			};
		};
		[10008] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5016, 9368, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {9574, 9087, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {9205, 4371, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {4137, 4406, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13390, 6713 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10003 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12496, 11720 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10011 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7645, 13828 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10004 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2242, 12665 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 848, 7937 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5567, 641 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7017, 7364 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{5993,1377,32},
				{5993,1614,32},
				{5853,1781,15},
				{5651,1781,15},
				{5449,1781,15},
				{2008,7731,32},
				{2008,7956,32},
				{2008,8193,32},
				{1805,12191,15},
				{2028,12191,15},
				{2235,12191,15},
				{2443,12191,15},
				{2677,12191,15},
				{2899,12191,15},
				{3062,12191,15},
				{6908,13292,15},
				{7098,13292,15},
				{7287,13292,15},
				{7483,13292,15},
				{7672,13292,15},
				{7858,13292,15},
				{8043,13292,15},
				{8218,13292,15},
				{8377,13292,15},
				{11418,11870,23},
				{11551,11697,23},
				{11701,11512,23},
				{11873,11357,23},
				{12019,11149,23},
				{12148,10972,23},
				{12289,10791,23},
				{12440,10614,23},
				{12280,7244,32},
				{12280,6965,32},
				{12280,6722,32},
				{6690,6115,15},
				{6098,7077,32},
				{6651,8261,13},
				{8327,7658,32},
				{8327,7426,32},

			};
			tbBaoDongNpcPos = {
				{5020,9499},
				{5133,9352},
				{4956,9303},
				{9577,9227},
				{9686,9040},
				{9510,9040},
				{9235,4557},
				{9321,4346},
				{9103,4333},
				{4156,4604},
				{4269,4412},
				{4051,4333},
			};
		};
		[10009] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6612, 10139, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10863, 9958, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {11522, 6300, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6398, 6531, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15573, 9333 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10045 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8066, 2065 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10022 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10203, 13752 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10040 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13096, 13196 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 11591, 1670 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2366, 7012 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8751, 8182 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12146,2346,32},
				{12146,2543,32},
				{12009,2647,15},
				{11869,2647,15},
				{11700,2647,15},
				{11556,2647,15},
				{11409,2647,15},
				{8110,2858,15},
				{7916,2858,15},
				{7774,2858,15},
				{7607,2858,15},
				{3497,7024,32},
				{3497,6929,32},
				{9608,13572,32},
				{9768,13435,15},
				{9951,13435,15},
				{10129,13435,15},
				{10293,13435,15},
				{10451,13435,15},
				{10624,13435,15},
				{10803,13435,15},
				{10961,13435,15},
				{12565,13142,21},
				{12733,13056,21},
				{12897,12970,21},
				{13059,12885,21},
				{13236,12789,21},
				{13398,12693,21},
				{13564,12592,21},
				{14787,8898,23},
				{14889,8797,23},
				{15001,8690,23},
				{15112,8583,23},
				{8283,7329,23},
				{8107,7457,23},
				{7939,7587,23},
				{8011,8713,5},
				{7943,8538,5},
				{9321,9225,23},
				{9796,8467,32},
				{9796,8264,32},

			};
			tbBaoDongNpcPos = {
				{6617,10299},
				{6719,10134},
				{6514,10060},
				{10839,10123},
				{11038,9969},
				{10782,9832},
				{11528,6475},
				{11670,6310},
				{11414,6202},
				{6395,6697},
				{6577,6463},
				{6326,6497},
			};
		};
		[10010] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6546, 10826, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10821, 10197, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {6686, 5549, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {11159, 5724, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15387, 3624 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10004 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2854, 3016 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10020 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2867, 14901 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10012 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10765, 2913 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10155, 13914 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13852, 13837 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7903, 7683 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{14527,3474,32},
				{14527,3312,32},
				{10258,3710,15},
				{10422,3710,15},
				{10625,3710,15},
				{10771,3710,15},
				{10931,3710,15},
				{3610,3915,23},
				{3739,3824,23},
				{3856,3725,23},
				{3857,14138,7},
				{3753,14046,7},
				{3652,13958,7},
				{3548,13875,7},
				{3441,13771,7},
				{3340,13670,7},
				{10732,11901,12},
				{10892,11955,12},
				{13158,14123,7},
				{13305,13575,21},
				{13507,13486,21},
				{13674,13389,21},
				{13833,13299,21},
				{13985,13206,21},
				{14439,13482,7},
				{14521,13610,7},
				{14610,13754,7},
				{14132,14332,23},
				{14280,14239,23},
				{14412,14146,23},
				{14540,14041,23},
				{8593,6868,32},
				{7237,7004,23},
				{7225,8153,6},
				{8055,8662,18},

			};
			tbBaoDongNpcPos = {
				{6553,10972},
				{6666,10817},
				{6500,10776},
				{10826,10348},
				{10933,10181},
				{10743,10140},
				{11153,5884},
				{11290,5676},
				{11100,5676},
				{6664,5761},
				{6895,5558},
				{6606,5433},
			};
		};
		[10011] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6832, 12284, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {12582, 12044, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7311, 7640, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {12121, 7161, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 11208, 15052 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10017 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15402, 6984 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10008 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4935, 3837 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10004 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4683, 13974 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10014 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14847, 10474 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10488, 3054 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 9607, 10451 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{10775,2892,32},
				{10775,3056,32},
				{10775,3218,32},
				{10775,3384,32},
				{10648,3501,15},
				{10496,3501,15},
				{10353,3501,15},
				{10212,3501,15},
				{10066,3501,15},
				{9910,3501,15},
				{9762,3501,15},
				{5391,3595,32},
				{5391,3828,32},
				{5391,4041,32},
				{5391,4241,32},
				{5215,4457,15},
				{5017,4457,15},
				{4824,4457,15},
				{4647,4457,15},
				{4081,13549,15},
				{4251,13549,15},
				{4409,13549,15},
				{4577,13549,15},
				{4748,13549,15},
				{4916,13549,15},
				{5082,13549,15},
				{5142,14142,32},
				{5142,13992,32},
				{5142,13850,32},
				{5142,13704,32},
				{10844,14306,15},
				{11026,14306,15},
				{11196,14306,15},
				{11358,14306,15},
				{14654,10858,15},
				{14497,10858,15},
				{14383,10699,32},
				{14383,10532,32},
				{14383,10366,32},
				{14383,10202,32},
				{14383,10093,32},
				{14512,9964,15},
				{14688,9964,15},
				{9813,9210,15},
				{9601,9210,15},
				{8345,10568,32},
				{8345,10360,32},
				{9475,11721,15},
				{9678,11721,15},
				{10865,10460,32},
				{10865,10294,32},
				{14672,7494,15},
				{14460,7494,15},
				{14310,7313,32},
				{14310,7092,32},
				{14310,6908,32},
				{14310,6747,32},
				{14504,6614,15},
				{14696,6614,15},
				{14890,6614,15},
				{15051,6614,15},

			};
			tbBaoDongNpcPos = {
				{6835,12398},
				{6933,12273},
				{6795,12229},
				{12589,12149},
				{12678,12029},
				{12540,12011},
				{12114,7292},
				{12212,7172},
				{12087,7115},
				{7293,7750},
				{7400,7648},
				{7262,7577},
			};
		};
		[10012] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8645, 12201, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {12203, 12302, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {8198, 6727, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {12318, 6885, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 17323, 17032 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10013 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15469, 4777 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10038 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5218, 4661 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10014 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5226, 15906 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10010 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13262, 15602 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10037 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10301, 16235 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8902, 9509 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{15334,6028,9},
				{15092,5838,9},
				{14902,5657,9},
				{14697,5471,9},
				{14460,5285,9},
				{14177,5078,9},
				{4850,5286,15},
				{5141,5286,15},
				{5384,5286,15},
				{5637,5286,15},
				{5880,5286,15},
				{6205,5286,15},
				{6329,5057,32},
				{6329,4847,32},
				{5188,15136,9},
				{5395,15278,9},
				{5602,15433,9},
				{5796,15589,9},
				{5980,15754,9},
				{6192,15925,9},
				{9775,16280,32},
				{9775,16044,32},
				{9775,15793,32},
				{9964,15642,15},
				{10217,15642,15},
				{10488,15642,15},
				{12760,15444,32},
				{12928,15219,15},
				{13239,15219,15},
				{13520,15219,15},
				{13775,15352,32},
				{13775,15561,32},
				{16121,16102,23},
				{16371,15959,23},
				{9749,8593,9},
				{9526,8452,9},
				{8633,8403,19},
				{7989,9598,32},
				{8268,10285,7},
				{8423,10451,7},
				{9996,10193,25},
			};
			tbBaoDongNpcPos = {
				{8634,12464},
				{8816,12209},
				{8525,12118},
				{12162,12539},
				{12342,12368},
				{12105,12235},
				{12314,7096},
				{12485,6897},
				{12266,6783},
				{8115,6935},
				{8334,6830},
				{8144,6640},
			};
		};
		[10013] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5553, 9353, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {9873, 9400, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {4854, 6246, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {9950, 5344, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13073, 12522 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10015 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13203, 2448 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10016 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2860, 2282 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10012 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2597, 12695 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5920, 12059 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8043, 2496 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7416, 7316 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {
				{8379,2930,23},
				{7750,3020,7},
				{4787,4375,23},
				{3373,11200,9},
				{5432,11845,32},
				{5991,11585,15},
				{12244,12701,32},
				{12244,12081,32},
				{12834,11682,15},
				{8340,6320,7},
				{8476,6424,7},
				{8218,6205,7},
				{6620,6555,22},
				{6788,6402,22},
				{6323,7891,7},
				{6224,7725,7},
				{6459,8021,7},
				{8092,8139,23},
				{7955,8266,23},
				{8296,7994,23},
				{12550,3186,32},
				{12550,3021,32},
				{12550,2868,32},
				{12550,2711,32},
				{12550,2535,32},
				{12550,2373,32},
				{12550,2187,32},
				{12550,2011,32},
				{8535,2742,23},
				{8208,3109,23},
				{7908,3175,7},
				{7616,2915,7},
				{7508,2810,7},
				{4551,4571,23},
				{5028,4167,23},
				{5159,4055,23},
				{4909,4275,23},
				{4664,4489,23},
				{4423,4697,23},
				{3698,11507,7},
				{3545,11368,7},
				{3228,11131,7},
				{3004,11012,7},
				{5432,11695,32},
				{5605,11585,15},
				{5835,11585,15},
				{6197,11585,15},
				{6451,11585,15},
				{12244,12434,32},
				{12244,11866,32},
				{12480,11682,15},
				{12667,11682,15},
				{13067,11682,15},
				{13282,11682,15},

			};
			tbBaoDongNpcPos = {
				{5549,9525},
				{5671,9393},
				{5498,9286},
				{9867,9556},
				{9989,9423},
				{9847,9347},
				{9919,5437},
				{10025,5384},
				{9912,5275},
				{4852,6359},
				{4975,6250},
				{4803,6187},
			};
		};
		[10014] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5468, 11489, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10809, 9922, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {4560, 6498, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {10727, 6044, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3958, 14905 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10038 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2576, 2863 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10012 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12740, 1991 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10011 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8397, 13930 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14155, 14314 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15625, 10462 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7632, 8016 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12491,2705,9},
				{3591,13975,15},
				{3973,13971,15},
				{7605,12833,22},
				{13165,13449,16},
				{13754,13376,16},
				{15839,10910,15},
				{15301,10463,32},
				{7776,7010,12},
				{6481,7318,27},
				{7423,8851,10},
				{8956,8349,28},
				{9013,8217,28},
				{3887,3244,32},
				{3887,3399,32},
				{3698,3568,15},
				{3105,3568,15},
				{3413,3568,15},

			};
			tbBaoDongNpcPos = {
				{5456,11600},
				{5556,11506},
				{5422,11435},
				{10804,10133},
				{10987,9950},
				{10721,9822},
				{10676,6252},
				{10886,6078},
				{10639,5923},
				{4516,6664},
				{4754,6499},
				{4443,6371},
			};
		};
		[10015] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {7135, 11094, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {11356, 10875, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {11113, 6412, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {7159, 6509, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3218, 14627 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10043 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3751, 3559 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10013 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15563, 4222 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10016 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6057, 2710 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14003, 13866 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8153, 14588 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6090, 14555 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 9073, 9092 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{14816,4898,32},
				{14816,4053,32},
				{6878,3177,15},
				{7529,3177,15},
				{4349,4683,23},
				{4921,4254,23},
				{3743,13718,9},
				{6082,14136,15},
				{7923,14357,15},
				{8405,14357,15},
				{12992,13924,23},
				{13623,13378,23},
				{14276,12813,23},
				{9136,8010,15},
				{9258,8010,15},
				{8965,8010,15},
				{8065,9036,32},
				{8065,9159,32},
				{8065,8878,32},
				{9115,10043,15},
				{8950,10043,15},
				{9277,10043,15},
				{10118,9014,32},
				{10118,9169,32},
				{10118,8869,32},
				{14816,5141,32},
				{14816,4657,32},
				{14816,4343,32},
				{14816,3778,32},
				{6696,3177,15},
				{7108,3177,15},
				{7331,3177,15},
				{7752,3177,15},
				{7906,3177,15},
				{4149,4836,23},
				{4673,4479,23},
				{5233,4049,23},
				{3981,13921,9},
				{3499,13583,9},
				{5899,14136,15},
				{6304,14136,15},
				{7753,14357,15},
				{8179,14357,15},
				{8635,14357,15},

			};
			tbBaoDongNpcPos = {
				{7119,11272},
				{7269,11149},
				{7102,11004},
				{11360,11021},
				{11516,10864},
				{11315,10803},
				{11070,6551},
				{11215,6445},
				{11058,6350},
				{7135,6685},
				{7280,6551},
				{7124,6439},
			};
		};
		[10016] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {7591, 14003, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {12436, 14086, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {12621, 10395, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6993, 8127, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 16105, 2528 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10025 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4078, 4790 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10013 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2194, 16419 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10015 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 17641, 17810 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 17178, 12050 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4733, 13139 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 9676, 11720 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{15796,5653,15},
				{4796,5731,23},
				{5441,13871,32},
				{5441,13161,32},
				{5094,14269,15},
				{4326,16472,32},
				{16173,17136,25},
				{16511,12416,32},
				{16525,11904,32},
				{10539,10666,7},
				{8911,10410,23},
				{8854,12608,7},
				{10549,12345,23},
				{16120,5653,15},
				{15527,5653,15},
				{15281,5653,15},
				{4658,5870,23},
				{5016,5613,23},
				{5152,5524,23},
				{5441,12802,32},
				{5441,13000,32},
				{5441,13450,32},
				{5441,13704,32},
				{5441,14090,32},
				{5441,14229,32},
				{5248,14269,15},
				{4917,14269,15},
				{4326,16010,32},
				{4326,16190,32},
				{4326,16343,32},
				{4326,16659,32},
				{16098,17240,25},
				{16260,17046,25},
				{16361,16921,25},
				{16511,12634,32},
				{16511,12199,32},
				{16511,11681,32},
				{16511,11449,32},
				{10663,10758,7},
				{8773,10518,23},
				{8720,12467,7},
				{8986,12707,7},
				{10657,12277,23},


			};
			tbBaoDongNpcPos = {
				{7567,14204},
				{7727,14017},
				{7513,13897},
				{12442,14298},
				{12623,14084},
				{12356,14004},
				{12616,10591},
				{12796,10411},
				{12549,10304},
				{6959,8347},
				{7126,8167},
				{6959,8046},
			};
		};
		[10017] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6925, 11636, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {11186, 11478, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {11256, 6113, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6715, 6043, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9377, 14705 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10030 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2612, 3807 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10011 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6877, 3598 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10025 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6917, 14069 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13686, 3220 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2487, 8565 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8384, 8607 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{14266,4006,15},
				{14060,4006,15},
				{13881,4006,15},
				{13670,4006,15},
				{13500,3829,32},
				{13500,3649,32},
				{13500,3464,32},
				{13500,3308,32},
				{13500,3128,32},
				{13500,2928,32},
				{7219,3634,32},
				{7219,3863,32},
				{7219,4069,32},
				{7219,4250,32},
				{7044,4349,15},
				{6863,4349,15},
				{6691,4349,15},
				{6486,4349,15},
				{6335,4201,32},
				{6335,4017,32},
				{6335,3851,32},
				{6335,3682,32},
				{3320,4899,32},
				{3320,4702,32},
				{3320,4509,32},
				{3320,4322,32},
				{3320,4141,32},
				{3320,3927,32},
				{3320,3728,32},
				{3320,3516,32},
				{2823,8329,15},
				{3029,8329,15},
				{3188,8329,15},
				{3285,8414,32},
				{3285,8605,32},
				{3285,8802,32},
				{3176,8920,15},
				{3023,8920,15},
				{2864,8920,15},
				{6546,13568,15},
				{6709,13568,15},
				{6888,13568,15},
				{7063,13568,15},
				{7245,13568,15},
				{7411,13568,15},
				{9022,14058,15},
				{9210,14058,15},
				{9413,14058,15},
				{9607,14058,15},
				{9816,14058,15},
				{8688,7350,15},
				{8399,7350,15},
				{6951,8597,32},
				{6951,8370,32},
				{8443,9771,15},
				{8774,9771,15},
				{9800,8080,32},
				{9800,7832,32},

			};
			tbBaoDongNpcPos = {
				{6907,11941},
				{7150,11663},
				{6837,11551},
				{11157,11741},
				{11391,11516},
				{11105,11403},
				{11209,6389},
				{11444,6190},
				{11166,5990},
				{6681,6294},
				{6933,6051},
				{6586,5938},
			};
		};
		[10018] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6134, 10995, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {11533, 10458, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10556, 6940, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6086, 6867, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13244, 13815 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10036 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8469, 14545 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10039 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7905, 2495 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10005 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3510, 4618 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14504, 6088 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13222, 3942 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8392, 8874 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{14090,6369,7},
				{12148,4966,11},
				{11595,3871,32},
				{8480,3569,23},
				{7565,3583,7},
				{3605,5599,22},
				{4289,5086,22},
				{8621,13867,15},
				{13125,13505,15},
				{13561,13509,15},
				{8368,8025,15},
				{7512,8434,25},
				{7792,9405,7},
				{9192,9434,21},
				{9433,8985,34},
				{8753,3326,23},
				{8215,3829,23},
				{7766,3807,7},
				{7393,3425,7},
				{4665,4867,22},
				{3968,5344,22},
				{3275,5788,22},

			};
			tbBaoDongNpcPos = {
				{6121,11136},
				{6263,10979},
				{6121,10913},
				{11491,10649},
				{11681,10520},
				{11483,10356},
				{10510,7169},
				{10673,7014},
				{10510,6859},
				{6039,7057},
				{6254,6885},
				{6022,6764},
			};
		};
		[10019] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {7998, 10819, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {11539, 10844, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7899, 6337, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {13198, 5842, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3560, 12025 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10001 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3464, 8300 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10006 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9518, 3401 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10044 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3509, 3412 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 15030, 11173 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4374, 14141 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7432, 14572 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10541, 7714 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9874,3683,32},
				{9538,3819,15},
				{9086,3809,15},
				{4003,8512,32},
				{4004,8167,32},
				{4458,11238,7},
				{5384,13758,7},
				{4905,13239,7},
				{7790,14181,15},
				{7107,14181,15},
				{14438,11119,32},
				{10137,6916,23},
				{9798,7626,32},
				{10796,8541,15},
				{11298,7001,32},
				{4133,3390,32},
				{4133,3611,32},
				{4133,3827,32},
				{3928,3954,15},
				{3678,3954,15},
				{3444,3954,15},
				{3260,3954,15},
				{4003,7968,32},
				{4275,11096,7},
				{5608,14042,7},
				{5139,13493,7},
				{4674,13038,7},
				{7455,14181,15},
				{14438,10954,32},

			};
			tbBaoDongNpcPos = {
				{7925,10946},
				{8129,10833},
				{7957,10751},
				{11490,10969},
				{11707,10842},
				{11512,10747},
				{13195,6000},
				{13335,5838},
				{13162,5727},
				{7898,6475},
				{8021,6330},
				{7820,6263},
			};
		};
		[10020] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {4440, 8997, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8420, 9099, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {8481, 4018, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {4134, 3895, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12220, 8752 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10004 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 11575, 1299 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10040 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8791, 1486 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10033 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 5784, 1725 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10007 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1942, 11512 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10010 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 919, 4340 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 932, 2853 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 6469, 6415 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{11829,1862,15},
				{11266,1862,15},
				{10695,1430,32},
				{9816,1590,32},
				{9384,1787,15},
				{8783,1787,15},
				{8121,1787,15},
				{5938,2320,15},
				{5360,2320,15},
				{4939,2000,32},
				{1364,4419,32},
				{1364,3633,32},
				{1364,3027,32},
				{931,3583,15},
				{11609,8888,32},
				{11609,8482,32},
				{12072,8140,15},
				{6897,5686,11},
				{7077,5783,11},
				{5658,5791,23},
				{5820,5629,23},
				{6075,7243,9},
				{5901,7101,9},
				{7301,6425,32},
				{7301,6225,32},
				{12060,1862,15},
				{11601,1862,15},
				{11405,1862,15},
				{11049,1862,15},
				{10847,1862,15},
				{10695,1769,32},
				{10695,1608,32},
				{10695,1189,32},
				{9816,1480,32},
				{9657,1787,15},
				{9156,1787,15},
				{8963,1787,15},
				{8647,1787,15},
				{8474,1787,15},
				{8305,1787,15},
				{7950,1787,15},
				{7786,1787,15},
				{7585,1787,15},
				{6173,2320,15},
				{5658,2320,15},
				{5128,2320,15},
				{4939,2206,32},
				{4939,1790,32},
				{1364,2533,32},
				{1364,2840,32},
				{1364,3372,32},
				{1136,3583,15},
				{742,3583,15},
				{1364,3868,32},
				{1364,4184,32},
				{1364,4741,32},
				{1500,11220,15},
				{1722,11220,15},
				{1913,11220,15},
				{2115,11220,15},
				{2305,11220,15},
				{2492,11220,15},
				{2699,11220,15},
				{2912,11220,15},
				{3107,11220,15},
				{3315,11220,15},
				{3495,11220,15},
				{11609,9118,32},
				{11609,8694,32},
				{11609,8319,32},
				{11761,8140,15},
				{11941,8140,15},
				{12242,8140,15},
				{12431,8140,15},


			};
			tbBaoDongNpcPos = {
				{4412,9147},
				{4571,9032},
				{4381,8899},
				{8417,9244},
				{8567,9050},
				{8320,9001},
				{8475,4187},
				{8598,4010},
				{8382,3931},
				{4107,4050},
				{4244,3931},
				{4089,3798},
			};
		};
		[10021] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6180, 11041, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10549, 10397, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10549, 5097, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6288, 6064, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2073, 10720 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10028 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1519, 7146 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10047 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12198, 2423 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10091, 2374 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4234, 13508 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3253, 2268 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2012, 3113 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2152, 4911 }; --复活点位置
				};


			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8681, 7897 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12055,2936,10},
				{11707,2732,10},
				{10268,2722,15},
				{9891,2722,15},
				{9543,2722,15},
				{3686,2622,15},
				{3229,2596,15},
				{2568,3352,32},
				{2498,4953,32},
				{2193,7044,32},
				{2180,7507,32},
				{3019,10081,7},
				{4283,12806,15},
				{8696,6632,18},
				{7513,8188,29},
				{7607,7936,29},
				{8712,8918,15},
				{10230,7012,5},

			};
			tbBaoDongNpcPos = {
				{6171,11230},
				{6354,11047},
				{6119,10952},
				{10548,10607},
				{10705,10382},
				{10506,10314},
				{10527,5266},
				{10668,5109},
				{10480,5010},
				{6291,6251},
				{6427,6078},
				{6192,6015},
			};
		};
		[10022] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6604, 10074, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {11283, 9342, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10977, 5681, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {5486, 5904, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8650, 2022 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10047 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3256, 8348 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10032 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9386, 14583 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10009 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13627, 3181 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3520, 3899 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12420, 13651 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8092, 7589 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{13639,4099,18},
				{12942,3297,32},
				{8650,2539,15},
				{3766,8541,34},
				{3686,8240,34},
				{9142,13973,15},
				{9639,13972,15},
				{11683,13378,32},
				{11683,13001,32},
				{12256,12601,15},
				{12891,12601,15},
				{8660,6845,15},
				{7918,6991,23},
				{7503,7970,7},
				{8642,7952,25},
     			{8735,7851,25},
				{4360,3795,32},
				{4360,4140,32},
				{4134,4459,15},
				{3764,4459,15},
				{3436,4459,15},
				{11683,12821,32},
				{11943,12601,15},
				{12576,12601,15},
				{13161,12601,15},
			};
			tbBaoDongNpcPos = {
				{6613,10257},
				{6749,10121},
				{6558,10006},
				{11285,9494},
				{11400,9337},
				{11220,9271},
				{10937,5840},
				{11106,5682},
				{10931,5606},
				{5469,6047},
				{5589,5916},
				{5453,5840},
			};
		};
		[10023] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5414, 8159, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {9172, 8196, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {11341, 5990, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8294, 3560, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3275, 11699 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10031 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 11396, 11675 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10048 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2224, 2912 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12581, 2965 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9442, 12356 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2560, 8623 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7198, 5503 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12475,3445,7},
				{12109,3088,7},
				{3633,2847,29},
				{2626,7911,15},
				{3121,8766,32},
				{3109,8320,32},
				{3611,11239,5},
				{3809,11592,5},
				{9046,12001,32},
				{9455,11803,15},
				{9877,12082,32},
				{10955,11704,32},
				{11228,11388,15},
				{11661,11388,15},
				{6920,4756,15},
				{7237,4756,15},
				{7063,6281,9},
				{7738,6157,23},
				{8079,5172,35},
				{12683,3628,7},
				{12286,3267,7},
				{11883,2913,7},
				{2891,7911,15},
				{9213,11803,15},
				{9705,11803,15},

			};
			tbBaoDongNpcPos = {
				{5386,8350},
				{5561,8191},
				{5346,8071},
				{9191,8382},
				{9350,8191},
				{9127,8103},
				{11332,6201},
				{11491,6010},
				{11276,5922},
				{8243,3734},
				{8466,3575},
				{8235,3487},
			};
		};
		[10024]  = {
			nType = tbConst.MAP_TYPE_TOWN;
			nStar = 2; --星级
			--城门配置,没有则不用填
			Doors = {
				 {	
				 	szNpcName  = "北城门";
				 	tbPos = {8372, 9771, 32}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_north",--动态障碍名
				 	szMapTxtIndex = "gate_north", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_north"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{8228, 9956}, {8372, 9956}, {8561, 9956}}; 
			 	 	szGateTrapNameIn = "trap_northin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{8217, 9611}, {8386, 9611}, {8586, 9611}}; 
			 	 };
				 {	
				 	szNpcName  = "南城门";
				 	tbPos = {7828, 4347, 39}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_south",--动态障碍名
				 	szMapTxtIndex = "gate_south", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_south"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{7556, 4295}, {7690, 4200}, {7836, 4098}}; 
				 	szGateTrapNameIn = "trap_southin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7785, 4611}, {7923, 4544}, {8128, 4410}}; 
			 	 };
				 {	
				 	szNpcName  = "西城门";
				 	tbPos = {6850, 6919, 48}, --城门的位置及朝向,
				 	szDynamicObstacle = "dynamic_west",--动态障碍名
				 	szMapTxtIndex = "gate_west", --小地图文字内容key,对应text_pos_info.txt的 index
				 	szGateTrapName = "trap_west"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPos = {{6653, 7068}, {6653, 6932}, {6653, 6725}};
				 	szGateTrapNameIn = "trap_westin"; --门未破之前的踩trap传送,门破以后trap失效
				 	tbTrapPassPosIn = {{7048, 7068}, {7048, 6932}, {7048, 6725}};  
			 	 };
			},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {8242, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10761, 8322, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10766, 4480, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {8397, 5692, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6660, 13191 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10041 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4087, 12039 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10023 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2237, 9924 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10029 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1228, 6721 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10044 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1529, 3776 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10028 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3848, 1927 }; --复活点位置
					tbConnetMap = {"trap_tomap_6", 10021 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6438, 1213 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 12195, 6947 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{6747,2123,15},
				{6561,2123,15},
				{6406,2123,15},
				{6252,2123,15},
				{4492,2358,23},
				{4347,2466,23},
				{4221,2558,23},
				{4116,2624,23},
				{3987,2690,23},
				{2676,3845,29},
				{2583,4005,29},
				{2498,4192,29},
				{2424,4381,29},
				{2341,6996,32},
				{2341,6815,32},
				{2341,6618,32},
				{2341,6423,32},
				{2341,6207,32},
				{2657,9350,7},
				{2787,9523,7},
				{2888,9679,7},
				{2980,9829,7},
				{4286,11090,9},
				{4468,11204,9},
				{4635,11311,9},
				{4762,11452,9},
				{6313,12185,15},
				{6529,12185,15},
				{6724,12185,15},
				{6897,12185,15},
				{11773,7536,32},
				{11773,7319,32},
				{11773,7112,32},
				{11773,6869,32},
				{11773,6592,32},
			};
			tbBaoDongNpcPos = {
				{8302,8543},
				{8439,8220},
				{8060,8293},
				{10786,8567},
				{10964,8220},
				{10609,8245},
				{10754,4752},
				{11012,4437},
				{10665,4413},
				{8407,5897},
				{8576,5679},
				{8278,5574},
				{8254,9612},
				{8522,9606},
				{8393,9612},
				{7040,7032},
				{7050,6885},
				{7049,6719},
				{7835,4589},
				{7931,4528},
				{8055,4462},
			};

		};
		[10025] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {4569, 9871, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {9023, 9994, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10203, 6027, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {4813, 5417, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 12826, 14203 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10016 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1812, 14005 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10030 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2184, 2155 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10017 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7382, 2560 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10036 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14737, 2839 }; --复活点位置
					tbConnetMap = {"trap_tomap_5", 10026 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13293, 6648 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 6960, 7443 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{13900,2501,32},
				{2637,2474,25},
				{2399,13348,9},
				{12588,13406,22},
				{7539,6555,13},
				{6291,6657,20},
				{5960,7531,9},
				{6965,8508,17},
				{8342,7403,5},
				{8093,2684,32},
				{8093,2988,32},
				{7879,3221,15},
				{7592,3221,15},
				{7323,3221,15},
				{12307,6609,32},
				{12307,6354,32},
				{12307,6118,32},
				{12307,5912,32},
				{12533,5765,15},
				{12809,5765,15},
				{13086,5765,15},
				{13339,5765,15},

			};
			tbBaoDongNpcPos = {
				{4541,10102},
				{4751,9892},
				{4460,9784},
				{8982,10177},
				{9172,9987},
				{8962,9906},
				{10167,6236},
				{10363,6054},
				{10127,5912},
				{4771,5641},
				{4981,5397},
				{4690,5329},
			};
		};
		[10026] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5019, 10536, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10328, 10479, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10252, 4789, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {5000, 5037, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13400, 11943 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10042 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13346, 1684 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10005 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1428, 1630 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10025 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1606, 13826 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7555, 12803 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 7457, 2262 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 7906, 7905 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12945,2073,7},
				{7408,2731,15},
				{6958,2350,32},
				{1962,2005,23},
				{2490,12742,15},
				{7822,12085,7},
				{13044,12077,32},
				{13044,11707,32},
				{7764,6847,20},
				{6794,7752,32},
				{7321,8952,10},
				{8703,8911,23},
				{8848,7081,7},
				{7668,2731,15},
				{7108,2731,15},
				{6958,2567,32},
				{6958,2187,32},
				{2786,12742,15},
				{2230,12742,15},
				{8038,12180,10},
				{13044,11431,32},
				{13044,11926,32},
				{13044,12249,32},
				{7601,6909,18},
				{7951,6767,18},

			};
			tbBaoDongNpcPos = {
				{4995,10682},
				{5134,10568},
				{4981,10449},
				{10297,10634},
				{10456,10509},
				{10293,10401},
				{10221,4975},
				{10387,4797},
				{10190,4692},
				{4975,5253},
				{5160,5055},
				{4932,4938},
			};
		};
		[10027] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5656, 11698, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10765, 11639, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10844, 5505, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {7057, 6018, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2087, 2740 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10002 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3097, 10413 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10005 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1517, 14900 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10042 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9659, 14552 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13732, 13326 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13114, 3406 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8140, 9480 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{12740,3773,6},
				{2528,3293,23},
				{3505,9905,5},
				{3733,10270,5},
				{3598,10703,21},
				{3229,10854,21},
				{2479,14310,9},
				{9060,14037,15},
				{9708,14037,15},
				{10307,14037,15},
				{12992,13263,25},
				{13263,12893,25},
				{8792,8372,9},
				{7112,9198,30},
				{7693,10427,10},
				{8992,10029,25},
				{9150,9814,25},
				{2710,3178,23},
				{2368,3395,23},
				{3710,10652,21},
				{8649,14037,15},
				{9405,14037,15},
				{10026,14037,15},
				{10596,14037,15},

			};
			tbBaoDongNpcPos = {
				{5696,11863},
				{5788,11634},
				{5593,11657},
				{10780,11796},
				{10887,11630},
				{10707,11571},
				{10845,5643},
				{10986,5481},
				{10787,5407},
				{7043,6147},
				{7174,6052},
				{7038,5947},
			};
		};
		[10028] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {5905, 10892, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10137, 10807, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10240, 6796, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {4556, 6096, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 1596, 9914 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10006 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14695, 6496 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 14416, 4312 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10021 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13816, 12136 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3321, 3490 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8605, 3075 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 6478, 6388 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{13948,6322,32},
				{13948,5976,32},
				{14068,5731,15},
				{14008,5023,15},
				{13749,4731,32},
				{8280,3370,15},
				{8812,3370,15},
				{3348,4697,23},
				{3744,4334,23},
				{4173,3994,23},
				{4589,3615,23},
				{2557,9917,32},
				{2557,9569,32},
				{13209,12515,7},
				{13009,12226,7},
				{13099,11750,23},
				{13406,11545,23},
				{7368,5750,5},
				{5636,6208,32},
				{5636,5961,32},
				{6558,7150,15},
				{7650,7029,23},
				{13749,4541,32},
				{8551,3370,15},
				{4367,3838,23},
				{3954,4210,23},
				{3556,4524,23},
				{3111,4922,23},
				{4868,3422,23},
				{9418,13432,32},
				{9418,13207,32},
				{9418,13006,32},
				{9577,12842,15},
				{9814,12842,15},
				{10088,12842,15},
				{10352,12842,15},
				{10573,12842,15},
				{10732,13013,32},
				{10732,13235,32},
				{12956,11862,23},

			};
			tbBaoDongNpcPos = {
				{5897,11046},
				{6032,10878},
				{5874,10801},
				{10127,10946},
				{10267,10815},
				{10082,10702},
				{10222,6956},
				{10362,6820},
				{10195,6730},
				{4551,6249},
				{4687,6105},
				{4511,6000},
			};
		};
		[10029] = {
			nType = tbConst.MAP_TYPE_FIELD;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6279, 9986, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {10787, 10082, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {10729, 6169, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6068, 5901, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8547, 14942 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10044 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 2133, 8771 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 8756, 2054 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10002 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 13408, 13486 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 6783, 12847 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3059, 3472 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 8555, 8389 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{8321,2966,15},
				{8510,2968,15},
				{8688,2971,15},
				{8886,2980,15},
				{3452,3916,32},
				{3444,3737,32},
				{3450,3574,32},
				{3450,3389,32},
				{3450,3201,32},
				{2707,8734,5},
				{2652,8574,5},
				{2585,8419,5},
				{5893,12344,32},
				{5893,12166,32},
				{6218,11947,15},
				{6396,11947,15},
				{6562,11959,15},
				{6725,11950,15},
				{6891,11953,15},
				{8269,13807,15},
				{8419,13801,15},
				{8536,13801,15},
				{8653,13814,15},
				{12501,12960,23},
				{12611,12872,23},
				{12736,12787,23},
				{12846,12690,23},
				{12978,12586,23},
				{9436,8029,30},
				{9420,7873,34},
				{8380,7322,14},
				{8071,7403,17},
				{7597,7739,28},
				{7466,7969,30},
				{7514,8937,7},
				{7681,9116,8},
				{7849,9304,9},
				{8305,9450,18},
				{9452,8725,26},

			};
			tbBaoDongNpcPos = {
				{6266,10143},
				{6404,9986},
				{6221,9904},
				{10780,10247},
				{10914,10098},
				{10739,9982},
				{10698,6348},
				{10880,6188},
				{10660,6091},
				{6061,6050},
				{6203,5927},
				{6005,5815},
			};
		};
		[10030] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10017 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10025 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},
			};
		};
		[10031] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10023 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10002 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},
			};
		};
		[10032] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10007 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10022 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},
			};
		};
		[10033] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10020 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10007 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10034] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10004 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10045 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10035] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10003 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10001 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10036] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10025 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10018 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10037] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10043 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10012 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10038] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10012 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10014 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10039] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10018 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10001 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10040] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10020 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10009 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10041] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10002 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10042] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10026 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10027 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10043] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10037 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10015 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10044] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10019 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10006 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10024 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10029 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},
			};
		};
		[10045] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10034 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
					tbConnetMap = {"trap_tomap_3", 10009 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10006 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},
			};
		};
		[10046] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10003 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10006 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10001 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10047] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10022 }; --传回连通的地图的攻方复活点

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置

				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
					tbConnetMap = {"trap_tomap_4", 10021 }; --传回连通的地图的攻方复活点
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
		[10048] = {
			nType = tbConst.MAP_TYPE_VILLAGE;
			nStar = 1; --星级
			--城门配置,没有则不用填
			Doors = {},
			--龙柱配置
			tbFlagNpc = {
				{
					szNpcName = "1号龙柱";
					tbPos = {6588, 8442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_1" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "2号龙柱";
					tbPos = {8262, 7442, 48};--位置朝向
					szMapTxtIndex = "Longzhu_2" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "3号龙柱";
					tbPos = {7668, 5735, 48};--位置朝向
					szMapTxtIndex = "Longzhu_3" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
				{
					szNpcName = "4号龙柱";
					tbPos = {6079, 6475, 48};--位置朝向
					szMapTxtIndex = "Longzhu_4" ;--小地图文字内容key,对应text_pos_info.txt的 index
				};
			};
			--多个进攻方复活点 ，复活点数大于等于 连通城市trap点数
			tbAtackCamp = {
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 9757, 10865 }; --复活点位置
					tbConnetMap = {"trap_tomap_1", 10002 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 4575, 10808 }; --复活点位置
					tbConnetMap = {"trap_tomap_2", 10023 }; --传回连通的地图的攻方复活点
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 3310, 3868 }; --复活点位置
				};
				{
					--攻方的营地是攻守放都可以随意进出的，不限制，不然守方没法去连通的下个地图
					tbBornPos = { 10179, 3535 }; --复活点位置
				};

			};
			--一个守方复活点
			tbDefendCamp = {
				tbBornPos = { 10289, 7280 };
			};
			
			--战斗营地一开始的动态障碍，开始后关闭障碍
			szAttackDynamicObstacle  = "dynamic_begin";
			-- 战斗开始前各个营地障碍npc的摆放 位置，朝向，开始后会删除，不删的就不用配在这里
			tbCampDynamicObstacleNpc = {  
				{9940,3909,7},
				{3879,4246,26},
				{4616,9973,10},
				{4937,10157,10},
				{5286,10331,10},
				{4310,9809,10},
				{9428,10451,25},
				{9022,7394,32},
				{9016,7049,32},
			};
			tbBaoDongNpcPos = {
				{6578,8346},
				{6682,8152},
				{6500,8158},
				{8031,7591},
				{7823,7389},
				{8109,7300},
				{7431,6046},
				{7592,5791},
				{7300,5785},
				{6272,6842},
				{6136,6658},
				{6391,6605},

			};
		};
	};

	tbUiMapTypeSprite = {
		[tbConst.MAP_TYPE_CITY] = 
		{
			"BtnMainCity","BtnMainCityGray"
		} ;
		[tbConst.MAP_TYPE_TOWN] = 
		{
			"BtnVillage", "BtnVillageGray"
		};
		[tbConst.MAP_TYPE_FIELD] = 
		{
			"BtnField", "BtnFieldGray"
		};
		[tbConst.MAP_TYPE_VILLAGE] =
		{
			"BtnField", "BtnFieldGray"
		};
	};
	--ui 领土战地图上面 ui名字顺序对应的地图id
	tbUiOrderToMapId = {
		[1] = 10001;
		[2] = 10002;
		[3] = 10003;
		[4] = 10004;
		[5] = 10005;
		[6] = 10006;
		[7] = 10007;
		[8] = 10008;
		[9] = 10009;
		[10] = 10010;
		[11] = 10011;
		[12] = 10012;
		[13] = 10013;
		[14] = 10014;
		[15] = 10015;
		[16] = 10016;
		[17] = 10017;
		[18] = 10018;
		[19] = 10019;
		[20] = 10020;
		[21] = 10021;
		[22] = 10022;
		[23] = 10023;
		[24] = 10024;
		[25] = 10025;
		[26] = 10026;
		[27] = 10027;
		[28] = 10028;
		[29] = 10029;
		[30] = 10030;
		[31] = 10031;
		[32] = 10032;
		[33] = 10033;
		[34] = 10034;
		[35] = 10035;
		[36] = 10036;
		[37] = 10037;
		[38] = 10038;
		[39] = 10039;
		[40] = 10040;
		[41] = 10041;
		[42] = 10042;
		[43] = 10043;
		[44] = 10044;
		[45] = 10045;
		[46] = 10046;
		[47] = 10047;
		[48] = 10048;
	};
	--ui 上不同家族领地的颜色区分
	tbUiMapNameColorMy =  { 255, 232, 89 };
	tbUiMapNameColorTop10 = {
		{255,	127,	174};
		{63,	167,	255};
		{218,	116,	255};
		{255,	157,	104};
		{131,	148,	255};
		{121,	255,	181};
		{116,	255,	243};
		{220,	255,	123};
		{255,	111,	103};
	};
	tbUiMapNameColorOther = {19,	165,	0};
	tbUiMapNameColorNone = {255,255,255};

	tbShowKinMemberCareersList = {
		Kin.Def.Career_Leader;
		Kin.Def.Career_Master;
		Kin.Def.Career_ViceMaster;

		Kin.Def.Career_Commander;
		Kin.Def.Career_Elder;
		Kin.Def.Career_Elder;
		Kin.Def.Career_Elder;
		Kin.Def.Career_Elder;
		Kin.Def.Career_Elder;

		Kin.Def.Career_Mascot;
		Kin.Def.Career_Mascot;
	};

	
	--各种请求数据cd，因为登陆或重连时重置了上次请求时间，已经有主动下发的那种请求时间不用低于1小时
	nRequestIntervalComon = 7200;--客户端请求检查赛季和宣战的cd，
	nRequestIntervalAllMapOwn = 7200;--请求所有地图的家族占领信息
	nRequestIntervalMapInfo = 60;--请求一个地图的建筑，宣战信息
	nRequestIntervalKinfo = 60;--请求本家族的同步信息
	nRequestIntervalKinMsg = 100;--请求本家族缓存的战报系统消息
	nRequestIntervalFightData = 12;--请求本家族战斗信息，前线营地，功臣车
	nRequestIntervalMapKinPower = 30; --请求家族战报的间隔
	nRequestIntervalMyRoleInfo = 10; --个人战绩的请求cd
	nRequestIntervalAllRoleRank = 20;--全家族个人排名数据请求cd

};

local tbDefine = LingTuZhan.define

function LingTuZhan:GetCombineKinKey(nServerId, dwKinId)
    return nServerId .. "," ..  dwKinId
end

function LingTuZhan:GetSplitKinKey( szCombineKey )
	local nServerId, dwKinId = unpack(Lib:SplitStr(szCombineKey))
	if not dwKinId then
		return
	end
    return tonumber(nServerId), tonumber(dwKinId)
end

function LingTuZhan:IsMapCanDeclareWar(pPlayer, nMapTemplateId ,szKinKey)
	if not self:IsOpenLingTuZhanThisWeek() then
		return false, "当前赛季未开放"
	end
	local tbInfo = self.define.tbMapSeting[nMapTemplateId]
	if not tbInfo then
		return false
	end
	local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
    if not tbDefine.tbCanDeclareCareer[nMyCarrer] then
        return false, "族长、副族长和指挥才可以宣战" 
    end

	if tbDefine.tbCannotDirDeclareMapType[tbInfo.nType] then
		return false, string.format("%s不可以直接宣战", tbDefine.tbMapTypeName[tbInfo.nType]) 
	end
	local nNeedRound = tbDefine.tbMapTypeOpenRound[tbInfo.nType]
	local tbSynCommon = self:GetSynCommonData();
	if tbSynCommon.nOpenRound < nNeedRound then
		return false, string.format("%s在第%d轮跨服领土战开放", tbDefine.tbMapTypeName[tbInfo.nType], nNeedRound)
	end

 	local tbGetMyOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey );
 	if next(tbGetMyOwnMapIds) then
 		return false, "已有领地的家族不可以手动宣战"
 	end
 	local tbSynMyKinInfo = LingTuZhan:GetSynKinInfo( szKinKey )
 	if not tbSynCommon.bOpenDeclareWar and not (tbSynCommon.bOpenWar and not  tbSynMyKinInfo.nManulDeclareMapId) then
 		return false, "该阶段不可宣战"
 	end
 	if tbSynMyKinInfo.nManulDeclareMapId == nMapTemplateId then
 		return false, "已经宣战该地图"
 	end

 	--如果该地图连通的地图全部被一个家族占领，也是不可宣战的
 	local tbConnectMaps = tbDefine.tbConnectMapSetting[nMapTemplateId]
 	if tbConnectMaps then
 		local tbSynAllMapOwn = LingTuZhan:GetSynAllMapOwnerInfo()
 		local tbTarOwnKin = tbSynAllMapOwn[nMapTemplateId]
 		if tbTarOwnKin then
 			local bConnectAll = true
	 		for nConnMapId,v in pairs(tbConnectMaps) do
	 			local tbOwnKin = tbSynAllMapOwn[nConnMapId]
	 			if not tbOwnKin or tbOwnKin[1] ~= tbTarOwnKin[1] or tbOwnKin[2] ~= tbTarOwnKin[2] then
	 				bConnectAll =  false
	 				break;
	 			end
	 		end
	 		if bConnectAll then
	 			return false, "该领地的周围领地已被一个家族占领，不可宣战"
	 		end
 		end
 	end
 	return true;
end

function LingTuZhan:IsCanSetMasterMap(pPlayer, szKinKey, nMapTemplateId )
	local tbInfo = self.define.tbMapSeting[nMapTemplateId]
	if not tbInfo then
		return false
	end
	local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
    if not tbDefine.tbCanSetMasterCityCareer[nMyCarrer] then
        return false,"族长、副族长和指挥才可以设置主城"
    end
	local tbGetMyOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey );
	if not tbGetMyOwnMapIds[nMapTemplateId] then
		return false, "只可对已占领的领土设置主城"
	end
 	local tbSynMyKinInfo = LingTuZhan:GetSynKinInfo( szKinKey )
 	if tbSynMyKinInfo.nMasterMapId then
 		return false, "您已经有主城了，无法更改设置"
 	end
 	return true
end

function LingTuZhan:IsCanControlStable( pPlayer, szKinKey, nMapTemplateId )
	local tbMapSeting = tbDefine.tbMapSeting[nMapTemplateId]
	if not tbMapSeting then
		return
	end

	local tbGetMyOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey );
	if not tbGetMyOwnMapIds[nMapTemplateId] then
		return false, "只可对已占领的领土维持稳定"
	end

	local nCostFound = tbDefine.tbControlStableCostFound[tbMapSeting.nStar]
	--先判断资金
	local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
	if not tbSynMyKinInfo.nFound or tbSynMyKinInfo.nFound < nCostFound then
		return false, string.format("维持稳定一次消耗%d资金", nCostFound) 
	end
	local nMyCarrer = Kin:GetPlayerCareer( pPlayer.dwID)
    if not tbDefine.tbCanControlStableCareer[nMyCarrer] then
        return false, "族长、副族长和指挥才可以维持稳定" 
    end

	local tbSynCommon = self:GetSynCommonData();
	local nStable = LingTuZhan:CaclMapStable(tbSynCommon, tbSynMyKinInfo, nMapTemplateId)
	if nStable >= tbDefine.nMaxStable then
		return false, "当已经是最大稳定值"
	end
	--需要宣战日
	if not tbSynCommon.bOpenDeclareWar then
		return false, "只有宣战期间可以维持稳定"
	end

	return true,nil,nCostFound
end

function LingTuZhan:CanLevelUpWall( pPlayer, szKinKey, nMapTemplateId )
	local tbMapSeting = tbDefine.tbMapSeting[nMapTemplateId]
	if not tbMapSeting then
		return
	end
	if not tbMapSeting.Doors or #tbMapSeting.Doors == 0 then
		return false, "该领土没有城墙"
	end
	
	local tbGetMyOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey );
	if not tbGetMyOwnMapIds[nMapTemplateId] then
		return false, "只可对已占领的领土升级城墙"
	end

	local tbCostInfo = tbDefine.tbLevelUpWallCostFound[tbMapSeting.nStar]
	if not tbCostInfo then
		return false, "该星级领土没有城墙"
	end

	local tbSynMapInfo = LingTuZhan:GetSynMapInfo(nMapTemplateId)
	local nCurLevel = tbSynMapInfo.nWallLevel or 1;
	if nCurLevel >= #tbCostInfo then
		return false , "已经满级，无需升级"
	end
	local nCostFound = tbCostInfo[nCurLevel + 1] 
	--先判断资金
	local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
	if not tbSynMyKinInfo.nFound or tbSynMyKinInfo.nFound < nCostFound then
		return false, string.format("升级需要消耗%d资金", nCostFound) 
	end

	local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
    if not tbDefine.tbCanUpgradeBuildCareer[nMyCarrer] then
        return false, "族长、副族长和指挥才可以对城门进行升级" 
    end
	local tbSynCommon = self:GetSynCommonData();
	if tbSynCommon.bOpenWar then
		return false, "领土战期间，无法对城门进行升级"
	end

	return true,nil,nCostFound
end

function LingTuZhan:CanLevelUpDragonFlag( pPlayer, nMapTemplateId )
	local tbMapSeting = tbDefine.tbMapSeting[nMapTemplateId]
	if not tbMapSeting then
		return
	end
	local szKinKey = LingTuZhan:GetCombineKinKey(Sdk:GetTrueServerId(), pPlayer.dwKinId)
	local tbGetMyOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey );
	if not tbGetMyOwnMapIds[nMapTemplateId] then
		return false, "只可对已占领的领土升级龙柱"
	end

	local tbCostInfo = tbDefine.tbLevelUpDragonFlagCostFound[tbMapSeting.nStar]
	if not tbCostInfo then
		return false, "该星级领土不可升级龙柱"
	end

	local tbSynMapInfo = LingTuZhan:GetSynMapInfo(nMapTemplateId)
	local nCurLevel = tbSynMapInfo.nDragonFlagLevel or 1;
	if nCurLevel >= #tbCostInfo then
		return false , "已经满级，无需升级"
	end
	local nCostFound = tbCostInfo[nCurLevel + 1] 
	--先判断资金
	local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
	if not tbSynMyKinInfo.nFound or tbSynMyKinInfo.nFound < nCostFound then
		return false, string.format("升级需要消耗%d资金", nCostFound) 
	end

	local nMyCarrer = Kin:GetPlayerCareer( pPlayer.dwID)
    if not tbDefine.tbCanUpgradeBuildCareer[nMyCarrer] then
        return false, "族长、副族长和指挥才可以对龙柱进行升级" 
    end
	local tbSynCommon = self:GetSynCommonData();
	if tbSynCommon.bOpenWar then
		return false, "领土战期间，无法对龙柱进行升级"
	end
	return true,nil,nCostFound
end

function LingTuZhan:GetAllKinOwnMapIds(  )
	if not self.tbKinOwnMapIds then
		self.tbKinOwnMapIds = {};
		local tbSynAllMapOwn = LingTuZhan:GetSynAllMapOwnerInfo()
		-- [nMapId] = {nServerId, dwkinId,  szKinName}
		for nMapId, tbKinInfo in pairs(tbSynAllMapOwn) do
			local nServerId, dwkinId,  szKinName = unpack(tbKinInfo)
			local szCombineKey = LingTuZhan:GetCombineKinKey(nServerId, dwkinId)
			self.tbKinOwnMapIds[szCombineKey] = self.tbKinOwnMapIds[szCombineKey] or {};
			self.tbKinOwnMapIds[szCombineKey][nMapId] = 1;
		end
	end
	return self.tbKinOwnMapIds
end

function LingTuZhan:GetKinOwnMapIds( szKinKey )
	local tbKinOwnMapIds = self:GetAllKinOwnMapIds()
	return tbKinOwnMapIds[szKinKey] or {};
end

function LingTuZhan:FindAroundMaps( nCenterMapId,  tbFindedMapIds , tbFindedConnectMapIds, tbOwnMapIds)
	if not tbFindedMapIds[nCenterMapId] then
		tbFindedMapIds[nCenterMapId] = 1;
		if tbOwnMapIds[nCenterMapId] then
			tbFindedConnectMapIds[nCenterMapId] = 1;
		else
			return
		end
	end
	local tbAroundMaps = {};
	for k,v in pairs(tbDefine.tbConnectMapSetting[nCenterMapId]) do
		if not tbFindedMapIds[k] then
			self:FindAroundMaps(k, tbFindedMapIds, tbFindedConnectMapIds, tbOwnMapIds)
		end
	end
end

--获取 tbOwnMapIds 里最大的相连数
function LingTuZhan:GetMaxConnectMapList( tbOwnMapIds )
	local nMaxConnectCount = 0;
	for nMasterMapId,_ in pairs(tbOwnMapIds) do
		local tbFindedMapIds = {}
		local tbFindedConnectMapIds = {}
		LingTuZhan:FindAroundMaps( nMasterMapId,  tbFindedMapIds , tbFindedConnectMapIds, tbOwnMapIds)		
		local nCurCount = 0;
		for k,v in pairs(tbFindedConnectMapIds) do
			nCurCount = nCurCount + 1;
		end
		if nCurCount > nMaxConnectCount then
			nMaxConnectCount = nCurCount
		end
	end
	return nMaxConnectCount
end

function LingTuZhan:GetRevoverMapList(nMasterMapId, tbOwnMapIds )
	local tbFindedMapIds = {}
	local tbFindedConnectMapIds = {}
	LingTuZhan:FindAroundMaps( nMasterMapId,  tbFindedMapIds , tbFindedConnectMapIds, tbOwnMapIds)	
	local tbRecoveryIds = {};
	for k,v in pairs(tbOwnMapIds) do
		if not tbFindedConnectMapIds[k] then
			tbRecoveryIds[k] = 1;
		end
	end
	return 	tbRecoveryIds
end

function LingTuZhan:CaclMapStable(tbComon, tbKinSave, nMapTemplateId)
	-- 由于初始值到战斗前一天是都不能修改的，如果已经存值就是今天的，没存就计算应有值
	local nCurValue;
	if tbKinSave.tbMapStable and tbKinSave.tbMapStable[nMapTemplateId] then
		nCurValue = tbKinSave.tbMapStable[nMapTemplateId]
	else
		nCurValue = math.max(tbDefine.nMinStable, tbDefine.nDefaultStable - tbDefine.nMinuStableEveryDay * (Lib:GetLocalDay() - tbComon.nLastWarDay))
	end
	return nCurValue
end

function LingTuZhan:IsCanEnterBattle( pPlayer)
	--注意判断地图 ,因为还有从本服进前线营地的，还有已经在跨服的
	if tbDefine.tbMapSeting[pPlayer.nMapTemplateId] then
		return true
	end
 	if not AsyncBattle:CanStartAsyncBattle(pPlayer)  then
 		return false, "请在安全区域下参与活动"
 	end
	local tbComon = self:GetSynCommonData()
	if not tbComon.bOpenWar then
		return false, "当前未开放活动，不可以参战"
	end
	local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
	if not nMyCarrer then
		return false, "无家族不可参加"
	end
	if tbDefine.tbForbitEnterGameCarrer[nMyCarrer] then
		return false, string.format("%s不可以进入",Kin.Def.Career_Name[nMyCarrer])
	end
	local nMinLevel = 1;
	for i,v in ipairs(tbDefine.tbEnterFightLevelLimit) do
		if GetTimeFrameState(v[1]) == 1 then
			nMinLevel = v[2]
		else
			break;
		end
	end
	if pPlayer.nLevel < nMinLevel then
		return false, string.format("%d级以上才可进入", nMinLevel)
	end
	return true
end

function LingTuZhan:IsCanPlayerEnterFromMap( pPlayer, nMapTemplateId ,szKinKey)
	if pPlayer.nMapTemplateId == nMapTemplateId then
		return false, "您已经在该地图了"
	end
	local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
	--只可从已有的地图进或者进手动宣战的地图
	if tbSynMyKinInfo.nManulDeclareMapId and tbSynMyKinInfo.nManulDeclareMapId == nMapTemplateId then
		return true
	else
		local tbOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey )
		if tbOwnMapIds[nMapTemplateId] then
			return true
		end
	end
	return false, "该地图不可进入"
end

function LingTuZhan:IsOpenSeason(  )
	local tbComon = self:GetSynCommonData()
	return tbComon.nOpenSeason == Lib:GetLocalSeason();
end

function LingTuZhan:GetSupplyItemCount(pPlayer, nItemId )
	local tbKinBattleFightData = self:GetSynKinBattleFightData(pPlayer)
	local tbSupplyCount = tbKinBattleFightData.tbSupplyCount or {};
	local nDefaultCount = tbDefine.tbBattleApplyIdDefaultCount[nItemId] or 0
	return tbSupplyCount[nItemId] or nDefaultCount
end

function LingTuZhan:CanUseSupplyItem( pPlayer, nItemId, szKinKey)
	--家族资金主要是战斗期间其他玩家完成周目标也可能获得，所以还是放在了本服
	--使用道具都在本段判断算了，数据也是存本服，因为权限、家族资金的判断
	--玩家需要是在跨服状态 ，地图就不判断了 战斗阶段
	local tbComon = self:GetSynCommonData()
	if not tbComon.bOpenWar then
		return false, "当前未开放活动"
	end
	local nUseCost = tbDefine.tbBattleApplyUseCountCost[nItemId]
	if nUseCost then
		local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
		local nFound = tbSynMyKinInfo.nFound or 0
		if nUseCost > nFound then
			return false, string.format("当前领土资金不足%d,无法使用前线旗帜", nUseCost)
		end
	end
	local nCount = self:GetSupplyItemCount(pPlayer, nItemId)
	if nCount<= 0 then
		return false, "可使用个数不足"
	end
	local nTotalCount = tbDefine.tbBattleApplyCurTotalLimit[nItemId]
	if nTotalCount then
		if pPlayer.GetNpc().nShapeShiftNpcTID ~= 0 then
			return false, "您当前已经变身"
		end

		local tbKinBattleFightData = self:GetSynKinBattleFightData(pPlayer)
		local tbSupplyCurTotal = tbKinBattleFightData.tbSupplyCurTotal or {};
		local nCurCount = tbSupplyCurTotal[nItemId] or 0
		if nCurCount >= nTotalCount then
			return false, string.format("该物资最多同时使用%d个", nTotalCount)
		end
	end
	local tbNeedCarrer = tbDefine.tbBattleApplyUseCarrer[nItemId]
	if tbNeedCarrer then
		local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
		if not tbNeedCarrer[nMyCarrer] then
			return false, "您没有使用的权限"
		end
	end
	return true, nil, nCount
end

function LingTuZhan:CanBuildSupplyItem( pPlayer, nItemId , szKinKey)
	local tbComon = self:GetSynCommonData()
	if not tbComon.bOpenWar then
		return false, "当前未开放活动"
	end
	local nBuildCost = tbDefine.tbBattleApplyAddCountCost[nItemId]
	if nBuildCost then
		local tbSynMyKinInfo = self:GetSynKinInfo( szKinKey )
		local nFound = tbSynMyKinInfo.nFound or 0;
		if nBuildCost > nFound then
			return false, string.format("当前领土资金不足%d,无法建造", nBuildCost)
		end
	end
	local tbNeedCarrer = tbDefine.tbBattleApplyBuildCarrer[nItemId]
	if tbNeedCarrer then
		local nMyCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
		if not tbNeedCarrer[nMyCarrer] then
			return false, "您没有建造的权限"
		end
	end
	return true
end

function LingTuZhan:GetMapSetting( nMapTemplateId )
	return tbDefine.tbMapSeting[nMapTemplateId]
end

function LingTuZhan:InitSetting(  )
	local tbConnectMapSetting = {};
	for nMapId1,v1 in pairs(tbDefine.tbMapSeting) do
		for i2,v2 in ipairs(v1.tbAtackCamp) do
			if v2.tbConnetMap then
				local nMapId2 = v2.tbConnetMap[2]
				tbConnectMapSetting[nMapId1] = tbConnectMapSetting[nMapId1] or {};
				tbConnectMapSetting[nMapId1][nMapId2] = 1;

				tbConnectMapSetting[nMapId2] = tbConnectMapSetting[nMapId2] or {};
				tbConnectMapSetting[nMapId2][nMapId1] = 1;
			end
		end
	end
	tbDefine.tbConnectMapSetting = tbConnectMapSetting;
end


function LingTuZhan:IsOpenLingTuZhanThisWeek()
	if not LingTuZhan:IsOpenSeason() then
		return false
	end
	--季度初始月的 1-7号不开活动
	local tbTime = os.date("*t", GetTime())
	if tbTime.month % 3 == 1 and tbTime.day >= 1 and tbTime.day <= 7 then
		return false
	end
	--如果今天是周一且当天是季度最后一天，那么明天也是不开的，现在是固定周二开
	if Lib:GetLocalWeekDay() == 1 then
		local tbTimeTomorrow = os.date("*t", GetTime()+3600*24)
		if tbTimeTomorrow.month % 3 == 1 and tbTimeTomorrow.day == 1 then
			return false
		end
	end
	if Activity:__IsActInProcessByType(WuLinDaHui.szActNameMain) then
		return false
	end
	return true
end

function LingTuZhan:OpenActLTZ( bOpen )
	self.bOpenActLTZ = bOpen;
end

function LingTuZhan:IsOpenActLTZ(  )
	return self.bOpenActLTZ;
end

function LingTuZhan:IsOpenActLTZToDay(  )
	--活动临时处理
	if self.bOpenActLTZ and Lib:GetLocalWeekDay() == 7 then
		local nNow = Lib:GetLocalDayTime()
		return nNow < Lib:ParseTodayTime("21:40")
	end
end

function LingTuZhan:IsToDayLastSeasonMatch(  )
	local nNow = GetTime()
	local tbTimeNow = os.date("*t", nNow)    
	if tbTimeNow.month % 3 ~= 0 then
		return
	end
	--有活动，就是取最后一个周末，没活动，取最后一个周二, 看哪天时间靠后
	local nTimeRet = Lib:GetTimeByWeekInMonth(nNow, -1, 2, 21, 0, 0)
	local nDefaultDay = Lib:GetLocalDay(nTimeRet)
	local nActDay = 0;
	if self:IsOpenActLTZ() then
		 --活动那天，这周日仍然在这个月
		 local nTimeRet2 = Lib:GetTimeByWeekInMonth(nNow, -1, 7, 21, 0, 0)
		 if Lib:GetLocalWeek(nTimeRet2) == Lib:GetLocalWeek() then
			nActDay = Lib:GetLocalDay(nTimeRet2) 	
		 end
	end
	local nLastDay = math.max(nDefaultDay, nActDay)
	return nLastDay == Lib:GetLocalDay()
end

function LingTuZhan:GetCityMapIds(  )
	if tbDefine.tbCityMapIds then
		return tbDefine.tbCityMapIds
	end
	tbDefine.tbCityMapIds = {}
	for k,v in pairs(tbDefine.tbMapSeting) do
		if v.nType == LingTuZhan.tbConst.MAP_TYPE_CITY then
			table.insert(tbDefine.tbCityMapIds, k)
		end
	end
	return tbDefine.tbCityMapIds
end

LingTuZhan:InitSetting();
