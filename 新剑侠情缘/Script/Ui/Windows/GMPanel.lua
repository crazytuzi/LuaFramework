local tbUi = Ui:CreateClass("GMListPanel");

-- 我要各个AI的同伴 (同伴ID配置)
local tbAllTestAIPartner = "{57, 23, 13, 20, 22, 29, 12, 52, 26, 41, 37, 11, 21, 66}"

-- 决定显示顺序
local tbDataIndex =
{
	OneKeyShow 				= 1,					-- 一键演示
	QuicklyEquipment 		= 2,					-- 一键N级
	RefreshHp				= 3,					-- 回满血
	ActivtyOpen 			= 4,					-- 活动开启
	AddPower 				= 5,					-- 角色能力添加
	Money 					= 6,					-- 大量财富
	GainItem 				= 7,					-- 获取道具
	GainWaiYi 				= 8,					-- 获取道具
	Revive					= 9,					-- 满血复活
	nPartnerDataIndex		= 10,					-- 同伴同伴
	Role 					= 11,					-- XX级角色
	KinTool					= 12,					-- 家族工具
	House 					= 13,					-- 家园
	nLevelUpDataIndex		= 14,					-- 升级
	nHonorDataIndex			= 15,					-- 头衔
	BattleSignIn 			= 16,					-- 战场报名
	BaoZang 				= 17,					-- 宝藏
	TeamFuben 				= 18,					-- 组队副本
	RandomFuben 			= 19,					-- 随机秘境
	UnlockFuben 			= 20,					-- 开关卡
	AddItem 				= 21,					-- 增加指定道具
	TestClientPk 			= 22,					-- 客户端同屏PK测试
	CleanBag 				= 23,					-- 清空背包
	Refresh 				= 24,					-- 小功能
	ChangeFaction 			= 25,					-- 转门派
}

-- 动态初始化的索引
local nSSSPartnerSingleIndex		= 3
local nSSPartnerSingleIndex 		= 5
local nSPartnerSingleIndex 			= 7
local nAPartnerSingleIndex 			= 9
local nAllPartnerIndex 				= 12
-- local nCodeGift 					= 13

-- XX级角色 配置
local tbRoleData =
{
	[1] =
	{
		nLevel = 20,
		tbStrong = {5,10,20}, 					-- 强化
		tbInsert = {5,10,20},  					-- 镶嵌(前提是表里有数据)
	},
	[2] =
	{
		nLevel = 30,
		tbStrong = {10,20,30},
		tbInsert = {10,20,30},
	},
	[3] =
	{
		nLevel = 40,
		tbStrong = {20,30,40},
		tbInsert = {20,30,40},
	},
	[4] =
	{
		nLevel = 50,
		tbStrong = {30,40,50},
		tbInsert = {30,40,50},
	},
	[5] =
	{
		nLevel = 60,
		tbStrong = {40,50,60},
		tbInsert = {40,50,60},
	},
	[6] =
	{
		nLevel = 70,
		tbStrong = {50,60,70},
		tbInsert = {50,60,70},
	},
	[7] =
	{
		nLevel = 80,
		tbStrong = {60,70,80},
		tbInsert = {60,70,80},
	},
	[8] =
	{
		nLevel = 90,
		tbStrong = {70,80,90},
		tbInsert = {70,80,90},
	},
	[9] =
	{
		nLevel = 100,
		tbStrong = {80,90,100},
		tbInsert = {80,90,100},
	},
	[10] =
	{
		nLevel = 110,
		tbStrong = {90,100,110},
		tbInsert = {90,100,110},
	},
	[11] =
	{
		nLevel = 120,
		tbStrong = {90,100,110},
		tbInsert = {100,110,120},
	},
	[12] =
	{
		nLevel = 130,
		tbStrong = {100,110,120},
		tbInsert = {100,110,120},
	},
	[13] =
	{
		nLevel = 140,
		tbStrong = {100,110,120},
		tbInsert = {100,110,120},
	},
	[14] =
	{
		nLevel = 150,
		tbStrong = {110,120,130},
		tbInsert = {100,110,120},
	},
	[15] =
	{
		nLevel = 160,
		tbStrong = {110,120,130},
		tbInsert = {100,110,120},
	},
	[16] =
	{
		nLevel = 170,
		tbStrong = {110,120,130},
		tbInsert = {100,110,120},
	},
}

-- 等级提升等级段配置
local nMaxLevelUp = 17

