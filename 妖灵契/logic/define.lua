--游戏定义的常量
module(...)
GameName = "妖灵契"

Pay = {
	CoinName = "水晶",
	Proportion = 10,
	isCustomPrice = true,
	CustomText = "",
}

DemiFrame = {
	TestGameID = 8,
	GameID = 2,
	-- ChannelID = "kaopu",
	-- SubChannelID = "kaopu",
	Spliter = "DEMISPLITER",
	TestUrl = "https://devintegrationsdk.cilugame.com/v1/sdkc/area/info.json",
	-- NormalUrl = "https://devintegrationsdk.cilugame.com/v1/sdkc/area/info.json",
	NormalUrl = "https://isdk.demigame.com/v1/sdkc/area/info.json",
}

Url = {
	Release = "http://csn1.cilugame.com", --默认的release
	IOS_Release = nil,--没有则用默认的release
	Andriod_Release = nil, --没有则用默认的release
-- "http://shenhen1.cilugame.com"
	Dev = "http://devn1.cilugame.com",
	Bussiness = "http://businessn1.demigame.com",
	OffcialWeb = "http://ylq.kpzs.com/",
}

Layer ={
	MapTerrain = 8,
	MapWalker = 9,
	War = 10,
	ModelTexture = 11,
	Hide= 12,
	House = 13,
	BottomUI = 14,
	Live2d = 15,
	Magic = 16,
	Effect = 18,
	CreateRole = 19,
}

Shadow = {
	createrole = {
		light={-0.16072,-0.6357552,0.7549731},
		color = {1, 1, 1, 0.8},
	},
	war = {
		light={-0.3213938, -0.7660444, 0.5566705},
		color = {1, 1, 1, 0.8},
	},
}

Weapon = {
	Bow = 1, --弓
	Sword = 2, --剑
}
--频道
Channel = {
	World = 1,
	Team = 2,
	Org = 3,
	Current = 4,
	Message = 6,
	Common = 7,
	TeamPvp = 8,
	Sys = 100,
	Bulletin = 101, --公告
	Help = 102,
	Rumour = 103,

	Ch2Text = {
		[1] = "世界",
		[2] = "队伍",
		[3] = "公会",
		[4] = "当前",
		[6] = "消息",
		[7] = "常用",
		[8] = "队伍",
		[100] = "系统",
		[101] = "公告",
		[102] = "帮助",
		[103] = "传闻",
	}
}

Sex = {
	Male = 1,
	Female = 2
}

School = {
	Shushan = 1,
	Xingxiuhai = 3,
}

Attr = {
	Event = {
		Change = 1,
		AddPoint = 2,
		UpdateDay = 3,
		UpdateSkin = 4,
	},
	String = 
	{
		grade = "等级",
		name = "名字",
		goldcoin = "水晶",
		coin = "金币",
		exp = "经验",
		maxhp = "气血",
		hp = "气血",		
		attack = "攻击",
		defense = "防御",
		speed = "速度",
		critical_ratio = "暴击",
		res_critical_ratio = "抗暴",
		critical_damage = "暴击伤害",
		cure_critical_ratio = "治疗暴击",
		abnormal_attr_ratio = "异常命中",
		res_abnormal_ratio = "异常抵抗",
		attack_ratio = "攻击加成",
		defense_ratio = "防御加成",
		maxhp_ratio = "气血加成",
		power = "战力",
		school = "职业",
	},
	AttrKey = 
	{
		[1] = "hp",
		[2] = "maxhp",
		[3] = "attack",
		[4] = "defense",
		[5] = "speed",
		[6] = "critical_ratio",
		[7] = "res_critical_ratio",
		[8] = "critical_damage",
		[9] = "cure_critical_ratio",
		[10] = "abnormal_attr_ratio",
		[11] = "res_abnormal_ratio",
		[12] = "power",
	},
}

Title = {
	Event = {
		OnGetTitleList = 1,
		OnUpdateTitleInfo = 2,
		OnReceiveUpdateUseTitle = 3,
		RemoveTitles = 4,
	},
	HandleType = {
		ShowTitle = 1,
		CancelTitle = 0,
	},
	ShowType = {
		HeadTitle = 1,
		ArenaGrade = 2,
		FootTitle = 3,
	}
}


