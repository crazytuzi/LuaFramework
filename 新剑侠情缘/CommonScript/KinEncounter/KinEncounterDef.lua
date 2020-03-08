KinEncounter.Def = {
	nPrepareMapId = 6200,	--准备场地图
	nFightMapId = 6201,	--战场地图

	nJoinLevel = 60,	--参与等级
	nMinKinMemberCount = 8,	--家族最低参与人数

	nPrepareTime = 6 * 60,	--准备时间
	nReadyGoWaitTime = 9,	--播放321 ready go动画等待时间
	nFightWaitTime = 12,	--战斗开始前等待时间
	nFightTime = 15 * 60,	--战斗时间
	nDelayKickoutTime = 5,	--结束后多久踢出所有玩家

	nPrepareMapUpdateInfoTime = 3,	--准备场刷新信息时间间隔(秒)
	tbPreMapEnterPos = {{2709, 5659}, {2666, 6319}, {2684, 5001}, {6931, 5712}, {6947, 6462}, {6947, 4994}},     -- 准备场进入点

	tbFightMapEnterPos = {{3552, 9365}, {23666, 8711}},	--战斗地图出生点{A, B}

	tbMapPeaceNpcs = {
		walls = {	--障碍门
			a_t = {id = 104, x=5275, y=10797, dir=26},
			a_b = {id = 104, x=4807, y=7691, dir=10},
			b_t = {id = 104, x=21954, y=9963, dir=6},
			b_b = {id = 104, x=22574, y=6770, dir=22},
		},

		gates = {	--传送门
			a_t = {id = 73, x=4657, y=7970},
			a_b = {id = 73, x=5054, y=10679},
			b_t = {id = 73, x=22720, y=7041},
			b_b = {id = 73, x=22201, y=9786},
		},
	},

	tbMapResNpcs = {
		dragon = {	--龙柱
			c = {id = {
					{30, 2974},	--人数上限（含）, npc id
					{50, 3163},
					{70, 3162},
					{90, 3164},
					{110, 3165},
					{130, 3166},
					{150, 3167},
				}, x=14110, y=9397, name="龙柱"},
		},

		food = {	--粮仓
			t = {id = {
					{30, 3156},	--人数上限（含）, npc id
					{50, 3186},
					{70, 3187},
					{90, 3188},
					{110, 3189},
					{130, 3190},
					{150, 3191},
				}, x=6504, y=4781, name="西·粮仓"},
			b = {id = {
					{30, 2976},	--人数上限（含）, npc id
					{50, 3174},
					{70, 3175},
					{90, 3176},
					{110, 3177},
					{130, 3178},
					{150, 3179},
				}, x=20228, y=12991, name="东·粮仓"},
		},

		wood = {	--神木
			t = {id = {
					{30, 2975},	--人数上限（含）, npc id
					{50, 3168},
					{70, 3169},
					{90, 3170},
					{110, 3171},
					{130, 3172},
					{150, 3173},
				}, x=9684, y=14331, name="封渊神木"},
			b = {id = {
					{30, 3155},	--人数上限（含）, npc id
					{50, 3180},
					{70, 3181},
					{90, 3182},
					{110, 3183},
					{130, 3184},
					{150, 3185},
				}, x=17513, y=2252, name="雄常神木"},
		},
	},

	tbTraps = {
		["A_chuansong_N"] = {5525, 10900},	--传送点 = 目标坐标
		["A_chuansong_S"] = {4937, 7500},
		["B_chuansong_N"] = {21706, 10128},
		["B_chuansong_S"] = {22404, 6512},
	},

	tbWays = {								--自动寻路通路矩形的端点
		{ {5262, 10740}, {5458, 10740}},
		{ {4675, 7690}, {5070, 7690}},
		{ {21783, 9957}, {22037, 9957}},
		{ {22315, 6765}, {22652, 6765}},
	},

	nMultKillBroadcast = 10,	--连杀x人家族提示
	tbNpcHpNotify = {50, 30, 10},	--npc血量预警

	tbFoodBuff = {5144, 1},	--占领粮仓加buff，{id, 等级}
	nActiveInterval = 3,	--数据（积分、木材等）更新间隔（秒）

	nWoodReward = 0,	--占领一个神木奖励的木材
	nWoodIncSpeed = 1,	--占领一个神木提供的木材增加速度（个/秒）
	nInitWood = 90,	--初始木材数量

	nMaxScore = 10000,	--最大积分
	nKeepTime = 3 * 60,	--计算积分增速时的保留时间（秒）

	tbRewards = {	--奖励
		tbSingle = {	--轮空
			{"item", 8463, 1}, {"BasicExp", 100},
		},
		tbWin = {	--胜利
			{20, {{"item", 8462, 1}, {"BasicExp", 100}}},	--排名百分比，奖励
			{50, {{"item", 8463, 1}, {"BasicExp", 100}}},
			{80, {{"item", 8464, 1}, {"BasicExp", 90}}},
			{100, {{"item", 8465, 1}, {"BasicExp", 80}}},
		},
		tbLose = {	--失败
			{20, {{"item", 8466, 1}, {"BasicExp", 100}}},	--排名百分比，奖励
			{50, {{"item", 8467, 1}, {"BasicExp", 90}}},
			{80, {{"item", 8468, 1}, {"BasicExp", 80}}},
			{100, {{"item", 8469, 1}, {"BasicExp", 60}}},
		},
	},

	tbToolCfgs = {	--工具配置
		[3192] = {	--npc id
			nShowItemId = 8457,	--物品id（用于购买界面展示）
			nPrice = 30,	--制造消耗木材量
			nMaxAlive = 5,	--最多在战场中存在数量（单个家族）
		},
	},

	tbNpcLevel = {	--时间轴对应npc等级
		["OpenLevel59"] = 55,
		["OpenLevel69"] = 65,
		["OpenLevel79"] = 75,
		["OpenLevel89"] = 85,
		["OpenLevel99"] = 95,
		["OpenLevel109"] = 105,
		["OpenLevel119"] = 115,
		["OpenLevel129"] = 125,
		["OpenLevel139"] = 135,
		["OpenLevel149"] = 145,
		["OpenLevel159"] = 155,
	},

	tbTransformBuffLevel = {	--时间轴对应使用军械库变身等级
		["OpenLevel59"] = 1,
		["OpenLevel69"] = 2,
		["OpenLevel79"] = 3,
		["OpenLevel89"] = 4,
		["OpenLevel99"] = 5,
		["OpenLevel109"] = 5,
		["OpenLevel119"] = 6,
		["OpenLevel129"] = 6,
		["OpenLevel139"] = 7,
		["OpenLevel149"] = 7,
		["OpenLevel159"] = 8,
	},

	tbRecordRewards = {	--汇总奖励
		[8] = {
			{8458, 193},	--领袖(称号物品id, 红包EventId)
			{8459, 194},	--族长
		},
		[7] = {
			{8458, 193},	--领袖(称号物品id, 红包EventId)
			{8459, 194},	--族长
		},
		[6] = {
			{8458, 193},	--领袖(称号物品id, 红包EventId)
			{8459, 194},	--族长
		},
		[5] = {
			{8460, 195},	--领袖(称号物品id, 红包EventId)
			{8461, 196},	--族长
		},
		[4] = {
			{8460, 195},	--领袖(称号物品id, 红包EventId)
			{8461, 196},	--族长
		},
		[3] = {
			{8460, 195},	--领袖(称号物品id, 红包EventId)
			{8461, 196},	--族长
		},
	},

	nOpenHour = 21,	--开启时间
	tbOpenDates = {	--开启日期
		Lib:ParseDateTime("2018-8-10"),
		Lib:ParseDateTime("2018-8-12"),
		Lib:ParseDateTime("2018-8-13"),
		Lib:ParseDateTime("2018-8-15"),
		Lib:ParseDateTime("2018-8-17"),
		Lib:ParseDateTime("2018-8-19"),
		Lib:ParseDateTime("2018-8-20"),
		Lib:ParseDateTime("2018-8-22"),
	},

	tbManagerCareers = {
		[Kin.Def.Career_Master] = true,
		[Kin.Def.Career_ViceMaster] = true,
		[Kin.Def.Career_Elder] = true,
		---[Kin.Def.Career_Mascot] = true,	
	},
}