tbUi.tbGMData = {
	[tbDataIndex.OneKeyShow] = {
		Text = "一键演示",
		szCallback = "GM:OneKeyShow()",
	},

	[tbDataIndex.QuicklyEquipment] =
	{
		Text = "一键N级",
		tbChild = {
			{
				Text = "一键40级",
				szCallback = "GM:QuicklyEquipment()",
			},
			{
				Text = "一键80级",
				szCallback = "GM:QuicklyEquipment2()",
			},
			{
				Text = "一键100级",
				szCallback = "GM:QuicklyEquipment3()",
			},
			{
				Text = "一键110级",
				szCallback = "GM:QuicklyEquipment4()",
			},
			{
				Text = "一键130级",
				szCallback = "GM:QuicklyEquipment5()",
			},
			{
				Text = "一键159级",
				szCallback = "GM:QuicklyEquipment6()",
			},
			{
				Text = "进监狱",
				szCallback = [[
					me.AddMoneyDebt("Gold", 999999, 0);
					me.CheckMoneyDebt("Gold")
					me.PushToPrison(GetTime() + 24 * 3600);
					Map:CheckPushToPrison(me);
				]],
			},
		}
	},

	[tbDataIndex.RefreshHp] = {
		Text = "回满血",
		szCallback = "GM:RefreshHp()",
	},

	[tbDataIndex.ActivtyOpen] = {
		Text = "活动开启",
		tbChild = {
			{
				Text = "跨服",
				tbChild = {
					{
						Text = "去跨服",
						szCallback = "GM:GoZoneserver()",
					},
					{
						Text = "设置跨服1",
						szCallback = "GM:ChangeZoneConnect()",
					},
					{
						Text = "返回主服务器",
						szCallback = {"me.ZoneLogout()"},
					},
					{
						Text = "查看跨服血量",
						szCallback = {"Log(me.GetNpc().nCurLife); me.CenterMsg(me.GetNpc().nCurLife); "},
					},
				},
			},
			{
				Text = "拍卖行",
				tbChild = {
					{
						Text = "开启家族拍卖",
						szCallback = "GM:KinAuction()",
					},
					{
						Text = "开启西域行商",
						szCallback = "GM:StartAuctionDealer()",
					},
				},
			},
			{
				Text = "结婚功能",
				tbChild = {
					{
						Text = "获得求婚道具",
						szCallback = "GM:AddProposeItem()",
					},
					{
						Text = "队员互加好友",
						szCallback = "GM:ForceTeamAddFriend()",
					},
					{
						Text = "队员设置亲密度",
						szCallback = "GM:ForceTeamSetImitity()",
					},
					{
						Text = "查看预约婚期数据",
						szCallback = "GM:LogScheduleData()",
					},
					{
						Text = "庄园·晚樱连理道具",
						szCallback = "GM:WeddingItem1()",
					},
					{
						Text = "海岛·红鸾揽月道具",
						szCallback = "GM:WeddingItem2()",
					},
					{
						Text = "舫舟·乘龙配凤道具",
						szCallback = "GM:WeddingItem3()",
					},
					{
						Text = "开启婚礼",
						szCallback = "GM:TryStartBookWedding()",
					},
					{
						Text = "强制结束结婚副本",
						szCallback = "GM:CloseWedding()",
					},
					{
						Text = "增加请柬",
						szCallback = "GM:WeedingWelcomeCount()",
					},
					{
						Text = "设置结婚关系",
						szCallback = "GM:MakeMarry()",
					},
					{
						Text = "离婚",
						szCallback = "GM:Divorce()",
					},
					{
						Text = "花轿游程开启",
						szCallback = "GM:StartCityTour()",
					},
					{
						Text = "结束花轿游程",
						szCallback = "GM:CloseCityTour()",
					},
					{
						Text = "获取誓言修改道具",
						szCallback = "GM:AddWeddingPromiseItem()",
					},
					{
						Text = "输出检查结婚时的性别",
						szCallback = "GM:CheckWeddingKeyGender()",
					},
					{
						Text = "输出检查结婚称号是否修改",
						szCallback = "GM:CheckWeddingTitlePostfix()",
					},
				},
			},
			{
				Text = "武林盟主",
				tbChild = {
				{
						Text = "挑战武林盟主",
						szCallback = "GM:OpenBossActivity()",
				},
				{
						Text = "关闭武林盟主",
						szCallback = "GM:EndFinishBoss()",
				},
				{
						Text = "去除CD",
						szCallback = "GM:BossFightCd()",
				},
				{
						Text = "开启跨服盟主",
						szCallback = "GM:StartZBoss()",
				},
				{
						Text = "关闭跨服盟主",
						szCallback = "GM:EndZBoss()",
				},
				{
						Text = "跨服累计积分",
						szCallback = "GM:AddKinScoreToZBoss()",
				},
				},
			},
			{
				Text = "武神殿",
				szCallback = "GM:OpenRankPanel()",
			},
			{
				Text = "群英会",
				tbChild = {
					{
						Text = "开启群英会",
						szCallback = "GM:QunYingHuiOpen()",
					},
					{
						Text = "进入群英会",
						szCallback = "GM:QunYingHuiJoin()",
					},
					{
						Text = "计算时间轴(跨服执行)",
						szCallback = {"QunYingHuiCross.tbQunYingHuiZ:PreStart()"},
					},
					{
						Text = "开启跨服群英会活动(跨服执行)",
						szCallback = {"QunYingHuiCross.tbQunYingHuiZ:Start()"},
					},
				},
			},
			{
				Text = "战场",
				tbChild = {
					{
						Text = "开启新手战场",
						szCallback = "GM:OpenAloneBattle()",
					},
					{
						Text = "开启元帅战场",
						szCallback = "GM:OpenBattle()",
					},
					{
						Text = "开启杀戮战场",
						szCallback = "GM:OpenBatte1()",
					},
					{
						Text = "开启宋金攻防战",
						szCallback = "GM:OpenBatte8()",
					},
					{
						Text = "关闭战场报名",
						szCallback = "GM:StopBattleSignUp()",
					},
					{
						Text = "增加战场次数",
						szCallback = "GM:AddDegreeBattle()",
					},
				},
			},
			{
				Text = "野外首领",
				tbChild = {
					[1] = {
						Text = "开启野外首领",
						szCallback = "GM:OpenBoss()",
					},
					[2] = {
						Text = "关闭野外首领",
						szCallback = "GM:CloseBoss()",
					},
				},
			},
			--[[
			{
				Text = "武林隐居高手",
				tbChild = {
					[1] = {
						Text = "刷新武林隐居高手",
						szCallback = "GM:StartNewBoss()",
					},
					[2] = {
						Text = "关闭武林隐居高手",
						szCallback = "GM:CloseNewBoss()",
					},
				},
			},
			]]
			{
				Text = "神之墓地",
				tbChild = {
					[1] = {
						Text = "开启神之墓地",
						szCallback = "GM:StartHomeBB01()",
					},
					[2] = {
						Text = "关闭神之墓地",
						szCallback = "GM:EndHomeBB()",
					},
				},
			},
			{
				Text = "历代名将",
				tbChild = {
					{
						Text = "开启历代名将地图",
						szCallback = "GM:PreStartBossLeader()",
					},
					{
						Text = "开启历代名将",
						szCallback = "GM:StartBossLeader()",
					},
					{
						Text = "关闭历代名将",
						szCallback = "GM:CloseBossLeader()",
					},
					{
						Text = "检查跨服名将",
						szCallback = {"BossLeader:CheckServerCrossBossInfoZ();"},
					},
					{
						Text = "家族获得跨服名将资格",
						szCallback = "GM:BossLeaderCrossAllKinSave()",
					},
					{
						Text = "跨服名将开地图",
						szCallback = {"BossLeader:PreStartCrossBossZ();"},
					},
					{
						Text = "开跨服名将",
						szCallback = {"BossLeader:StartCrossBossZ();"},
					},
					{
						Text = "关跨服名将",
						szCallback = {"BossLeader:EndCrossBossZ();"},
					},
				},
			},
			{
				Text = "通天塔",
				tbChild = {
					{
						Text = "修改队伍人数为一人",
						szCallback = "GM:TeamBattleMemeber()",
					},
					{
						Text = "开启通天塔",
						szCallback = "GM:OpenTeamBattle()",
					},
					{
						Text = "开启跨服通天塔",
						szCallback = "GM:OpenTeamBattle_Cross()",
					},
					{
						Text = "进入通天塔",
						szCallback = "GM:EnterTeamBattle()",
					},
					{
						Text = "所有在线玩家参加通天塔\n(组队除外)",
						szCallback = "GM:TryJoinPreMapTeamBattle()",
					},
					{
						Text = "在线玩家组成三人队伍(活动开启后执行)",
						szCallback = "GM:ThreePeopleTeam()",
					},
					{
						Text = "所有队伍参加通天塔(活动开启后执行)",
						szCallback = "GM:TeamBattleAllTeam()",
					},
					{
						Text = "重置通天塔消耗次数",
						szCallback = "GM:TeamBattleUserValue()",
					},
					{
						Text = "[B03060]在线[-]所有玩家重置消耗次数",
						szCallback = "GM:TeamBattlePlayerUserValue()",
					},
					{
						Text = "[B03060]在线[-]所有玩家去除门票",
						szCallback = "GM:TeamBatlePlayerSetUserValue()",
					},
					{
						Text = "查询通天塔剩余荣誉",
						szCallback = "GM:TeamBattleHONOR()",
					},
					{
						Text = "月度通天塔资格获得\n(开赛前执行)",
						szCallback = "GM:TeamBattleMONTHLY()",
					},
					{
						Text = "季度通天塔资格获得\n(开赛前执行)",
						szCallback = "GM:TeamBattleQUARTERLY()",
					},
					-- {
					-- 	Text = "年度通天塔资格获得\n(开赛前执行)",
					-- 	szCallback = "GM:TeamBattleYEAR()",
					-- },
				},
			},
			{
				Text = "本服攻城战",
				tbChild = {
					{
						Text = "缩短攻城战时间&基准人数(服务端)",
						szCallback = "GM:DomainBattleTimeAndFlagScore()",
					},
					{
						Text = "缩短攻城战时间&基准人数(客户端)",
						szCmd = [[DomainBattle.define.tbFlagScore = {[1] = {[3] = {32000000 * 0.5, 1}, [2] = {32000000 * 0.25, 1}, }, [2] = {[3] = {16000000 * 0.5, 1}, [2] = {16000000 * 0.25, 1}, }, [3] = {[3] = {8000000, 1}, },};DomainBattle.define.tbActOwnerScoreSetting = {[1] = {8000000, 1};[2] = {4000000, 1};[3] = {2000000, 1};}; DomainBattle.STATE_TRANS = {{nSeconds = 30, szFunc = "StartFight", szDesc = "准备阶段"},{nSeconds = 300, szFunc = "StopFight", szDesc = "战斗阶段"},{nSeconds = 10, szFunc = "CloseBattle", szDesc = "结算阶段"},};]];
					},
					{
						Text = "开启攻城战宣战",
						szCallback = "GM:StartDomainBattleDeclareWar()",
					},
					{
						Text = "开启攻城战战场",
						szCallback = "GM:StartDomainBattleActivity()",
					},
					{
						Text = "查看攻城战届数",
						szCallback = "GM:GetValueDomainBattle()",
					},
					{
						Text = "领地行商(需占领领地)",
						szCallback = "GM:AddOnwenrDomainBattle()",
					},
					{
						Text = "在线的人都参战\n(需要家族宣战)",
						szCallback = "GM:CometomeDomain()",
					},
					{
						Text = "设立襄阳城主雕像\n(需要角色为领袖)",
						szCallback = "GM:SetMasterStatue()",
					},
					{
						Text = "攻下襄阳城的拍卖",
						szCallback = "GM:DomainBattleAuctionXiangYang()",
					},
				},
			},
			{
				Text = "跨服攻城战",
				tbChild = {
					{
						Text = "查询跨服攻城战上次开启日期",
						szCallback ="GM:CrossDomainBattleOpenLatTime()",
					},
					{
						Text = "查询跨服攻城战本次开启日期",
						szCallback ="GM:CrossDomainBattleOpenTime()",
					},
					{
						Text = "查询跨服攻城战下次开启日期",
						szCallback ="GM:CrossDomainBattleOpenNextTime()",
					},
					{
						Text = "查询个人剩余跨服城战荣誉",
						szCallback = "GM:SurplusCrossDomainHonor()",
					},
					{
						Text = "增加本家族积分（主城）",
						szCallback = "GM:AddDomainBattleLocalScore1()",
					},
					{
						Text = "增加本家族积分（村镇）",
						szCallback = "GM:AddDomainBattleLocalScore2()",
					},
					{
						Text = "增加本家族积分（野外）",
						szCallback = "GM:AddDomainBattleLocalScore3()",
					},
					{
						Text = "查询所有家族积分",
						szCallback = "GM:DomainBattleCrossScore()",
					},
					{
						Text = "清除所有家族积分",
						szCallback = "GM:DomainBattleClearLocalData()",
					},
					{
						Text = "生成参战家族名单",
						szCallback ="GM:DomainBattleOnLocalBattleEnd()",
					},
					{
						Text = "把自己家族设置成占领襄阳城",
						szCallback = "GM:DomainBattleMapOwner()",
					},
					{
						Text = "去掉开启日期限制",
						szCallback = "GM:Removedatelimit()",
					},
					{
						Text = "去掉开启日期限制(跨服)",
						szCallback ={"function DomainBattle.tbCross:CheckCrossDay() return true end"},
					},
					
					{
						Text = "开始助战报名",
						szCallback ="GM:DomainBattleOnStartAidSignUp()",
					},
					{
						Text = "不清除本服参战权限数据，方便重开",
						szCallback ="GM:DomainBattleNoClearLocalData()",
					},
					{
						Text = "开战前上报本服数据到跨服(步骤1)",
						szCallback ="GM:OnCrossDomainPrepareNotice()",
					},
					{
						Text = "创建战斗地图(步骤2)",
						szCallback ={"ScheduleTask:OnCrossDomainCreateMap()"},
					},
					{
						Text = "开战(步骤3)",
						szCallback ={"ScheduleTask:OnCrossDomainStart()"},
					},
					{
						Text = "进入请求(步骤4)",
						szCallback ="GM:DomainBattleEnterRequest()",
					},
					{
						Text = "不用准备直接开战",
						szCallback ={"DomainBattle.tbCross:StartBattle()"},
					},
					{
						Text = "直接进入王城",
						szCallback ={"local tbPlayerInfo = DomainBattle.tbCross:GetPlayerInfo(me.dwID);local tbKingInst = DomainBattle.tbCross:GetKingInst();tbKingInst:TransferToKinCamp(tbPlayerInfo.nKinId, me);"},
					},
					{
						Text = "直接进入内城",
						szCallback ={"local tbPlayerInfo = DomainBattle.tbCross:GetPlayerInfo(me.dwID);local tbKinInfo = DomainBattle.tbCross:GetKinInfo(tbPlayerInfo.nKinId);local nInnerMapId = tbKinInfo.nInnerMapId;local tbInnerInst = DomainBattle.tbCross.tbInstList[nInnerMapId];tbInnerInst:TransferToKinCamp(tbPlayerInfo.nKinId, me);"},
					},
					{
						Text = "清除王城占领王座",
						szCallback ={"local tbKingInst = DomainBattle.tbCross:GetKingInst();tbKingInst:ClearThroneFight();"},
					},
					{
						Text = "清除内城占领王座",
						szCallback ={"local tbPlayerInfo = DomainBattle.tbCross:GetPlayerInfo(me.dwID);local tbKinInfo = DomainBattle.tbCross:GetKinInfo(tbPlayerInfo.nKinId);local nInnerMapId = tbKinInfo.nInnerMapId;local tbInnerInst = DomainBattle.tbCross.tbInstList[nInnerMapId];tbInnerInst:ClearThroneFight();"},
					},
					{
						Text = "强制结束",
						szCallback ={" if DomainBattle.tbCross.nMainTimer then Timer:Close(DomainBattle.tbCross.nMainTimer) DomainBattle.tbCross.nMainTimer = nil DomainBattle.tbCross.nCurStateIndex = 4 DomainBattle.tbCross:NextState() end"},
					},
					{
						Text = "设立临安城主雕像\n(需要角色为领袖)",
						szCallback ="GM:CrossDomainBattleEnterRequest()",
					},
					{
						Text = "临安城主拍卖",
						szCallback ="GM:CrossDomainBattleLocalAward()",
					},
				},
			},
			{
				Text = "白虎堂",
				tbChild = {
					{
						Text = "开启白虎堂",
						szCallback = "GM:OpenWhiteTigerFuben()",
					},
					{
						Text = "进入白虎堂准备场",
						szCallback = "GM:EnterWhiteTigerFuben()",
					},
					{
						Text = "开启白虎堂第五层",
						szCallback = {"Fuben.WhiteTigerFuben:BeginCrossFight();"},
					},
					{
						Text = "关闭白虎堂",
						szCallback = "GM:CloseWhiteTigerFuben()",
					},
					{
						Text = "白虎堂次数+1",
						szCallback = "GM:AddDegreeWhiteTigerFuben()",
					},
				},
			},
			{
				Text = "门派竞技",
				tbChild = {
					{
						Text = "开启门派竞技(本服)",
						szCallback = "GM:OpenFactionBattle()",
					},
					{
						Text = "参加门派竞技",
						szCallback = "GM:JoinFactionBattle()",
					},
					{
						Text = "关闭门派竞技",
						szCallback = "GM:CloseFactionBattle()",
					},
					{
						Text = "开启评选",
						szCallback = "GM:StartFactionMonkey()",
					},
					{
						Text = "关闭评选",
						szCallback = "GM:EndFactionMonkey()",
					},
					{
						Text = "月度赛加资格",
						szCallback = "GM:FactionBattleLocal8th()",
					},
					{
						Text = "门派竞技月度赛(本服)",
						szCallback = "GM:FactionBattleMonthBattleOpen()",
					},
					{
						Text = "门派竞技月度赛(跨服)",
						szCallback = {"function FactionBattle:IsMonthBattleOpen() return true end"},
					},
					{
						Text = "季度赛加资格",
						szCallback = "GM:FactionBattleMonthly8th()",
					},
					{
						Text = "门派竞技季度赛(本服)",
						szCallback = "GM:FactionBattleSeasonBattleOpen()",
					},
					{
						Text = "门派竞技季度赛(跨服)",
						szCallback = {"function FactionBattle:IsSeasonBattleOpen() return true end"},
					},
					{
						Text = "开门派竞技(跨服)\n 先开本服再开跨服 ",
						szCallback = {"ScheduleTask:StartFactionBattle()"},
					},
					{
						Text = "关闭门派竞技(跨服)",
						szCallback = {"FactionBattle:Close()"},
					},
				},
			},
			{
				Text = "家族试炼",
				tbChild = {
					[1] = {
						Text = "开启家族试炼",
						szCallback = "GM:OpenKinTrain()",
					},
					[2] = {
						Text = "进入家族试炼",
						szCallback = "GM:EnterKinTrain()",
					},
					[3] = {
						Text = "家族试炼开启(精简版 - 一人即可)",
						szCallback = "GM:KinTrainMgrStart()",
					},
				},
			},
			{
				Text = "秦始皇陵",
				tbChild = {
					{
						Text = "进入皇陵",
						szCallback = "GM:EnterTombRequest()",
					},
					{
						Text = "进入2层",
						szCallback = "GM:EnterNormalFloor2()",
					},
					{
						Text = "进入3层",
						szCallback = "GM:EnterNormalFloor3()",
					},
					{
						Text = "增加表秦陵时间",
						szCallback = "GM:ImperialTombAddTime()",
					},
					{
						Text = "清除表秦陵时间\n（需先消耗再执行）",
						szCallback = "GM:ImperialTombClearTime()",
					},
					{
						Text = "召唤百将",
						szCallback = "GM:ImperialTombCallLeader()",
					},
					{
						Text = "密室邀请",
						szCallback = "GM:ImperialTombSecretRoom()",
					},
					{
						Text = "密室刷怪",
						szCallback = "GM:ImperialTombSpawnSecret()",
					},
					{
						Text = "开启始皇降世",
						szCallback = "GM:OpenEmperor()",
					},
					{
						Text = "开启女帝疑冢",
						szCallback = "GM:OpenEmperor1()",
					},
					{
						Text = "进入始皇降世地图",
						szCallback = "GM:EnterEmperorRoom()",
					},
					{
						Text = "刷新始皇降世首领",
						szCallback = "GM:CallBoss()",
					},
					{
						Text = "刷新始皇降世秦始皇",
						szCallback = "GM:CallEmperor()",
					},
					{
						Text = "关闭始皇降世",
						szCallback = "GM:CloseEmperor()",
					},
				},
			},
			{
				Text = "华山论剑",
				tbChild = {
					{
						Text = "开启预选赛",
						szCallback = "GM:StartEnterHuaShanLunJian()",
					},
					{
						Text = "进入预选赛准备场",
						szCallback = "GM:EnterHuaShanLunJian()",
					},
					{
						Text = "拉人入战队(需组队)",
						szCallback = "GM:JoinFightTeamHuaShanLunJian()",
					},
					{
						Text = "关闭预选赛",
						szCallback = "GM:CloseEnterHuaShanLunJian()",
					},
					{
						Text = "开启决赛\n(重复开需要重启服务器哦)",
						szCallback = "GM:StartFinalsHuaShanLunJian()",
					},
					{
						Text = "进入决赛场",
						szCallback = "GM:PlayerEnterHuaShanLunJian()",
					},
					{
						Text = "获取八强信息(最新消息)",
						szCallback = "GM:InformFinalsFightTeamListHuaShanLunJian()",
					},
				},
			},
			{
				Text = "心魔幻境(跨服)",
				tbChild = {
					{
						Text = "修改队伍数为2",
						szCallback = {"InDifferBattle.tbBattleTypeSetting.Normal.nMinTeamNum = 2;"},
					},
					{
						Text = "修改准备场时间为60秒",
						szCallback = {"InDifferBattle.tbDefine.MATCH_SIGNUP_TIME = 60;"},
					},
					{
						Text = "开启心魔幻境",
						szCallback = "GM:InDifferBattleStart()",
					},
					{
						Text = "开启心魔绝地",
						szCallback = {"InDifferBattle:OpenSignUp('JueDi');"},
					},
					{
						Text = "增加心魔次数",
						szCallback = "GM:InDifferBattleDegree()",
					},
					{
						Text = "添加心魔宝珠",
						szCallback = "GM:AddInDifferBattleItem()",
					},
					{
						Text = "获得全部物品\n (秘籍自买)",
						szCallback = {"me.AddItem(3308,4); me.AddItem(3299,600); me.AddItem(3307,1); me.AddItem(2400,1); me.AddItem(1392,1); me.AddMoney('Jade', 9999);"},
					},
				},
			},
			{
				Text = "遗迹寻宝(跨服)\n (顺序执行)",
				tbChild = {
					{
						Text = "查询当前累计积分",
						szCallback = "GM:KeyQuestFubenIntegral()",
					},
					{
						Text = "①准备时间改为1分钟",
						szCallback = {"local DEFINE = Fuben.KeyQuestFuben.DEFINE; DEFINE.SIGNUP_TIME = 60 * 1;"},
					},
					{
						Text = "②修改遗迹寻宝参加人数\n(两支队伍，每支队伍两人)",
						szCallback = {"local DEFINE = Fuben.KeyQuestFuben.DEFINE; DEFINE.MIN_OPEN_NUM = 4; DEFINE.MAX_TEAM_ROLE_NUM = 2; DEFINE.OPENM_MATCH_NUM_FROM =  {  [1] = { 2, 3 }; [2] = { 2, 3 }; [3] = { 2, 3 };};"},
					},
					{
						Text = "③开启遗迹寻宝",
						szCallback = {"Fuben.KeyQuestFuben:StartSignUp()"},
					},
					{
						Text = "当前地图所有人获取资格\n(只在第一、二层执行)",
						szCallback = {"local tbInst = Fuben.tbFubenInstance[me.nMapId]; local tbPlayers = KPlayer.GetMapPlayer(me.nMapId); for i,pPlayer in ipairs(tbPlayers) do 	tbInst:PlayerGetKey(pPlayer) end "},
					},					
				},
			},
		},
	},

	[tbDataIndex.AddPower] = {
		Text = "角色能力添加\n [B0E2FF]乀(ˉεˉ乀)[-] ",
		tbChild = {
			{
				Text = "全能小强变身\n[FF1493]╮(╯▽╰)╭ [-]",
				szCallback = "GM:SwitchSkillState()",
			},
			{
				Text = "跨服小强变身\n[FF1493]╰(`□′)╯[-]",
				szCallback = {"GM:SwitchSkillState()"},
			},
			{
				Text = "全能大强变身\n[FF1493]╰(`□′)╯[-]",
				szCallback = "GM:SwitchSkillState1()",
			},
			{
				Text = "跨服大强变身\n[FF1493]╰(`□′)╯[-]",
				szCallback = {"GM:SwitchSkillState1()"},
			},
			{
				Text = "10倍界王拳\n[FF1493]～(￣▽￣～)[-]",
				szCallback = "GM:SwitchSkillState2()",
			},
			{
				Text = "20倍界王拳\n[FF1493]┑(￣Д ￣)┍ [-]",
				szCallback = "GM:SwitchSkillState3()",
			},
			{
				Text = "30倍界王拳\n[FF1493](～￣▽￣)～ [-]",
				szCallback = "GM:SwitchSkillState4()",
			},
		},
	},

	[tbDataIndex.Money] = {
		Text = "大侠，发财吗 \n [B03060](～o▔▽▔)～o [-]",
		tbChild = {
			{
				Text = "加钱999999",
				szCallback = "GM:GMAddMoney(999999)",
			},
			{
				Text = "购买周卡",
				szCallback = "GM:BuyWeekCardCallBack()",
			},
			{
				Text = "购买月卡",
				szCallback = "GM:BuyMonCardCallBack()",
			},
			{
				Text = "购买至尊周卡",
				szCallback = "GM:BuySuperWeekCardCallBack()",
			},
			{
				Text = "1元礼包",
				szCallback = "GM:OnBuyDayCardCallBack1()",
			},
			{
				Text = "3元礼包",
				szCallback = "GM:OnBuyDayCardCallBack3()",
			},
			{
				Text = "6元礼包",
				szCallback = "GM:OnBuyDayCardCallBack6()",
			},
			{
				Text = "充值档次\n(实际只加赠送的元宝)",
				tbChild = {
					{
						Text = "6 RMB",
						szCallback = "GM:OnTotalRechargeChange6RMB()",
					},
					{
						Text = "30 RMB",
						szCallback = "GM:OnTotalRechargeChange30RMB()",
					},
					{
						Text = "98 RMB",
						szCallback = "GM:OnTotalRechargeChange98RMB()",
					},
					{
						Text = "198 RMB",
						szCallback = "GM:OnTotalRechargeChange198RMB()",
					},
					{
						Text = "328 RMB",
						szCallback = "GM:OnTotalRechargeChange328RMB()",
					},
					{
						Text = "648 RMB",
						szCallback = "GM:OnTotalRechargeChange648RMB()",
					},
				},
			},
			{
				Text = "[00FF00]一本万利·壹[-]",
				szCallback = "GM:OnBuyInvestCallBack1()",
			},
			{
				Text = "[00FF00]一本万利·贰[-]",
				szCallback = "GM:OnBuyInvestCallBack2()",
			},
			{
				Text = "[00FF00]一本万利·叁[-]",
				szCallback = "GM:OnBuyInvestCallBack3()",
			},
			{
				Text = "[00FF00]一本万利·肆[-]",
				szCallback = "GM:OnBuyInvestCallBack4()",
			},
			{
				Text = "[00FF00]一本万利·伍[-]",
				szCallback = "GM:OnBuyInvestCallBack5()",
			},
			{
				Text = "[00FF00]一本万利·陆[-]",
				szCallback = "GM:OnBuyInvestCallBack6()",
			},
			{
				Text = "[00FF00]一本万利·柒[-]",
				szCallback = "GM:OnBuyInvestCallBack7()",
			},
			{
				Text = "[00FF00]一本万利·捌[-]",
				szCallback = "GM:OnBuyInvestCallBack8()",
			},
			{
				Text = "[00FF00]一本万利·回归[-]",
				szCallback = "GM:OnBuyInvestCallBackRegression()",
			},
			
		},
	},

	[tbDataIndex.GainItem] = {
		Text = "获取道具",
		szCallback = "GM:GetItem()",
	},
	[tbDataIndex.GainWaiYi] = {
		Text = "获取所有外装",
		szCallback = "GM:GetAllWaiyi()",	
	},

	[tbDataIndex.Revive] = {
		Text = "信春哥，满血复活",
		szCallback = "GM:Revive()",
	},

	[tbDataIndex.nPartnerDataIndex] = {
		Text = "同伴&门客\n [8B864E]~@^_^@~[-]",
		tbChild = {
			[1] = {
				Text = "经脉",
				tbChild = {
					{
						Text = "完成经脉任务",
						szCallback = "GM:JingMaiTFlg()",
					},
					{
						Text = "一键经脉",
						szCallback = "GM:JingMaiLevel()",
					},
					{
						Text = "获得真气",
						szCallback = "GM:ZhneQiAdd()",
					},
				},
			},
			[2] = {
				Text = "我要SSS级所有同伴",
				szCallback = string.format("GM:AddQualityPartner(1)"),
			},
			[nSSSPartnerSingleIndex] = {
				Text = "我要SSS级单个同伴",
				tbChild = {},
			},
			[4] = {
				Text = "我要SS级所有同伴",
				szCallback = string.format("GM:AddQualityPartner(2)"),
			},
			[nSSPartnerSingleIndex] = {
				Text = "我要SS级单个同伴",
				tbChild = {},
			},
			[6] = {
				Text = "我要S级所有同伴",
				szCallback = string.format("GM:AddQualityPartner(3)"),
			},
			[nSPartnerSingleIndex] = {
				Text = "我要S级单个同伴",
				tbChild = {},
			},
			[8] = {
				Text = "我要A级所有同伴",
				szCallback = string.format("GM:AddQualityPartner(4)"),
			},
			[nAPartnerSingleIndex] = {
				Text = "我要A级单个同伴",
				tbChild = {},
			},
			[10] = {
				Text = "我要各个AI的同伴",
				szCallback = string.format("GM:AddAIPartner(%s)",tbAllTestAIPartner),
			},
			[11] = {
				Text = "给上阵同伴升级",
				szCallback = string.format("GM:AddPartnerExp()"),
			},		
			[nAllPartnerIndex] = {
				Text = "所有同伴\n (按照ID排序)",
				tbChild = {},
			},
			[13] = {
				Text = "同伴技能书",
				tbChild = {
					{
						Text = "获取全1级(白色)技能书",
						szCallback = "GM:SkillBook1()",
					},
					{
						Text = "获取全2级(绿色)技能书",
						szCallback = "GM:SkillBook2()",
					},
					{
						Text = "获取全3级(蓝色)技能书",
						szCallback = "GM:SkillBook3()",
					},
					{
						Text = "获取全4级(紫色)技能书",
						szCallback = "GM:SkillBook4()",
					},
					{
						Text = "获取全5级(橙色)技能书",
						szCallback = "GM:SkillBook5()",
					},
				},
			},
			[14] = {
				Text = "同伴本命武器",
				tbChild = {
					{
						Text = "获取SSS级同伴本命武器",
						szCallback = "GM:CallPartnerSSSWeapon()",
					},
					{
						Text = "获取SS级同伴本命武器",
						szCallback = "GM:CallPartnerSSWeapon()",
					},
					{
						Text = "获取S级同伴本命武器",
						szCallback = "GM:CallPartnerSWeapon()",
					},
					{
						Text = "获取A级同伴本命武器",
						szCallback = "GM:CallPartnerAWeapon()",
					},
				},
			},
			[15] = {
				Text = "门客",
				tbChild = {
					{
						Text = "获取所有门客",
						szCallback = "GM:GetPartnerCard()",
					},
					{
						Text = "所有门客友好度增加",
						szCallback = "GM:PartnerCardAddCardExp()",
					},
				},
			},
		},
	},
	[tbDataIndex.Role] = {
		Text = "XX级角色\n 各种强化镶嵌妥妥的",
		tbChild = {},
	},
	[tbDataIndex.nLevelUpDataIndex] = {
		Text = "等级升级",
		tbChild = {},
	},
	[tbDataIndex.nHonorDataIndex] = {
		Text = "头衔升级",
		tbChild = {},
	},
	[tbDataIndex.BattleSignIn] = {
		Text = "战场报名",
		szCallback = "GM:OpenBattleSignUp()",
	},

	[tbDataIndex.BaoZang] = {
		Text = "兄弟，寻宝吗\n[40E0D0]ㄟ(▔皿▔ㄟ)[-] ",
		tbChild = {
			[1] = {
				Text = "来一打藏宝图",
				szCallback = "GM:AddCangbaotu()",
			},
			[2] = {
				Text = "来一打高级藏宝图",
				szCallback = "GM:AddSeniorCangbaotu()",
			},
		}
	},

	[tbDataIndex.TeamFuben] = {
		Text = "组队副本",
		tbChild = {
			[1] = {
				Text ="20级秘境",
				szCallback = "GM:Go2TeamFuben(1,1)",
			},
			[2] = {
				Text ="40级秘境",
				szCallback = "GM:Go2TeamFuben(1,2)",
			},
			[3] = {
				Text ="60级秘境",
				szCallback = "GM:Go2TeamFuben(1,3)",
			},
		},
	},

	[tbDataIndex.RandomFuben] = {
		Text = "凌绝峰\n ########### \n 地宫副本",
		tbChild = {},
	},

	[tbDataIndex.AddItem] = {
		Text = "增加指定道具",
		szCallback = "GM:AddItemList()",
	},

	[tbDataIndex.TestClientPk] = {
		Text = "客户端同屏PK测试",
		szCallback = "GM:TestClientPk()",
	},

	[tbDataIndex.UnlockFuben] ={
		Text = "关卡",
		tbChild = {
			{
				Text = "开关卡",
				szCallback = "GM:UnlockFuben()",
			},
			{
				Text = "直接完成关卡",
				szCmd = [[local tbFuben = PersonalFuben:GetCurFubenInstance(); tbFuben:GameWin();]];
			},
		},
	},

	[tbDataIndex.CleanBag] = {
		Text = "清空背包",
		szCallback = "GM:CleanBag()",
	},
	[tbDataIndex.Refresh] = {
		Text = "Test小功能\n [C1FFC1]（*^灬^*）[-]",
		tbChild = {
			{
				Text = "刷新HotFix",
				szCallback = "GM:CheckFixCmd()",
			},
			{
				Text = "断线重连",
				szCmd = [[CloseServerConnect();]];
			},
			{
				Text = "修改强制下线时间1分钟",
				szCmd = [[Operation.nNoOpDelayOffLineTime  = 1 * 60;]];
			},
			{
				Text = "角色等级增加1级",
				szCallback = "GM:LevelAdd()",
			},
			-- {
			-- 	Text = "刷新主播配置文件",
			-- 	szCallback = "GM:ChatHostInfo()",
			-- },
			{
				Text = "时间轴相关",
				tbChild = {
					{
						Text = "查看开服天数",
						szCallback = "GM:GetServerOpenDay()",
					},
					{
						Text = "查看开服时间",
						szCallback = "GM:ServerCreateTime()",
					},
					{
						Text = "输出所有时间轴的开启时间",
						szCallback = "GM:OutPutAllTimeFrameInfo()",
					},
					{
						Text = "查询时间轴是否开启",
						szCallback = "GM:QueryTimeFrameIsOpen()",
					},
					{
						Text = "查询时间轴开启时间",
						szCallback = "GM:QueryTimeFrameOpenTime()",
					},
					{
						Text = "查询当前时间所要达到时间轴的开服时间(仅限新创建数据库)",
						szCallback = "GM:ShowOpenLevelTime()",
					},
				}
			},
			{
				Text = "强制存盘",
				szCallback = "GM:ForceSaveData()",
			},
			{
				Text = "查看在线人数",
				szCallback = "GM:OnlinePlayerCount()",
			},
			{
				Text = "查看当前地图人数",
				szCallback = "GM:GetMapPlayer()",
			},
			{
				Text = "查看当前地图内所有玩家的战力",
				szCallback = "GM:GetMapPlayerPower()",
			},
			{
				Text = "获得活跃度",
				szCallback = "GM:EverydayTarget()",
			},
			{
				Text = "清除转门派CD",
				szCallback = "GM:RemoveUesrValue()",
			},
			{
				Text = "在线所有玩家切换战斗状态",
				szCallback = "GM:AllFightMode()",
			},
			{
				Text = "所有人来我身边",
				szCallback = "GM:Cometome()",
			},
			{
				Text = "全体踢下线",
				szCallback = "GM:KickoutPlayer()",
			},
			{
				Text = "召唤1号位同伴",
				szCallback = "GM:CreatePartnerByPos()",
			},
			{
				Text = "隐藏名字",
				szCallback = "GM:HideName()",
			},
			{
				Text = "刷新排行榜",
				szCallback = "GM:UpdateAllRank()",
			},
			{
				Text = "礼包码",
				szCallback = "GM:ShowCodeGift()",
			},
			{
				Text = "头衔所需令牌",
				tbChild = {
					{
						Text = "升级[ADFF2F]凌云[-]所需令牌",
						szCallback = "GM:HonorLingYun()",
					},
					{
						Text = "升级[ADFF2F]御空[-]所需令牌",
						szCallback = "GM:HonorYuKong()",
					},
					{
						Text = "升级[ADFF2F]潜龙[-]所需令牌",
						szCallback = "GM:HonorQianLong()",
					},
					{
						Text = "升级[ADFF2F]傲世[-]所需令牌",
						szCallback = "GM:HonorAoShi()",
					},
					{
						Text = "升级[ADFF2F]倚天[-]所需令牌",
						szCallback = "GM:HonorYiTian()",
					},
					{
						Text = "升级[ADFF2F]至尊[-]所需令牌",
						szCallback = "GM:HonorZhiZun()",
					},
					{
						Text = "升级[ADFF2F]武圣[-]所需令牌",
						szCallback = "GM:HonorWuShen()",
					},
					{
						Text = "升级[ADFF2F]无双[-]所需令牌",
						szCallback = "GM:HonorWuShuang()",
					},
					{
						Text = "升级[ADFF2F]传说[-]所需令牌",
						szCallback = "GM:HonorChuangShuo()",
					},
					-- {
					-- 	Text = "升级[ADFF2F]神话[-]所需令牌",
					-- 	szCallback = "GM:HonorShengHua()",
					-- },
				},
			},
			{
				Text = "测试挂机/经验",
				tbChild = {
					{
							Text = "开启怪物计数",
							szCallback = "GM:StartMonsterCount()",
					},
					{
							Text = "显示怪物计数",
							szCallback = "GM:ShowMonsterCount()",
					},
					{
							Text = "清空经验",
							szCallback = "GM:ClearExp()",
					},
					{
						Text = "定时自动战斗",
						szCallback = "GM:TryAutoFight()",
					},
				},
			},
			{
				Text = "Debug信息开关",
				szCmd = "Ui:ShowDebugInfo(not Ui.FTDebug.bShowDebugInfo); me.Msg((Ui.FTDebug.bShowDebugInfo and 'Debug信息开启' or 'Debug信息关闭') .. '成功');";
			},
			{
				Text = "移动设备关闭Debug显示",
				szCmd = [[Ui.FTDebug.bShowDebugUI = false; Ui.FTDebug.bDebug = false;me.Msg("Debug显示已关闭")]];
			},
			-- {
			-- 	Text = "主播",
			-- 	tbChild = {
			-- 		{
			-- 			Text = "获取主播权限",
			-- 			szCallback = "GM:GetHostAuth()";
			-- 		},
			-- 		{
			-- 			Text = "撤销主播权限",
			-- 			szCallback = "GM:CancelHostAuth()";
			-- 		},
			-- 	},
			-- },
			{
				Text = "手Q数据上报\n（需用SDK登陆）",
				szCallback = "GM:ReportQQData()";
			},
			{
				Text = "查看游戏版本号",
				szCmd = [[me.Msg("游戏版本号："..GAME_VERSION);Log(GAME_VERSION);]];
			},
			{
				Text = "查看当前服务器ID",
				szCmd = [[me.Msg("区服ID："..SERVER_ID);Log(SERVER_ID);]];
			},
			{
				Text = "查看NPC强度",
				szCmd = [[local tbNpc = KNpc.GetAroundNpcList(me.GetNpc(), 1000); for _, pNpc in pairs(tbNpc) do Log(string.format("%s TID:%s Level:%s Life:%s,%s", pNpc.szName, pNpc.nTemplateId, pNpc.nLevel, pNpc.nCurLife, pNpc.nMaxLife)); me.Msg(string.format("%s TID:%s Level:%s Life:%s,%s", pNpc.szName, pNpc.nTemplateId, pNpc.nLevel, pNpc.nCurLife, pNpc.nMaxLife)); end]];
			},
			{
				Text = "解除动态禁言",
				szCallback = "GM:ChatMgrSetFilterText()",
			},
			{
				Text = "执行test脚本检查坐标点\n (开发侧用)",
				szCmd = [[DoScript("test.lua");]];
			},
			
		}
	},

	[tbDataIndex.House] = {
		Text = "家园",
		tbChild = {
			{
				Text = "获得家园",
				szCallback = "GM:GetHouse()",
			},
			{
				Text = "升级家园",
				szCallback = "GM:LevelupHouse()",
			},
			{
				Text = "获得所有家具材料",
				szCallback = "GM:GetAllHouseMaterial()",
			},
			{
				Text = "获得所有家具",
				szCallback = "GM:GetAllHouseFurniture()",
			},
			{
					Text = "桃花树清空数据",
					szCallback = "GM:HousePeachClearData()",
			},
		},
	},
	[tbDataIndex.KinTool] = 
	{
		Text = "家族工具&活动\n惊喜多多，还不快来",
		tbChild = {
			{
				Text = "开启家族运镖",
				szCallback = "GM:StartKinEscort()",
			},
			{
				Text = "开启家族烤火",
				szCallback = "GM:StartKinGatherActivity()",
			},
			{
				Text = "增加家族建设资金",
				szCallback = "GM:AddKinFound()",
			},
			{
				Text = "开启家族宝贝",
				szCallback = "GM:OpenMascot()",
			},
			{
				Text = "关闭家族宝贝",
				szCallback = "GM:CloseMascot()",
			},
			{
				Text = "清除传功CD",
				szCallback = "GM:ChuangGongUserValue()",
			},
			{
				Text = "增加被传功次数",
				szCallback = "GM:AddDegreeChuangGong()",
			},
			{
				Text = "增加可传功次数",
				szCallback = "GM:AddDegreeChuangGongSend()",
			},
			{
				Text = "师徒目标完成",
				szCallback = "GM:TargetAddCount()",
			},
			{
				Text = "获取家族ID",
				szCallback = "GM:KinId()",
			},
			{
				Text = "查询家族活跃状态",
				szCallback = "GM:KinLastJudge()",
			},
			{
				Text = "在线的人加我家族\n(需族长且自己同意申请)",
				szCallback = "GM:KinGetAllPlayer()",
			},
			{
				Text = "在线的人建家族\n(需执行两次)",
				szCallback = "GM:KinIsNameValid()",
			},
			{
				Text = "家族在线进组\n(需先创建队伍)",
				szCallback = "GM:Kinteam()",
			},
			{
				Text = "解散家族\n[FF0000]慎点 {{{(>_<)}}}[-]",
				szCallback = "GM:DismissMyKin()",
			},
			
		},
	},

	[tbDataIndex.ChangeFaction] =
	{
		Text = "去PK场或转门派",
		tbChild = {
			[1] = {
				Text = "去PK场",
				szCallback = "me.SwitchMap(1006, 0, 0)",
			},
		}
	},
}