Map = {
	Event = {
		ShowScene = 1,
		EnterScene = 2,
		HeroPatrol = 3,
		MapNpcList = 4,
		MapLoadDone = 5,
		HeroLoadDone = 6,
	},
	AdaptationView = {
		Width = 1334	,
		Height = 750,
		PointSpac = 2,
	},
	TouchType = {
		Walker = {
			Name = "Walker",
			ID = "2017",
		},
		Terrian = {
			Name = "Terrian",
			ID = "2012",
		}
	},
	NpcMarkMode = 
	{
		Normal = 0,
		EquipFb = 1,
		TaskChapterFb = 2,
	}	
}

Skill = {
	Type ={
		SchoolSkill="active",
		PassiveSkill = "passive",
	},
	Event ={
		LoginSkill = 1,
		SchoolRefresh = 2,
		CultivateRefresh = 3,
		PassiveRefresh = 4,
	},
	CultivateType ={
		Hp = 1,
		Attack = 2,
		Defense = 3,
		Critical = 4,
		ResCritical= 5,
		CriticalDamage = 6,
		CureCritical = 7,
		AbnormalAttr = 8,
		ResAbnormal = 9,
	},

	Element = {
		["土"] = 1,
		["水"] = 2,
		["火"] = 3,
		["风"] = 4,
	},
}

Item = {
	Event = {
		RefreshSpecificItem = 1,
		RefreshBagItem = 2,
		RefreshEquip = 3,
		RefreshStrength = 4,
		RefreshFuwen = 5,	
		RefreshItemPrice = 6,
		RefreshPartnerEquip = 7,
		ComposePartnerEquip = 8,
		RefreshItemGetRedDot = 9,
		RefreshPartnerSkin = 10,
		DelItem = 11,
		AddItem = 12,
		RefreshFuwenName = 13,
		ForgeCompositeSuccess = 14,
		ForgeExchangeSuccess = 15,
		ForgerResolveSuccess = 16,
		RefreshPartnerSoul = 17,
		ForgeGemComposite = 18,
	},
	CellType = {
		BagCell = 1,
		WHCell = 2,
		ModelEquip = 3,
	},
	Quality = {
		White = 0,
		Green = 1,
		Blue = 2,
		Purple = 3,
		Orange = 4
	},
	SortType =
	{
		Time = 1,
		Level = 2,
		Type = 3,
		Amount = 4,
		Itemlevel = 5,
		Pos = 6,
		Sid = 7,
		Equip = 8,
		Partner = 9,
		Chip = 10,

	},
	SortTypeString =
	{
		[1] = "时间",	
		[2] = "等级",
		[3] = "类型",--道具的子类型
		[4] = "数量",	
		[5] = "品质",
		[6] = "类型",--装备的部位
	},
	--所有道具的类型
	ItemType =
	{
		Genernal = 1,
		Material = 2,
		Gem = 3,
		Equip = 4,
		PartnerEquip = 5,
		EquipStone = 6,
		PartnerChip = 7,
		PartnerSkin = 9,
		Travel = 10, --游历道具
		PartnerStone = 11,
		PartnerSoul = 12,
	},
	--所有道具的类型
	ItemBagShowType =
	{
		Genernal = 1,
		Material = 2,
		Equip = 3,
		Partner = 4,
		Chip = 5,
	},
	--所有道具的字符串
	ItemTypeString =
	{
		[1] = "普通",	
		[2] = "材料",
		[3] = "宝石",	
		[4] = "装备",		
		[5] = "符文",	
		[6] = "装备",  --装备灵石
		[7] = "伙伴碎片",
		[8] = "觉醒材料",
		[10] = "游历道具",
		[11] = "伙伴符石",
		[12] = "伙伴御灵",
	},

	ItemSubTypeRange = 
	{
		[1] = {1001,10000},
	    [2] = {10001,11099},
	    [3] = {12000,12099},
	    [4] = {18000,18999},
	    [5] = {19000,19999},
	    [6] = {20000,29999},
	    [7] = {2000000,2999900},
	    [8] = {3000000,5000000},
	},
	
	ItemSubType = 
	{
		Virtual = 1,
	   	Other = 2,
	    Housegift = 3,
	    Gem = 4,
	    Fuwen = 5,
	    Partnerequip = 6,
	    Equip = 7, 
	    EquipStone = 8,
	},
	ID = {
		ShiJianJiaoLang = 12020,
	},
	SkinType = {
		Default = 1,	--默认皮肤
		Classic = 2,	--经典皮肤
		Awake = 3,		--觉醒皮肤
		Epic = 4,		--史诗皮肤
	}
}

