TeacherStudent.Def = {
	tbTargetStates = {
		NotReport = 1,
		NotFinish = 2,
		Reported = 3,
		FinishedBefore = 4,	--拜师前达成
	},

	TIME_DELAY 	   = 600,	-- 消息超时时间

    nNpcMapTemplateId = 1000,	--师徒npc所在地图id
	nNpcTemplateId = 1839,		--师徒npc id

	nGiftMsgMax = 50,	--出师送礼留言最大长度
	nTeacherDeclarationMax = 42,	--收徒公告最大长度
	szTeacherNoticeDefault = "漫漫江湖路，我想找一个徒弟！",	--默认收徒公告
	nForceDissmissTime = 1*24*3600,	--离线超过x秒，可以强制解除关系
	nForceGraduateTime = 1*24*3600,	--离线超过x秒，可以强制出师
	nDismissWaitTime = 24*3600,	--解散等待时间
	nMaxUndergraduate = 2,	--最多多少个未出师徒弟
	nMaxTeachers = 2,	--最多多少个师父
	nDismissPunishTime = 24*3600,	--主动解散惩罚时间

	nGraduateDismissWaitTime = 14*24*3600,	--解除已出师关系等待时间
	nGraduateDismissQuitWaitTime = 1*24*3600,	--解除已出师关系等待时间(对方已弃游)
	nGraduateDismissCost = 1000,	--解除已出师关系消耗元宝

	nAddStudentNoCdCount = 2,	--前x个徒弟没有冷却时间
	nAddStudentInterval = 1*24*3600,	--收徒时间间隔

	nGraduateConnectDaysMin = 2,	--出师：拜师时间最少天数
	nGraduateTargetMin = 50,	--出师：出师目标最少完成数量

	nChuanGongTeacherExpBase = 30,	--师徒传功师傅获得x基准经验
	nChuanGongRefreshOffset = 4*3600,	--传功次数刷新时间偏移，详见Lib:IsDiffDay注释
	nDailyChuanGongMax = 5,	--每日最多累计传功次数(2徒弟，2师父)
	nFindTeacherListMax = 30,	--寻找师父最大显示数量
	nFindStudentListMax = 30,	--寻找徒弟最大显示数量
	nApplyListMax = 30,	--申请列表上限
	nGraduateDistance = 500,	--出师时,师徒的最大距离
	tbGraduateTeacherRewards = {	--徒弟出师，师父得到的奖励
		{
			nMin = 50, 	--目标最少完成数量，从小到大
			szJudgement = "普通",
			szJudgement2 = "普通",
			tbAttach = {	--奖励，与邮件附件配置相同
				{"Renown", 5000},
			},
		},
		{
			nMin = 60,
			bEliteAchieve = true,
			szJudgement = "杰出",
			szJudgement2 = "顶级",
			tbAttach = {
				{"Renown", 10000},
			},
		},
	},
	tbGraduateStudentRewards = {	--徒弟出师，得到的奖励
		{
			nMin = 50, 	--目标最少完成数量，从小到大
			szJudgement = "普通",
			szJudgement2 = "普通",
			tbAttach = {	--奖励，与邮件附件配置相同
				{"Item", 2762, 1},
			},
		},
		{
			nMin = 60,
			bEliteAchieve = true,
			szJudgement = "杰出",
			szJudgement2 = "顶级",
			tbAttach = {
				{"Item", 2763, 1},
			},
		},
	},

	nTargetProgressGroup = 106,	--目标保存在ServerSaveKey中的KEY_GROUP

	nTitleGroup = 107,	--师徒称号关系保存在ServerSaveKey中的KEY_GROUP
	tbTitleIds = {6100, 6101, 6102, 6103, 6104},	--可选称号id

	szTaskBuyCutOffWhite = "OpenLevel119",
	tbTargetTypeToIds = {	--师徒目标对应id
		OpenGoldBox = {1, 2},		--
		JoinKin = {3},				--
		BuyKinGift = {4, 5},		--
		KinDonate = {6, 7},			--
		KinSalary = {8, 9},			--
		DigGoods = {10, 11},		--完成x次挖宝--
		BuyMarketStall = {12},		--
		SellMarketStall = {13},		--
		WashEquipFull1 = {14},		--
		WashEquipFull10 = {15},		--
		AllEquipCC = {16},			--
		AllEquipXY = {17},			--
		DailyTargetFull = {18, 19},	--
		OpenXiuLian = {20, 21},		--
		ChengEr = {22, 23},			--惩恶次数--
		FuBenS = {24},				--
		FuBenSSS = {25},			--
		WuShenDian1500 = {26},		--
		WuShenDian500 = {27},		--
		ChallegeHero6 = {28},		--英雄挑战--
		ChallegeHero10 = {29},		--
		MengZhu1500 = {30},			--
		MengZhu500 = {31},			--
		FieldBoss = {32},			--野外首领--
		HistoryBoss = {33},			--历代名将--
		CommerceTask = {34, 35},	--
		BattleField = {36, 37},		--战场--
		KinPractice = {38, 39},		--
		AllEquipStrength20 = {40},	--
		AllEquipStrength30 = {41},	--
		AllEquipStrength40 = {42},	--
		EquipInsert1 = {43},		--镶嵌20个以上1级魂石--
		EquipInsert2 = {44},		--
		EquipInsert3 = {45},		--
		EquipInsert4 = {46},		--
		FactionBattle = {47, 48},	--
		JingHongTitle = {49},		--
		LingYunTitle = {50},		--
		YuKongTitle = {51},			--
		QianLongTitle = {52},		--
		BuyCutOffWhite = {56, 57},	--购买打折白水晶--
		BuyCutOffGreen = {58},		--打折绿水晶--
		Buy7DaysGift = {59},		--
		Buy30DaysGift = {60},		--
		BuyDailyGift = {61, 62},	--
		BuyInvestGift = {63},		--一本万利--
		Vip6 = {64},				--
	},

	tbCustomTargetTypeToIds = {	--自定义师徒目标对应id
		BattleField = {1},		--宋金战场--
		HistoryBoss = {2},		--历代名将--
		Tower = {3},			--通天塔--
		KinEscort = {4},		--运镖--
		FactionBattle = {5},	--门派竞技--
		FieldBoss = {6},		--野外首领--
		KinPractice = {7},		--家族试炼--
		CityWar	= {8},			--攻城战--
		WhiteTiger = {9},		--白虎堂--
		MengZhu = {10},			--武林盟主--
		KinGather = {11},		--家族烤火--
		SoulGhost = {12},		--心魔幻境--
		QinShiHuang = {13},		--秦始皇陵--
	},

	nMaxImityReportCount = 6,	--防刷，亲密度目标最多汇报次数（有三挡，2*3为6）
	tbImityTargetsIdToLevels = {	--师徒亲密度目标特殊处理,目标id对应的亲密度等级
		[53] = 10,
		[54] = 15,
		[55] = 20,
	},

	tbCustomTaskRewards = {	--任务奖励
		[1] = {500,  500},	--完成数量，徒弟经验奖励，师父名望奖励
		[2] = {750,  750},
		[3] = {1000, 1000},
		[4] = {1250, 1250},
		[5] = {1500, 1500},
		[6] = {2000, 2000},
		[7] = {2500, 2500},
		[8] = {3000, 3000},
	},
	nCustomTaskReportMin = 1,	--最少汇报多少条
	nCustomTaskCount = 8,	--师父每次给徒弟布置任务数量
	nCustomTaskLvDiff = 1,	--师父等级减徒弟等级 >= x
	nCustomTaskRemindCD = 10*60,	--提醒师父布置任务CD
	nCustomTaskRewardTop = 2,	--奖励完成目标数最多的前x名

	nConnectRiteMapId = 8016,	--拜师仪式副本地图id
	nConnectActId = 4,	--跪拜动作id
	nConnRiteTeaDelay = 2,	--徒弟跪拜师傅等待多久回应（秒）
	nConnRiteStuDelay = 5,	--师傅回应后等待多久徒弟站起来（秒）

	tbConnectRiteFireworks = {--拜师仪式烟花
		{9184,3432,5919, 0},
		{9185,3741,5911, 0},
		{9186,4007,5914, 0},
		{9187,4290,5918, 0},
		{9188,4575,5926, 0},
		{9189,3428,6265, 0},
		{9184,3744,6262, 0},
		{9185,4026,6262, 0},
		{9186,4323,6257, 0},
		{9187,4569,6254, 0},
		{9188,4569,6775, 0},
		{9189,4311,6781, 0},
		{9184,3982,6781, 0},
		{9185,3693,6785, 0},
		{9186,3433,6785, 0},
		{9187,3423,7093, 0},
		{9188,3703,7102, 0},
		{9189,3966,7093, 0},
		{9188,4311,7102, 0},
		{9189,4587,7109, 0},
	},
}