function tbUi:OnOpen()
	self:UpdateData()
	self:ResetUi()
	self:UpdateMainUi()
	self:ClearObj(1,2,3)
end

function tbUi:UpdateData()
	if not self.tbGMData[tbDataIndex.ChangeFaction].bLoad then
   	    local tbAllSex = {{Player.SEX_MALE, "男"}, {Player.SEX_FEMALE, "女"}};
	    for nFaction, tbFInfo in pairs(Faction.tbFactionInfo) do
	        for _, tbSex in ipairs(tbAllSex) do
	            local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, tbSex[1]);
	            if tbPlayerInfo then
	            	local tbCallback = {};
	            	tbCallback.Text = tbFInfo.szName.."-"..tbSex[2];
	            	local szCallback = 
	            	[[
	            		local nOrG = ChangeFaction.tbDef.nMapTID ;
	            		ChangeFaction.tbDef.nMapTID = me.nMapTemplateId; 
	            		ChangeFaction:PlayerChangeFaction(me, %d, %d);
	            		ChangeFaction.tbDef.nMapTID = nOrG;
	            	]]
	            	tbCallback.szCallback = string.format(szCallback, nFaction, tbSex[1]),
	            	table.insert(self.tbGMData[tbDataIndex.ChangeFaction].tbChild, tbCallback);
	            end
	        end
	    end
		self.tbGMData[tbDataIndex.ChangeFaction].bLoad = true;
	end

	self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild or {}

	local tbAllPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nAllPartnerIndex]
	if tbAllPartner then
		tbAllPartner.tbChild = {}
	end

	local tbAllSSSPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nSSSPartnerSingleIndex]
	if tbAllSSSPartner then
		tbAllSSSPartner.tbChild = {}
	end

	local tbAllSSPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nSSPartnerSingleIndex]
	if tbAllSSPartner then
		tbAllSSPartner.tbChild = {}
	end

	local tbAllSPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nSPartnerSingleIndex]
	if tbAllSPartner then
		tbAllSPartner.tbChild = {}
	end

	local tbAllAPartner = self.tbGMData[tbDataIndex.nPartnerDataIndex].tbChild[nAPartnerSingleIndex]
	if tbAllAPartner then
		tbAllAPartner.tbChild = {}
	end

	local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo();
	for nId, tbInfo in pairs(tbAllPartnerBaseInfo or {}) do
		if tbAllSSSPartner.tbChild then
			if tbInfo.nQualityLevel == 1 then
				table.insert(tbAllSSSPartner.tbChild, { Text = string.format("我要 %s ", tbInfo.szName), szCallback = string.format("GM:AddOnePartner(%d,true)",nId) })
			end
		end

		if tbAllSSPartner.tbChild then
			if tbInfo.nQualityLevel == 2 then
				table.insert(tbAllSSPartner.tbChild, { Text = string.format("我要 %s ", tbInfo.szName), szCallback = string.format("GM:AddOnePartner(%d,true)",nId) })
			end
		end

		if tbAllSPartner.tbChild then
			if tbInfo.nQualityLevel == 3 then
				table.insert(tbAllSPartner.tbChild, { Text = string.format("我要 %s ", tbInfo.szName), szCallback = string.format("GM:AddOnePartner(%d,true)",nId) })
			end
		end

		if tbAllAPartner.tbChild then
			if tbInfo.nQualityLevel == 4 then
				table.insert(tbAllAPartner.tbChild, { Text = string.format("我要 %s ", tbInfo.szName), szCallback = string.format("GM:AddOnePartner(%d,true)",nId) })
			end
		end

		if tbAllPartner.tbChild then
			table.insert(tbAllPartner.tbChild, { Text = string.format("我要 %s ", tbInfo.szName), szCallback = string.format("GM:AddOnePartner(%d,true)",nId) })
		end
	end

	self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild = {}
	for i = 0,nMaxLevelUp do
		table.insert(self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild,{Text = string.format("%s0+ 等级段", i),tbChild = {}})
		for j = 0, 9 do
			local nLevel = i * 10 + j;
			if nLevel > 0 then
				table.insert(self.tbGMData[tbDataIndex.nLevelUpDataIndex].tbChild[i + 1].tbChild,{Text = string.format("升级到 %s ", i * 10 + j),szCallback = string.format("GM:AddPlayerLevel(math.max(%d * 10 + %d, 1))",i,j)})
			end
		end
	end

	self.tbGMData[tbDataIndex.nHonorDataIndex].tbChild = {}
	for nHonorLevel=1,#Player.tbHonorLevelSetting do
		local szHonorName = Player.tbHonorLevel:GetHonorName(nHonorLevel)
		table.insert(self.tbGMData[tbDataIndex.nHonorDataIndex].tbChild,{ Text = "升级" ..szHonorName, szCallback = string.format("GM:SetHonorLevel(%d)",nHonorLevel)})
	end

	local tbEquipDesc =
	{
		[1] = "获得%d级装备（低）",
		[2] = "获得%d级装备（中）",
		[3] = "获得%d级装备（高）",
	}

	local tbInsertDesc =
	{
		[1] = "镶嵌%d级（低）",
		[2] = "镶嵌%d级（中）",
		[3] = "镶嵌%d级（高）",
	}

	self.tbGMData[tbDataIndex.Role].tbChild = {}
	local tbAllRole = self.tbGMData[tbDataIndex.Role].tbChild
	for nIndex,tbData in ipairs(tbRoleData) do
		local nLevel = tbData.nLevel or 0
		local tbStrong = tbData.tbStrong or {}
		local tbInsert = tbData.tbInsert or {}
		if nLevel ~= 0 then
			tbAllRole[nIndex] = {Text = string.format("%d级角色",nLevel),tbChild = {}}
			local tbRole = tbAllRole[nIndex].tbChild
			local nBaseIndex = #tbStrong+1
			tbRole[1] = {Text = string.format("升级到%d级",nLevel),szCallback = string.format("GM:AddPlayerLevel(%d)",nLevel)}
			tbRole[nBaseIndex+1] = {Text = "技能学满",szCallback = "GM:SkillUpFull()"}
			for i=1,#tbStrong do
				local nStrong = tbStrong[i]
				tbRole[#tbRole + 1] = {Text = string.format("强化+%d",nStrong),szCallback = string.format("GM:EnhanceEquip(%d)",nStrong)}
			end
			for nType=1,#tbEquipDesc do
				tbRole[#tbRole + 1] = {Text = string.format(tbEquipDesc[nType],nLevel),szCallback = string.format("GM:AddEquips(%d,%d)",nLevel,nType)}
			end
			for nType=1,#tbInsert do
				local nInsert = tbInsert[nType]
				tbRole[#tbRole + 1] = {Text = string.format(tbInsertDesc[nType],nInsert),szCallback = string.format("GM:InsetEquip(%d,%d)",nInsert,nType)}
			end
		end
	end

	local tbRandomDesc =
	{
		[1] = "1层秘境",
		[2] = "2层秘境",
		[3] = "3层秘境",
		[4] = "4层秘境",
		[5] = "5层秘境",
		[6] = "6层秘境",
	}

	-- 非秘境前面扩充
	local tbRandomBefore =
	{
		[1] = {Text = "随机秘境(需二人组队)",szCallback = "GM:Go2RandomFuben()"},
		[2] = {Text = "凌绝峰卡片收集开启",szCallback = "GM:BeginNewSession()"},
		[3] = {Text = "全套卡片",szCallback = "GM:BeginNewSessionItem()"},
	}

	-- 非秘境后面扩充
	local tbRandomAfter =
	{
		[1] = {Text = "直接胜利",szCallback = "GM:GameWinFubenInstance()"},
		[2] = {Text = "退出凌绝峰",szCallback = "GM:GotoEntryPoint()"},
		[3] = {Text = "重置凌绝峰次数",szCallback = "GM:RemoveUesrValueRandomFuben()"},
		[4] = {
					Text = "地宫小副本",
					tbChild = {
						[1] = {
							Text = "直接地宫",
							szCallback = "GM:DirectGotoDungeon()",
						},
						[2] = {
							Text = "地宫二层(水晶)\n需在地宫一层使用",
							szCallback = "GM:DirectGotoDungeonCrystal()",
						},
						[3] = {
							Text = "地宫二层(BOSS)\n需在地宫一层使用",
							szCallback = "GM:DirectGotoDungeonBoss()",
						},
					},
				},
	}

	if not self.tbRandomSetting then
		local tbFile = LoadTabFile("Setting/Fuben/RandomFuben/RoomSetting.tab", "sd", nil, {"Info","MapId"});
		for _,tbRow in pairs(tbFile) do
			local tbRoom = Lib:SplitStr(tbRow.Info, "_")
			local nLayer = tonumber(tbRoom[1]) or 0
			local nRoom = tonumber(tbRoom[2]) or 0
			self.tbRandomSetting = self.tbRandomSetting or {}
			self.tbRandomSetting[nLayer] = self.tbRandomSetting[nLayer] or {}
			self.tbRandomSetting[nLayer][nRoom] = tbRow.MapId
		end
	end

	self.tbGMData[tbDataIndex.RandomFuben].tbChild = {}
	local tbRandomFuben = self.tbGMData[tbDataIndex.RandomFuben].tbChild

	local nBeforeLen = #tbRandomFuben
	for i,tbChild in ipairs(tbRandomBefore) do
		tbRandomFuben[nBeforeLen + i] = tbChild
	end

	local nMiddleLen = #tbRandomFuben
	for nLayer = 1,#tbRandomDesc do
		local szLayerDesc = tbRandomDesc[nLayer]
		if not szLayerDesc then
			break
		end
		if self.tbRandomSetting[nLayer] then
			for nRoom=1,#self.tbRandomSetting[nLayer] do
				local nMapId = self.tbRandomSetting[nLayer][nRoom]
				if nMapId then
					tbRandomFuben[nLayer + nMiddleLen] = tbRandomFuben[nLayer + nMiddleLen] or {Text = szLayerDesc,tbChild={}}
					tbRandomFuben[nLayer + nMiddleLen].tbChild[nRoom] =
					{
						Text = string.format("%d号房间",nRoom),
						szCallback = string.format("GM:Go2RandomFuben(%d)",nMapId),
					}
				end
			end
		end
	end

	local nAfterLen = #tbRandomFuben
	for i,tbChild in ipairs(tbRandomAfter) do
		tbRandomFuben[nAfterLen + i] = tbChild
	end

end

tbUi.tbHideUI =
{
	ScrollView1 = true,
	ScrollView2 = true,
	ScrollView3 = true,
	Title1 = true,
	Title2 = true,
	Title3 = true,
}

function tbUi:ResetUi()
	for szUiName,_ in pairs(self.tbHideUI) do
		self.pPanel:SetActive(szUiName,false)
	end
end

function tbUi:ShowUi(...)
	self:ResetUi()
	local tbIdx = {...}
	for _,nIdx in pairs(tbIdx) do
		self.pPanel:SetActive("ScrollView" ..nIdx,true)
		self.pPanel:SetActive("Title" ..nIdx,true)
	end
end

function tbUi:CallServer(callBack)
	if type(callBack) == "table" then
		GMCommand(callBack[1], 1);
	else
		GMCommand(callBack);
	end
	
end

function tbUi:UpdateMainUi()
	self:ShowUi(1)

	local fnOnClick = function(itemObj)
		if self.tbGMData[itemObj.nId].tbChild then
			self:UpdateChildUi(itemObj.nId)
		else
			local szCallBack = self.tbGMData[itemObj.nId].szCallback
			if self.tbGMData[itemObj.nId].szCmd then
				local fn = loadstring(self.tbGMData[itemObj.nId].szCmd);
				Lib:CallBack({fn});
			else
				self:CallServer(szCallBack)
			end
			 me.CenterMsg(string.format("【%s】 执行成功！",self.tbGMData[itemObj.nId].Text))
		end
		self:ClearObj(1,2,3)
		itemObj.pPanel:SetActive("Choose",true)
	end

	local fnSetItem = function(itemObj,nIdx)
		self.tbGMData[nIdx].nId = nIdx  		-- 搜索用到对应的ID
		itemObj.pPanel:Label_SetText("Name",  self.tbGMData[nIdx].Text or "");
		itemObj.nId = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:SetActive("Mark",self.tbGMData[nIdx].tbChild)
	end

	self.ScrollView1:Update(#self.tbGMData,fnSetItem);
end

function tbUi:UpdateChildUi(nPartnerId)
	self:ShowUi(1,2)
	local tbChildData =  self.tbGMData[nPartnerId].tbChild
	local fnOnClick = function(itemObj)
		local nId = itemObj.nId
		if tbChildData[nId].tbChild then
			self:UpdateChild2Ui(nPartnerId,nId)
		else
			local szCallBack = tbChildData[nId].szCallback
			if tbChildData[itemObj.nId].szCmd then
				local fn = loadstring(tbChildData[itemObj.nId].szCmd);
				Lib:CallBack({fn});
			else
				self:CallServer(szCallBack)
			end
			me.CenterMsg(string.format("【%s】 执行成功！",tbChildData[nId].Text))
		end
		self:ClearObj(2,3)
		itemObj.pPanel:SetActive("Choose",true)
	end

	local fnSetItem = function(itemObj,nIdx)
		itemObj.pPanel:Label_SetText("Name",  tbChildData[nIdx].Text or "");
		itemObj.nId = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:SetActive("Mark",tbChildData[nIdx].tbChild)
	end

	self.ScrollView2:Update(#tbChildData,fnSetItem);
end

function tbUi:UpdateChild2Ui(nGrandParentId,nPartnerId)
	self:ShowUi(1,2,3)

	local tbChildData =  self.tbGMData[nGrandParentId].tbChild[nPartnerId].tbChild

	local fnOnClick = function(itemObj)
		local nId = itemObj.nId
		if tbChildData[nId].tbChild then
			self:UpdateChild3Ui()
		else
			local szCallBack = tbChildData[nId].szCallback
			if tbChildData[itemObj.nId].szCmd then
				local fn = loadstring(tbChildData[itemObj.nId].szCmd);
				Lib:CallBack({fn});
			else
				self:CallServer(szCallBack)
			end
			me.CenterMsg(string.format("【%s】 执行成功！",tbChildData[nId].Text))
		end
		self:ClearObj(3)
		itemObj.pPanel:SetActive("Choose",true)
	end

	local fnSetItem = function(itemObj,nIdx)
		itemObj.pPanel:Label_SetText("Name",  tbChildData[nIdx].Text or "");
		itemObj.nId = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:SetActive("Mark",tbChildData[nIdx].tbChild)
	end

	self.ScrollView3:Update(#tbChildData,fnSetItem);
end

function tbUi:UpdateChild3Ui()
	-- 暂时没需求
end

function tbUi:ClearObj(...)
	local tbIdx = {...}
	for _,nIdx in pairs(tbIdx) do
		for i=0,300 do
			local itemObj = self["ScrollView" ..nIdx].Grid["Item" ..i]
			if not itemObj then
				break
			end
			itemObj.pPanel:SetActive("Choose",false)
		end
	end
end

function tbUi:SearchSaveList(szSearch)
	local tbSaveCommond
	if szSearch == "" then
		tbSaveCommond = self.tbGMData
	else
		tbSaveCommond = self:GetSaveCommondByStr(szSearch)
	end
	if not tbSaveCommond then
		return
	end
	local fnOnClick = function(itemObj)
		local nId = tbSaveCommond[itemObj.nId].nId 				-- 原数据的ID索引
		if tbSaveCommond[itemObj.nId].tbChild then
			self:UpdateChildUi(nId)
		else
			local szCallBack = tbSaveCommond[itemObj.nId].szCallback
			if tbSaveCommond[itemObj.nId].szCmd then
				local fn = loadstring(tbSaveCommond[itemObj.nId].szCmd);
				Lib:CallBack({fn});
			else
				self:CallServer(szCallBack)
			end
			me.CenterMsg(string.format("【%s】 执行成功！",tbSaveCommond[itemObj.nId].Text))
		end
		self:ClearObj(1,2,3)
		itemObj.pPanel:SetActive("Choose",true)
	end

	local fnSetItem = function(itemObj,nIdx)
		itemObj.pPanel:Label_SetText("Name",  tbSaveCommond[nIdx].Text or "");
		itemObj.nId = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:SetActive("Mark",tbSaveCommond[nIdx].tbChild)
	end

	self.ScrollView1:Update(#tbSaveCommond,fnSetItem);
end

function tbUi:GetSaveCommondByStr(szSearch)
	local tbCommond = {}
	for index,info in ipairs(self.tbGMData) do
		info.nId = nil
		local szCommond = info.Text
		local isShow = string.find(szCommond, szSearch)
		if isShow then
			info.nId = index 				-- 原数据的ID索引
			table.insert(tbCommond,info)
		end
	end
	return tbCommond
end

tbUi.tbUiInputOnChange = {};
tbUi.tbUiInputOnChange.Input = function (self)
		local szSearch = self.Input:GetText()
		self:SearchSaveList(szSearch)
	end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	 end,
}