Equip = {
	Pos = {
		Weapon = 1,
		Necklace = 2,
		Clothes = 3,
		Ring = 4,
		Belt = 5,
		Shoes = 6,
	},
	PosName = {
		"武器",
		"项链",
		"衣服",
		"戒指",
		"腰带",
		"鞋子",
	},
}

Chat = {
	MsgType = {
		Self = 1,
		Others = 2,
		NoSender = 3,
	}, 
	Event = {
		AddMsg = 1,
		PlayAudio = 2,
		EndPlayAudio = 3,
		AddATMsg = 4,
		ChatBoxExpan = 5,
	},
}

Talk = {
	Event = {
		AddNotify = 1,
		DelNotify = 2,
		AddMsg = 3,
	},
}

Friend = {
	Event = {
		Add = 1,
		Del = 2,
		Update = 3,
		UpdateTeam = 4,
		UpdateApply = 5,
		UpdaeSearch = 6,
		AddBlack = 7,
		DelBlack = 8,
		DelRecent = 9,
		AddRecent = 10,
		UpdateRecommand = 11,
	},
}

Dialogue = {
	Event = {
		InitOption = 1,
		Dialogue = 2,
		HideAllViews = 3,
		Animation = 4,
	},
	Mode = {
		MainMenu = 1,
		Dialogue = 2, 
		TaskMenu = 3,
		ScreenMask = 4,
		Movie = 5,
	},
}

Teach = {
	Event = {
		OnUpdateProgressInfo = 1,
	},
	Status = {
		Doing = 1,
		Done = 2,
		GotReward = 3,
	}
}

Task = {
	Event = {
		RefreshAllTaskBox = 1,
		RefreshSpecificTaskBox = 2,
		ReceiveNewTeachTask = 3,
		AddTaskBullet = 4,
		RefreshPartnerTaskBox = 5,
	},
	TaskStatus = {
		Doing = 1,
		Accept = 2,
		Defeated = 3,
		Done = 4,
		HasCommmit = 5,
		Del = 6,
	},
	TaskType = {
		TASK_FIND_NPC = 1,		--找人
		TASK_FIND_ITEM = 2,		--找物
		TASK_FIND_PLACE = 3, 	--寻地
		TASK_NPC_FIGHT = 4,		--战斗		
		TASK_CHANGSHAPE = 5,	--伪装
		TASK_PICK = 6,			--采集
		TASK_USE_ITEM = 7,		--用物	
		TASK_ACHIEVE = 8,		--数值达成
		TASK_TRACE = 9,			--跟踪
		TASK_ESCORT = 10,		--护送
		TASK_TEACH = 11,		--教学
		TASK_LEGENDPARTNER = 12,--寻物
		TASK_SLIP = 13,			--滑屏
		TASK_PATROL = 14,		--巡逻
		TASK_SOCIAL = 15,		--巡逻
	},
	AchieveTaskType =
 	{
		TASK_UPGRADE = 1,		--升级
		TASK_ADDFRIEND = 2,		--添加好友
		TASK_ADDPARTNER = 3,	--添加伙伴
		TASK_ADDPOWER = 4,		--添加战力
		TASK_CHOUKA = 5,		--抽卡
	},
	TaskCategory = {
		TEST	= {ID = 1, NAME = "TEST"},
		STORY	= {ID = 2, NAME = "STORY"},
		ACHIEVE	= {ID = 3, NAME = "ACHIEVE"},
		SHIMEN	= {ID = 4, NAME = "SHIMEN"},
		LILIAN	= {ID = 5, NAME = "LILIAN"},
		ACTIVITY= {ID = 6, NAME = "ACTIVITY"},
		TEACH	= {ID = 7, NAME = "TEACH"},
		PRACTICE= {ID = 8, NAME = "PRACTICE"},
		DAILY	= {ID = 9, NAME = "DAILY"},
		HOUSE	= {ID = 10, NAME = "HOUSE"},
		PLOT 	= {ID = 11, NAME = "PLOT"},
		PARTNER	= {ID = 12, NAME = "PARTNER"},
	},
	String = 
	{
		[1] = "测试",
		[2] = "主线",
		[3] = "支线",	--成就支线
		[4] = "委托",
		[5] = "历练",
		[6] = "活动",
		[7] = "教学",
		[8] = "考验",
		[9] = "日常",
		[10] = "宅邸",
		[11] = "支线",  --剧情支线
		[12] = "支线",  --伙伴支线
	},
}

Gm = {
	Event = {
		RefreshTime = 1,
		RefreshLastInfo = 2,
		RefreshGmHelpMsg = 3,
		ShowItemId = 4,
	},
}

OpenInterfaceType =  {
	Base = 0,
	Barrage = 1,
	WroldBoss = 2,
	WarResult = 3,
}

Team = {
	Event = {
		AddTeam = 1,
		MemberUpdate = 2,
		DelTeam = 3,
		AddApply = 4,
		DelApply = 5,
		ClearApply = 7,
		AddInvite = 8,
		DelInvite = 9,
		ClearInvite = 10,
		NotifyInvite = 11,
		NotifyApply = 12,
		AddTargetTeam = 13,
		NotifyAutoMatch = 14,
		NotifyCountAutoMatch = 15,
		PartnerUpdate = 16,
		RefreshLocalTarget = 17,
		RefreshTargetCount = 18,
		TeamInvitePlayerList = 19,
		TeamInviteMatchList = 20,
	},
	MemberStatus = {
		Normal = 1,
		Leave = 2,
		Offline = 3,
	},
	TaskID = {
		ChuanShuoHuoBan = 1051  --组队目标 传说伙伴
	}
}


Summon = {
	Event = {
		UpdateSummonInfo = 1,
		DelSummon = 2,
		SetFightId = 3,
		WashSummonAdd = 4,
		AddSummon = 5,
		CombineSummonShow = 6,
		BagItemUpdate = 7,
	}
}

Currency = {
	Type = {
		GoldCoin = 1,			--水晶
		Gold = 2,				--金币
		Silver = 0,				--弃用
		PiFuQuan = 9,			--皮肤卷
		ColorCoin = 12,			--彩晶
		RMB = 13,				--人民币
	}
}

--日程
Schedule = {
	ID = {
		DailyCultivate = 1001, 	--每日修行
		EndlessPVE = 1002,	--月见幻境
		EquipFb = 1003, 	--装备副本(埋骨之地)
		Pata = 1004,		--爬塔
		PEFb = 1005, 		--符文副本(异空流放)
		MingLei = 1006, 	--猫萌茶会
		AnLei = 1007,		--探索
		Treasure = 1009,	--挖宝
		YJfuben = 1012,		--梦魇狩猎
		FieldBoss = 1013,	--野外BOSS(人形讨伐)
		OrgFuben = 1011,	--公会副本
		Travel = 1014,		--游历
		EqualArena = 1015,	--公平比武
		SceneExam = 1019,	--学霸去哪了
		Question = 2001, 	--答题
		Worldboss = 2002,	--次元妖兽
		Arenagame = 2003,  	--比武场
		Terrawar  = 2004,   --据点战
		Chapter = 1016,		--战役（剧情副本）
		ShiMen = 1017,		--师门
		Convoy = 1018,		--护送
		OrgWar = 2005,      --公会战
		MonsterAtkCity = 1020, --怪物攻城
		TeamPvp = 1021, --协同比武
	},
	Tag = {
		--Top跟导表有关
		Top1 = 1,		--经验
		Top2 = 2,		--金币
		Top3 = 3,		--伙伴
		Top4 = 4,		--符文
		Top5 = 5,		--活跃
		Right1 = 11,		--必做
		Right2 = 12,		--预告
	},
	Limit = {
		Xianshi  = 1,		--限时活动
		Quantian = 2,		--全天活动
	},
	State = {
		Not  = 0,	--未开启
		Open = 1,	--日程开启
		End  = 2,	--日程结束
	},
	Event = {
		Refresh = 1,	--刷新某个日程数据
		RefreshUITip = 3, --刷新主角面
	},
}

Model = {
	Defalut_Shape = 140,
}

Net = {
	Event_Sockect = 1,
}

MainMenu = {
	AREA = {
		MinMap = 1,
		Active = 2,
		Buff = 3,
		HeroIcon = 4,
		Task = 5,
		Bag = 6,
		Function = 7,
		Notify= 8,
		Chat = 9,
		Other = 10,
	},
	HideConfig = {
		PathFind = {2,3,6,7,8,10},
		SystemUI = {2,5,6,7,8,10} 
	}
}

Mail = {
	Single_Event = {
		GetDetail = 1,
		Del = 2,
		RetrieveAttach = 3,
		Add = 4,
	},
	Batch_Event = {
		OpenMails = 11,
	}
}

Instruction = {
	Config = {
		AttrMainIns = 1000,
	},
	View = {
		MaxHeight = 630,
		MinHeight = 130,
		Pixel = 470,
		YLength = 210,
		MinPixel = 160,
	}	
}

Org = {
	Event = {
		OnGetOrgDic = 1,
		GetOrgAim = 2,
		ApplySuccess = 3,
		GetOrgMainInfo = 4,
		DelMember = 5,
		ChangeFlag = 6,
		OnChangePos = 7,
		OnRejectAll = 8,
		OnChangeLimit = 9,
		OnDealApply = 10,
		OnGetMemberList = 11,
		OnUpdateMemberInfo = 12,
		OnGetLog = 13,
		OnOrgFBBossList = 14,
		UpdateOrgInfo = 15,
		OnlineCount = 16,
		OnOrgFBBossHP = 17,
		OnOrgFubenRedDot = 18,
		OnSendMailResult = 19,
		OnUpdateBlood = 20,
		EnterOrgWarScene = 21,
		LeaveOrgWarScene = 22,
		UpdateOrgWarTime = 23,
		UpdateOrderStatus = 24,
		UpdateOrgWarRank = 25,
		UpdateReviveTime = 26,
		UpdateOrgName = 27,
	},
	HandleType = {
		OpenMemberView = 1,
		OpenTeamInviteView = 2,
		OpenSocail = 3,
	},
	Build = {
		Status = {
			Not = 0,  		--无
			Ordinary = 1, 	--普通建设
			Senior = 2,		--高级建设
			Super = 3,		--超级建设
			Finish = 4,		--完成建设
			End = 5,		--领取奖励
		},
	},
	Pos = {
		HuiZhang = 1, --会长
	},
	WarStatus = {
		None = 1,				--未开始或已结束
		PreParing = 2,			--准备阶段
		IsFighting = 3,			--战斗中
	},
	OrderType = {
		Attack = 1,				--进攻状态
		Defense = 2,			--防守状态
		Cancel = 3,				--取消状态
	},
	OrgWarScene = {
		Prepare = 1,			--预备场景
		War = 2,				--正式场景
		None = 3,			--默认场景
	},
}

Store = {
	Event = {
		Gold2Coin = 1,
		CloseGold2Coin = 2,
		RefreshItem = 3,
		SetShopData = 4,
		RefreshPayInfo = 5,
	},
	Page = {
		CrystalShop = 201,
		EquipShop = 203,
		MedalShop = 204,
		HonorShop = 205, --竞技场
		OrgMemberShop = 207,
		OrgFuLiShop = 209,
		PartnerSkin = 210,
		TravelShop  = 211, --游历商店：直接走netstore
		LiBaoShop = 212, --礼包商店
		LimitSkin = 215,
	},
	GoodsType = {
		Item = 1,
		Partner = 2,
		PartnerSkin = 3,
		PartnerEquip = 4,
		PartnerChip = 5,
	},
	ExchangeType = {
		GoldCoin2Coin = 1,--1水晶to金币
		ColorCoin2Coin = 2,--2彩晶to金币
		ColorCoin2GoldCoin = 3,--3:彩晶to水晶
		GoldCoin2Energy = 4, --水晶to体力
	}
}

Rank = {
	Event = {
		ReceiveData = 1,
		RefreshData = 2,
		LikeSuccess = 3,
		ClearAll = 4,
		ReceiveEmptyData = 5,
		UpdateTimeLimitRankInfo = 6,
	},
	RankId = {
		Boss = 102,
		Power = 103,
		Pata = 105,
		Arena = 106,
		EqualArena = 109,
		RJFb = 110,
		TerrawarOrg = 111,	 --据点公会
		TerrawarServer = 112, --据点全服
		OrgPrestige = 113,
		Partner = 115,
		Consume = 117,			--消费榜
	},
	HandleType = {
		None = 0,
		Like = 1,
		AwardList = 2,
		ReplayAndLike = 3,
		JoinUnion = 4,
		DetailAndLike = 5,
		PartnerDetail = 6,
	},
	SubType = {
		Common = 0,
		TimeLimit = 1,
	}
}

Arena = {
	Event = {
		ReceiveMatchResult = 1,
		ReceiveMatchPlayer = 2,
		OpenWatchPage = 3,
		OpenReplay = 4,
		SetShowing = 5,
		OnWarEnd = 6,
		OnReceiveLeftTime = 7,
	},
	MatchResult = {
		Success = 1,
		Fail = 2,
	},
	WarResult = {
		Win = 1,
		Fail = 2,
		NotReceive = 3,
	}
}

EqualArena = {
	Event = {
		ReceiveMatchResult = 1,
		ReceiveMatchPlayer = 2,
		OpenWatchPage = 3,
		OpenReplay = 4,
		SetShowing = 5,
		OnWarEnd = 6,
		OnReceiveLeftTime = 7,
		OnChangePartner = 8,
		OnSelectSection = 9,
		OnSetSelecting = 10,
		OnCombineStart = 11,
		OnCombineDone = 12,
		OnCloseEqualArenaUI = 13,
		OnCombineSubmit = 14,
	},
	MatchResult = {
		Success = 1,
		Fail = 2,
	},
	WarResult = {
		Win = 1,
		Fail = 2,
		NotReceive = 3,
	},
	MarkType = {
		Selecting = 1,
		None = 2,
		Selected = 3,
	},
	SelectingType = {
		Partner = 1,
		Equip = 2,
	},
	Awake = {
		Yes = 1,
		No = 0,
	}
}

PlayerInfo = {
	Style = {
		Default = 0,
		WithoutPK = 1,
	}
}

EndlessPVE = {
	Event = {
		OnReceiveRingInfo = 1,
		BeginCountDown = 2,
		OnWarEnd = 3,
		OnReceiveChipList = 4,
	}
}

Emote = {
	Text = {
		Coin = "#w1",
		GoldCoin = "#w2",
		ColorCoin = "#wa",
	}
}

Help = {
	Key = {
		Arena = "arena",
		EndlessPVE = "endlesspve",
		OrgInfo = "org_info",
		OrgBuild = "org_build",
		OrgWish = "org_wish",
		OrgTuitu = "org_tuitu",
		EqualArena = "equalarena",
	}
}

LoginReward = {
	Event = {
		LoginReward = 1, --七天登录奖励
	},
}

Sociality = {
	Event = {
		OnReceivePlay = 1, --七天登录奖励
	},
}

Welfare = {
	Event = {
		OnChangeSecondTest = 1,
		OnHistoryRecharge = 2,
		OnRechargeWelfare = 3,
		OnSetBackPartner = 4,
		OnBackPartnerInfo = 5,
		OnDailySign = 6,
		OnSevenDayTarget = 7,
		OnSevenDayTargetRedDot = 9,
		OnUpdateDay = 10,
		OnFirstCharge = 11,
		OnRewardBack = 12,
		OnCzjj = 13,
		OnYueKa = 14,
		UpdateCostPoint = 15,
		UpdateDrawCnt = 16,
		RefreshRedDot = 17,
		OnFreeEnergyZhongwu = 18,
		OnFreeEnergyWanshang = 19,
		OnFreeEnergyClose = 20,
		OnChargeBack = 21,
		OnUpdateYiYuanLiBaoList = 22,
		UpdateRechargeWelfare = 23,
		UpdateRushRecharge = 24,
		UpdateLoopPay = 25,
		OnUpdateYiYuanLiBao = 26,
		UpdateLimitPay = 27,
		OnChargeScore = 28,
		UpdateRankBack = 29,
		OnCostSaveInfo = 30,
	},
	ID = {
		SecondTest = 1,		--二测福利
		DailySign = 2,		--每日签到
		RechargeWelfare = 3,--充值返利
		TotalRecharge = 4,	--累计奖励
		ZhaoMuBaoLiu = 5,	--招募保留
		SevenDayTarget = 6,	--七天目标
		RewardBack = 7,		--找回奖励
		Czjj = 8,			--成长基金
		Yk = 9,				--月卡
		Zsk = 10,			--终身卡
		LimitReward =11,	--限时狂欢
		FreeEnergy = 12,	--每日体力
		CodeExchage = 13,	--兑换码
		ChargeBack = 14,	--充值豪礼
		CostSave = 15,		--消费预存
		LimitRankWelfare = 16,--冲榜返利(战力)
		LimitRankPartnerWelfare = 17,--冲榜返利(伙伴)
		QQVipWelfare = 18,
	},
}

PlayerBuff = {
	Event = {
		OnRefreshBuff = 1,
	}
}

OnlineGift = {
	Event = {
		UpdateStatus = 1,
		UpdateTime = 2,
	},
	Status = {
		Doing = 1,
		CanGet = 2,
		Got = 3,
	},
}

Convoy = {
	Event = {
		UpdateConvoyInfo = 1,
	},
}

ChapterFuBen = {
	Type = {
		Simple = 1, 	--普通模式
		Difficult = 2, 	--困难模式
	},
	Event = {
		OnChapterOpen = 1,
		OnUpdateChapterTotalStar = 2,
		OnUpdateChapterExtraReward = 3,
		OnChapterInfo = 4,
		OnSweepChapterReward = 5,
		OnUpdateUpdateChapter = 6,
		OnLogin = 7,
	},
}

TeamPvp = {
	Event = {
		UpdateRankData = 1,
		UpdataTeamData = 2,
		OnReceiveMatchInfo = 3,
		LeaveScene = 4,
		OnWarEnd = 5,
		OnRrefshLeftTime = 6,
	},
	WarResult = {
		Win = 1,
		Fail = 2,
		NotReceive = 3,
	},
}

MonsterAtkCity = {
	Event = {
		AddMonster = 1,
		DelMonster = 2,
		Rank = 3,
		MyRank = 4,
		CityDefend = 5,
		Open = 6,
		RefreshHP = 7,
		RefreshWave = 8,
		Yure = 9,
	},
	RankType = {
		RankPart = 1,
		InfoPart = 2,
	} 
}

HuntPartnerSoul = {
	Event = {
		OnAddPartnerSoul = 1,
		OnDelPartnerSoul = 2,
		UpdateNpc = 3,
		UpdateHuntInfo = 4,
		OnUpdateTime = 5,
	},
	Color = {
		[1] = "#W",
		[2] = "#B",
		[3] = "#P",
		[4] = "#O",
		[5] = "#R",
	},
}

Marry = {
	Event = {
		OnResponse = 1,
	},
}

GradeGift = {
	Event = {
		UpdateInfo = 1,
	},
	GiftType = {
		Free = 0,
		Buy = 1,
	},
	Status = {
		Foretell = 0,
		Buying = 1,
		Over = 2,
	},
}