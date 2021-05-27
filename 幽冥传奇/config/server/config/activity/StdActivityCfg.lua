
--#include "..\..\language\LangCode.txt" once
StdActivityCfg = {
	[1] = {
		id = 1,
		name = Lang.dayactivity.name0001,
		timeDesc = Lang.dayactivity.time0001,
		ruleDesc = Lang.dayactivity.rule0001,
		entrance = Lang.dayactivity.talk0001,
		desc = Lang.dayactivity.desc0001,
		rewardicon = "{reward;0;480;1}{reward;0;2815;1}{reward;0;2816;1}{reward;0;2817;1}",
		Delivery = "moveto,4",
		awardIcons =
			{
				{type = 0, id = 480, count = 1, bind = 1},
				{type = 0, id = 2815, count = 1, bind = 1},
				{type = 0, id = 2816, count = 1, bind = 1},
				{type = 0, id = 2817, count = 1, bind = 1},
			},
		activityCfg = "活动规则: \n1.场景内每8秒获得一次奖励,人数越少奖励越丰厚\n2.站在温泉上方可享受多倍奖励: 红圈(5倍)、橙圈(4倍)、紫圈(3倍)、蓝圈(2.5倍)、绿圈(2倍)\n3.PK不增加PK值、死亡不掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value1$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"9", "50", "10", "10",},
				{"14", "40", "15", "00",},
				{"23", "30", "23", "50",},
			},
		},
		activitytime = 1200,
		RwData = {"闭关修炼", "土城", 78,69, "{moveto;4;[我也要参加]}"},
		sceneid = 51,
		level = 250,
		second = 8,
		NpcDlg = {
			enterCond = {
				"等级限制: {color;ff00ff00;250级以上}\n",
				"活动时间: {color;ff00ff00;9:50-10:10  14:40-15:00  23:30-23:50}\n",
			},
			dlgDesc = {
				"{flag;0}活动奖励: {color;ff00ff00;魔书-书灵、魔书-资质丹}\n",
				"{flag;0}活动场景内的玩家{color;ff00ff00;每8秒获得一次奖励},人数越少奖励越丰厚\n",
				"{flag;0}特效圈可享多倍奖励: {color;ffff0000;红圈(5倍)}、{color;ffff8a00;橙圈(4倍)}、{color;ffde00ff;紫圈(3倍)}、{color;ff00c0ff;蓝圈(2.5倍)}、{color;ff00ff00;绿圈(2倍)}\n",
				"{flag;0}{color;ff00c0ff;PS: PK不增加PK值、死亡不掉落}",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		tPosMultiple = {
			{34, 34, 5, "{color;FFff0000;红圈}",},
			{31, 31, 4, "{color;FFff8a00;黄圈}",},
			{37, 37, 4, "{color;FFff8a00;黄圈}",},
			{39, 29, 3, "{color;FFde00ff;紫圈}",},
			{32, 20, 2, "{color;FF00ff00;绿圈}",},
			{27, 26, 2.5, "{color;FF00c0ff;蓝圈}",},
			{21, 32, 2, "{color;FF00ff00;绿圈}",},
			{48, 36, 2, "{color;FF00ff00;绿圈}",},
			{42, 42, 2.5, "{color;FF00c0ff;蓝圈}",},
			{30, 39, 3, "{color;FFde00ff;紫圈}",},
			{37, 48, 2, "{color;FF00ff00;绿圈}",},
		},
		tReward = {
			{min = 11, max = -1,wards = {{type=50, id=0, count=20,bind=1},},},
			{min = 6, max = 10, wards = {{type=50, id=0, count=30,bind=1},},},
			{min = 1, max = 5, wards =  {{type=50, id=0, count=50,bind=1},},},
		},
		tRewardDesc =
		{
			{ idIndex = 50,bind=1,desc ="书灵: {color;ff00ff00;%d}\n", },
			--{ idIndex = 20000,bind=1,desc ="等级丹碎片: {color;ff00ff00;%d}\n", },
		},
	},
	[2] =
	{
		id = 2,
		name = Lang.dayactivity.name0012,
		timeDesc = Lang.dayactivity.time0012,
		ruleDesc = Lang.dayactivity.rule0012,
		entrance = Lang.dayactivity.talk0012,
		desc = Lang.dayactivity.desc0012,
		rewardicon = "{reward;0;1631;1}{reward;0;2057;1}{reward;0;2514;1}{reward;0;493;1}",
		Delivery = "moveto,12",
		-- tracktxt = "{color;FFff0000;$value1$/$value2$}\n{color;FF00c0ff;活动奖励:}\n    <(iaward#4#1)><(iaward#5#1)><(iaward#6#1)>",
		activityCfg = "1.击杀BOSS拾取土豪宝箱，将获得持宝人称号，并每8秒获得1次丰厚奖励；\n2.持宝人死亡或者下线，宝箱都会掉落在地上，其他人可随意拾取；\n3.活动结束，持宝人可获得一个土豪宝箱，开启获得特戒；\n4.活动场景内的玩家每8秒可获得一次奖励；\n5.活动地图内PK不增加PK值、死亡不掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value14$}",
		tOpenTime =
		{
			weeks={0},
			times =
			{
				{"16", "00", "16", "20",},
			}
		},
		tScene = {"土  城", 103, 64,},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上\n}",
				"活动时间: {color;ff00ff00;16:00-16:20}(开服第1天，每日可以挑战)",
			},
			dlgDesc =
			{
				"{flag;1}活动奖励: {color;ff00ff00;特戒、精炼石、元宝}\n",
				"{flag;1}持宝箱人若死亡或者下线背包处的宝箱自动掉落其他人随意拾取，\n",
				"　拾取后开始计时，{color;ff00ff00;满8秒则给一次奖励};\n",
				"{flag;1}活动结束，持宝人可获得土豪宝箱，开启获得大量上古残卷；\n",
				"{flag;1}活动场景内的玩家{color;ff00ff00;每8秒可获得一次奖励}；\n",
				"{flag;1}{color;ff00c0ff;PS:活动地图内PK不增加PK值、死亡不掉落}",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		activitytime = 1200,
		level = 250,
		enterxy = {x =56 ,y =75 },
		RankName = "QiBingDuoBao",
		PaoDianTimeInterval = 8,
		SceneName = Lang.SceneName.s00099,
		sceneId = 99,
		startTime = {16,00,0},
		endTime = {16,20,0},
		timerInterval = 3*60*1000,
		titleId = 41,
		propId = 1632,
		giftId = 1631,
		BossId = 463,
		BossStartTime = 0,
		BossTimeInterval = 1200,
		BossPos = {54, 55},
		minLevel = 200,
		outSceenId = 3,
		outMapX = {103},
		outMapY = {64},
		relivex = {107},
		relivey = {76},
		opsvDays = 1,
		Awards =
		{
		},
		awardsMasterTitle =
		{
			{ type = 0, id = 1632, count = 1, strong = 0, quality = 0, bind = 0 },
		},
		awardsMaster =
		{
					{type = 6, id = 0, count = 10000, bind = 1,IncomeDesc ="元  宝 : {color;ff00ff00;%d}\n",},
					{type = 0, id = 2514, count = 5 , bind = 1,IncomeDesc ="精炼石 : {color;ff00ff00;%d}\n",},
					--{type = 0, id = 20, count = 1, bind = 1,IncomeDesc ="等级直升丹碎片 : {color;ff00ff00;%d}\n"},
		},
		pdAward =
		{
			{minlv = 250, maxlv = -1, wards =
				{
					{type=6, id=0, count=5000,bind=1, IncomeDesc ="元  宝 : {color;ff00ff00;%d}\n",},
					{type=0, id=2514, count=2,bind=1, IncomeDesc ="精炼石 : {color;ff00ff00;%d}\n",},
				},
			},
		},
		chuanSongIdx = 12,
		RwData = {"夺宝奇兵", "土城", 103, 64, "{moveto;12;[我也要参加]}"},
	},
	[3] = {
		id = 3,
		name = Lang.dayactivity.name0010,
		timeDesc = Lang.dayactivity.time0010,
		ruleDesc = Lang.dayactivity.rule0010,
		entrance = Lang.dayactivity.talk0010,
		desc = Lang.dayactivity.desc0010,
		rewardicon = "{reward;0;2510;1}{reward;0;493;1}",
		Delivery = "moveto,9",
--		tracktxt = "{color;FF00c0ff;剩余怪物: }{color;FFff0000;$value1$/$value2$}\n{color;FF00c0ff;活动奖励:}\n    <(iaward#4#1)><(iaward#5#1)><(iaward#6#1)>",
		activityCfg = "活动规则: \n1.行会闯关共10层,每通一关可获得宝石碎片、元宝奖励\n2.击败当层BOSS即可从闯关指引者NPC领取奖励并进入下一层",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value12$}",
		tOpenTime = {
			weeks={1,5},
			times = {
				{"20", "00", "21", "00",},
			}
		},
		level = 250,
		fubenid = 32,
		activitytime = 3600,
		scenedata =
		{
			{53,  71, 30, 472},
			{123, 71, 30, 473},
			{124, 71, 30, 474},
			{125, 71, 30, 475},
			{126, 71, 30, 476},
			{127, 71, 30, 477},
			{128, 71, 30, 478},
			{129, 71, 30, 479},
			{130, 71, 30, 480},
			{131, 71, 30, 481},
		},
		awards =
		{
			{
				itemlist =
				{
					{type = 0, id =2510, count = 200, bind = 1},
					{type = 6, id = 493, count = 200000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;200}\n元宝:{color;ff00ff00;200000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 250, bind = 1},
					{type = 6, id = 493, count = 300000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;250}\n元宝:{color;ff00ff00;300000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 300, bind = 1},
					{type = 6, id = 493, count = 400000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;300}\n元宝:{color;ff00ff00;400000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 350, bind = 1},
					{type = 6, id = 493, count = 500000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;350}\n元宝:{color;ff00ff00;500000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 400, bind = 1},
					{type = 6, id = 493, count = 600000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;400}\n元宝:{color;ff00ff00;600000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 450, bind = 1},
					{type = 6, id = 493, count = 700000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;450}\n元宝:{color;ff00ff00;700000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 500, bind = 1},
					{type = 6, id = 493, count = 800000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;500}\n元宝:{color;ff00ff00;800000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 600, bind = 1},
					{type = 6, id = 493, count = 900000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;600}\n元宝:{color;ff00ff00;900000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 700, bind = 1},
					{type = 6, id = 493, count = 1000000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;700}\n元宝:{color;ff00ff00;1000000}\n",
			},
			{
				itemlist =
				{
					{type = 0, id =2510, count = 800, bind = 1},
					{type = 6, id = 493, count = 1200000, bind = 1},
				},
				desc = "宝石碎片:{color;ff00ff00;800}\n元宝:{color;ff00ff00;1200000}\n",
			},
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;加入任意一个行会}\n",
				"活动时间: {color;ff00ff00;20:00-21:00 (每周一、五)}\n",
			},
			dlgDesc =
			{
				"{flag;0}活动奖励: {color;ff00ff00;宝石碎片、元宝}\n",
				"{flag;0}行会闯关{color;ff00ff00;共10层},每通一关可获得{color;ff00ff00;宝石碎片}和{color;ff00ff00;元宝}奖励\n",
				"{flag;0}击败{color;ff00ff00;当层BOSS}即可从闯关指引者NPC领取奖励并进入下一层\n",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		NextNpcDlg =
		{
			enterCond =
			{
				"当前关数: {color;ff00ff00;%d关}\n",
				"当前状态: {color;ff00ff00;%s}\n",
			},
			enterNextBtn = "{btn;0;进入下层;%s;%s}",
			AwardBtn = "{btn;0;领取奖励;%s;%s}",
		},
		RwData = {"行会闯关", "土城", 97, 71, "{moveto;9;[我也要参加]}"},
	},
	[4] = {
		id = 4,
		name = Lang.dayactivity.name0011,
		timeDesc = Lang.dayactivity.time0011,
		ruleDesc = Lang.dayactivity.rule0011,
		entrance = Lang.dayactivity.talk0011,
		desc = Lang.dayactivity.desc0011,
		rewardicon = "{reward;0;1663;1}{reward;0;1664;1}{reward;0;1694;1}{reward;0;495;1}",
		Delivery = "moveto,10",
--		tracktxt = "{color;FF00c0ff;剩余怪物: }{color;FFff0000;$value1$/$value2$}\n{color;FF00c0ff;活动奖励:}\n    <(iaward#4#1)><(iaward#5#1)><(iaward#6#1)>",
		activityCfg = "活动规则: \n胜负区分: \n    1.进入攻城战(活动)场景途径:传送阵NPC→沙城→皇宫\n    2.攻城战(活动)开启10分钟,皇宫内仅剩一个行会时可暂时获得沙城归属\n    3.清除完皇宫内沙城归属的行会可暂时获得沙城归属\n    4.21:00(活动结束)皇宫内获得沙城归属的行会将真正获得胜利\n奖励区分: \n    1.攻城战(活动)胜利的行会会长、副会长、各堂主、其他成员和其他参与行会\n    2.详细规则和活动奖励请查看: 沙城争霸面板",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value13$}",
		tOpenTime = {
			weeks={2,4,6},
			times = {
				{"20", "00", "21", "00",},
			}
		},
		tScene = {"沙城", 110, 7,},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;加入任意一个行会\n}",
				"活动时间: {color;ff00ff00;20:00-21:00 (每周二、四、六)}",
			},
			dlgDesc =
			{
				"{flag;1}活动奖励: {color;ff00ff00;沙城称号、沙城装备、钻石、元宝、寻宝要是\n}",
				"{flag;1}参加{color;ff00ff00;攻城战(活动)}必须加入某个行会,或自己建行会\n",
				"{flag;1}攻城战规则: \n",
				"　  首次 {color;ff00ff00;新服第三天  20:00-21:00\n}",
				"　  合区 {color;ff00ff00;合服第三天  20:00-21:00\n}",
				"　  其他 {color;ff00ff00;每周二、四、六  20:00-21:00\n}",
				"　  申请攻城时间 {color;ff00ff00;每周一、三、五\n}",
				"  　新服第三天、合服第三天无需申请攻城\n",
				"{flag;1}{color;ff00c0ff;PS: 只有行会会长和副会长可申请攻城}\n",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
			applyBtn = "{btn;0;申请攻城;OpenView,WangChengZhengBa}",
		},
	},
	[5] = {
		id = 5,
		name = Lang.dayactivity.name0005,
		timeDesc = Lang.dayactivity.time0005,
		ruleDesc = Lang.dayactivity.rule0005,
		entrance = Lang.dayactivity.talk0005,
		desc = Lang.dayactivity.desc0005,
		rewardicon = "{reward;0;2262;1}{reward;0;22;1}{reward;0;273;1}",
		Delivery = "moveto,3",
--		tracktxt = "{color;FF00c0ff;收益统计: }\n  {color;FF827556;泡点获得经验: }{color;FF00ff00;$value1$}\n  {color;FF827556;鄙视/膜拜次数: }{color;FF00ff00;$value2$/$value3$}\n  {color;FF827556;鄙视/膜拜经验: }{color;FF00ff00;$value4$}\n  {color;FF827556;累计获得经验: }{color;FF00ff00;$value5$}",
		activityCfg = "活动规则: \n1.每天可拥护/反对城主10次,10星更能额外获得灭魔令x1\n2.站在城主雕像附近每8秒可获得一次奖励",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value5$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"12", "40", "13", "10",},
				{"17", "40", "18", "10",},
			},
		},
		getMasterYbTimes =
		{
			beginTimes = {20, 05},
			endTimes = {23, 59},
		},
		level = 200,
		sceneId = 3,
		activitytime = 1800,
		maxTimes = 10,
		interval = 8,
		ybRefresh = 88,
		bindcoinRefresh = 10000,
		maxAddupYb = 2000,
		worshipAddYb = 1,
		despiseReduceYb = 2,
		tPos = {{87,105}, {87,96}, {99,96}, {99,105},},
		pdAward =
		{
			{minlv = 250, maxlv = 399, wards = {{type=0, id=273, count=1,bind=1},}, },
			{minlv = 400, maxlv = 499, wards = {{type=0, id=273, count=3,bind=1},},},
			{minlv = 500, maxlv = 599, wards = {{type=0, id=273, count=5,bind=1},},},
			{minlv = 600, maxlv = 699, wards = {{type=0, id=273, count=8,bind=1},},},
			{minlv = 700, maxlv = -1, wards = {{type=0, id=273, count=12,bind=1},},},
		},
		pdAwardDesc =
		{
			--{ idIndex = 20000,desc ="等级丹碎片 : {color;ff00ff00;%d}\n", },
			{ idIndex = 273000,desc ="护盾碎片 : {color;ff00ff00;%d}\n", },
		},
		psmbAward = {
			{multiple = 1, awards = {{type = 0, id = 22, count = 2, bind = 1,},}, rate = 10000,},
			{multiple = 2, awards = {{type = 0, id = 22, count = 4, bind = 1,},}, rate = 5000,},
			{multiple = 3, awards = {{type = 0, id = 22, count = 6, bind = 1,},}, rate = 5000,},
			{multiple = 4, awards = {{type = 0, id = 22, count = 8, bind = 1,},}, rate = 5000,},
			{multiple = 5, awards = {{type = 0, id = 22, count = 10, bind = 1,},}, rate = 5000,},
			{multiple = 6, awards = {{type = 0, id = 22, count = 12, bind = 1,},{type = 0, id = 2262, count = 3, bind = 1},}, rate = 5000,},
			{multiple = 7, awards = {{type = 0, id = 22, count = 14, bind = 1,},{type = 0, id = 2262, count = 5, bind = 1},}, rate = 5000,},
			{multiple = 8, awards = {{type = 0, id = 22, count = 16, bind = 1,},{type = 0, id = 2262, count = 8, bind = 1},}, rate = 4000,},
			{multiple = 9, awards = {{type = 0, id = 22, count = 18, bind = 1,},{type = 0, id = 2262, count = 10, bind = 1},}, rate = 4000,},
			{multiple = 10, awards = {{type = 0, id = 22, count = 20, bind = 1,},{type = 0, id = 2262, count = 20, bind = 1},}, rate = 4000,},
		},
		RwData = {"城主雕像", "土城", 93, 100, "{moveto;3;[我也要鄙视]}", "我也要膜拜", "鄙视", "膜拜"},
	},
	[6] = {
		id = 6,
		name = Lang.dayactivity.name0006,
		timeDesc = Lang.dayactivity.time0006,
		ruleDesc = Lang.dayactivity.rule0006,
		entrance = Lang.dayactivity.talk0006,
		desc = Lang.dayactivity.desc0006,
		rewardicon = "{reward;0;1687;1}{reward;0;495;1}{reward;0;493;1}",
		Delivery = "moveto,5",
		awardIcons =
			{
				{type = 0, id = 1687, count = 1, bind = 1},
				{type = 0, id = 495, count = 1, bind = 1},
				{type = 0, id = 493, count = 1, bind = 1},
			},
--		tracktxt = "{color;FF00c0ff;胜利奖励: }\n    <(iaward#26#1)>{color;FF00ff00;武林争霸称号 x $value1$}\n    <(iaward#3#1)>{color;FF00ff00;元宝 x $value2$}\n    <(iaward#5#1)>{color;FF00ff00;金条(大) x $value3$}\n{color;FF00c0ff;参与奖励: }\n    <(iaward#5#1)>{color;FF00ff00;金条(中) x $value4$}",
		activityCfg = "活动规则: \n1.入场时间:19:00-19:35\n2.活动开始自由PK,之后活动场景内仅存一名玩家,则自动宣告活动结束\n3.场景内每8秒可获得一次奖励,角色等级越高经验越高\n4.活动结束可通过与NPC对话领取奖励\n5.PK不增加PK值、死亡不掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value6$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"19", "00", "19", "35",},
			},
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上}\n",
				"入场时间: {color;ff00ff00;19:00-19:30}\n",
				"活动时间: {color;ff00ff00;19:00-19:35(每日)}\n",
			},
			dlgDesc =
			{
				"{flag;0}胜利奖励: {color;ff00ff00;雄霸天下(称号)、5000钻石、元宝}\n",
				"{flag;0}参与奖励: {color;ff00ff00;500钻石、元宝}\n",
				"{flag;0}活动开始自由PK,之后活动场景内仅存一名玩家,则自动宣告活动结束\n",
				"{flag;0}活动场景内的玩家{color;ff00ff00;每8秒可获得一次奖励},角色等级越高经验越高\n",
				"{flag;0}活动开启前10分钟自动{color;ff00ff00;收回上届颁发的雄霸天下(称号)}\n",
				"{flag;0}活动结束可通过与{color;ff00ff00;NPC对话领取奖励}\n",
				"{flag;0}活动时间结束,仍无法决出胜负时自动{color;ff00ff00;宣告失败}\n",
				"{flag;0}{color;ff00c0ff;PS: PK不增加PK值、死亡不掉落}",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
			awardBtn = "{btn;0;领取奖励;%s;%s}",
		},
		activitytime = 2100,
		level = 250,
		awardsYb = 5000,
		limitTimes = 30,
		clearTimes = 10,
		lastTime = 2100,
		RankName = "WuLinZhengBa",
		RankTxt = "WuLinZhengBaConfig.txt",
		lowSceenId = 50,
		wMapX = {19,40},
		wMapY = {27,46},
		outSceenId = 3,
		outMapX = {107},
		outMapY = {76},
		RankColumn =
		{
			{columnName = "name", ShowFlag = 0},
			{columnName = "state", ShowFlag = 0},
		},
		LoopTime = 8,
		Awards =
		{
		},
		awardsMasterTitle =
		{
			{ type = 0, id = 1687, count = 1, strong = 0, quality = 0, bind = 1 },
		},
		awardsMaster =
		{
			{ type = 0, id = 269, count = 10, strong = 0, quality = 0, bind = 1 },
			{ type = 15, id = 0, count = 5000, strong = 0, quality = 0, bind = 0 },
		},
		awardsSignUp =
		{
			{ type = 0, id = 266, count = 20, strong = 0, quality = 0, bind = 1 },
			{ type = 15, id = 0, count = 500, strong = 0, quality = 0, bind = 0 },
		},
		fRate = 0.1,
		pdAward = {
			{minlv = 250, maxlv = -1, wards = {{type=6, id=0, count=5000,bind=0},},},
		},
		Awards = {
			{type = 0, id = 269, count = 5,},
		},
		AddBuff =
		{
			{buffType= 64, value=1, buffGroup= 205,times =-1,interval= 21,needDelete = true,timeOverlay = true,buffName = Lang.Activity.w00026,},
		},
		RwData = {"武林争霸", "土城", 86, 76, "{moveto;5;[我也要参加]}"},
	},
	[7] = {
		id = 7,
		name = Lang.dayactivity.name0007,
		timeDesc = Lang.dayactivity.time0007,
		ruleDesc = Lang.dayactivity.rule0007,
		entrance = Lang.dayactivity.talk0007,
		desc = Lang.dayactivity.desc0007,
		rewardicon = "{reward;0;495;1}{reward;0;493;1}",
		Delivery = "moveto,6",
		awardIcons =
			{
				{type = 0, id = 495, count = 1, bind = 0},
				{type = 0, id = 493, count = 1, bind = 0},
			},
		trackArray = {"13:40:00", "14:10:00", "", "22:30:00", "23:00:00", ""},
--		tracktxt = "{color;FF00c0ff;当前波数: }{color;FF00c0ff;$value1$波}\n{color;FF00c0ff;下波时间: }{color;FF00c0ff;$array2$}\n{color;FF00c0ff;主要掉落: }<(iaward#3#1)><(iaward#4#1)><(iaward#5#1)>",
		activityCfg = "活动规则: \n1.每五分钟在水上乐园刷出一波水龟,一共刷新3波\n2.消灭的水龟越多,获得奖励越多\n3.最后一波刷新超级水龟，更有钻石掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value7$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"13", "40", "14", "10",},
				{"22", "30", "23", "00",},
			}
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上}\n",
				"活动时间: {color;ff00ff00;13:40-14:10  22:30-23:00}\n",
			},
			dlgDesc =
			{
				"{flag;0}活动奖励: {color;ff00ff00;大量钻石、海量元宝}\n",
				"{flag;0}{color;ff00ff00;每五分钟}刷出一波水龟,一共刷新{color;ff00ff00;3波},{color;ff00ff00;第3波}将随机刷出一只超级水龟,\n   爆率最高，掉落钻石\n",
				"{flag;0}{color;ff00c0ff;PS: 消灭的水龟越多,获得奖励越多}",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		RwData = {"元宝嘉年华", "土城", 103, 66, "{moveto;6;[我也要参加]}"},
		level = 250,
		activitytime = 1800,
		liveTime = 1800,
		sceneId = 3,
		refreshTimes = {3, 300, 600},
		refresh = {
			{
				{455,20,86, 49,30,30},
				{456,10,86, 49,30,30},
				{457,1,77, 105,15,25},
			},
			{
				{455,20,86, 49,30,30},
				{456,10,86, 49,30,30},
				{457,1,77, 105,15,25},
			},
			{
				{455,20,86, 49,30,30},
				{456,10,86, 49,30,30},
				{457,1,77, 105,15,25},
			},
		},
	},
	[8] = {
		id = 8,
		qid = 4002,
		name = Lang.dayactivity.name0004,
		timeDesc = Lang.dayactivity.time0004,
		ruleDesc = Lang.dayactivity.rule0004,
		entrance = Lang.dayactivity.talk0004,
		desc = Lang.dayactivity.desc0004,
		rewardicon = "{reward;0;22;30}{reward;0;1660;30}{reward;0;266;30}",
		Delivery = "moveto,20",
--		tracktxt = "$value1$: {color;FFff0000;($value2$)}\n{color;FF00c0ff;镖车时间: }{color;FFff0000;$value3$}\n{color;FF00c0ff;镖车奖励: }{color;FFff0000;$value4$}\n  <(iaward#2#1)>$value5$<(iaward#5#1)>$value6$<(iaward#20#1)>$value7$",
		activityCfg = "活动规则: \n1.每天双倍时间: 11:30-12:00、18:20-18:50\n2.押镖路线: 比奇城→土城\n3.镖车已购保险: 成功押镖获得150%的收益，而且额外获得特殊宝箱,失败获得100%的收益\n4.镖车未购保险: 成功押镖获得100%的收益,失败获得50%的收益\n5.有保险的镖车被劫将从保证金扣除200钻石(掉落在地上,任何人都可拾取)\n6.未按时交镖(30分钟内)、镖车被劫、人物死亡、中途下线则算护送失败",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value4$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"11", "30", "12", "00",},
				{"18", "20", "18", "50",},
			},
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上}\n",
				"活动时间: {color;ff00ff00;11:30-12:00、18:20-18:50}\n",
			},
			dlgDesc =
			{
			"{flag;0}活动奖励：{color;ff00ff00;等级丹碎片、神灵精魄、海量元宝}\n","{flag;0}每天可领取3次任务,镖车护送路线：比奇城→土城\n","{flag;0}镖车已购保险: 成功押镖获得150%的收益(还可获得一份豪礼),失败获得100%的收益\n","{flag;0}镖车未购保险: 成功押镖获得100%的收益,失败获得50%的收益\n","{flag;0}有保险的镖车被劫将从保证金扣除200钻石(掉落在地上,任何人都可拾取)\n","{flag;0}未按时交镖(30分钟内)、镖车被劫、人物死亡、中途下线则算护送失败",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		CrossDartNpcDlg =
		{
			Condition =
			{
				"镖车品质: %s\n",
				"镖车保险: {color;ff00ff00;%s}",
			},
			buyStaus = {"未购","已购"},
			Desc = "{reward;%d;%d;%d;%d}",
			continueBtn = "{btn;0;继续押镖;%s;%s}",
			SubmitBtn = "{btn;0;交镖;%s;%s}",
		},
		EscortNpc =
		{
			id = 101,
			DeliveryId = 20,
		},
		CarterNpc =
		{
			id = 81,
			DeliveryId = 21,
		},
		CrossDartNpcId = 82,
		DartsSceneId =
		{
				[218] = {level = 250,circle = 0},
				[223] = {level = 250,circle = 0},
				[219] = {level = 250,circle = 0},
		},
		level = 250,
		tYBL = {id = 545, name = "运镖令", count = 1, yb = 98,},
		time = 1800,
		maxRefresh = 3,
		maxEscort = 3,
		insurance = 500,
		distance = {3, 7},
		tAwardPercent = {0.5, 1, 1, 1.5,},
		relivetime = 5,
		activitytime = 1800,
		failReturn = 300,
		onekeyConsume = 199,
		BoomerangPercent = 0.5,
		BoomerangCount = 3,
		Boomerang_title = "劫镖成功",
		Boomerang_desc ="恭喜您成功劫到{color;ffff0000;%s}玩家的镖车，额外获得{color;ffff0000;%s}玩家镖车的%d％奖励，请收纳！",
		BoomeRangFailTitle = "劫镖失败",
		BoomeRangFailDesc = "您劫镖次数达到最高不可以得劫镖奖励，请明天再来！",
		FailBackinsurance = 300,
		ActDouble = 2,
		movetoConsumes = {{type = 15, id = 0, count = 100,},},
		mail_title = "押镖失败",
		maid_desc = "{color;ffff0000;很遗憾您本次押镖失败了.}获得{color;ffde00ff;%d％收益}:%s另处50％系统收回",
		tBiaoche =
		{
			{
				id = 448,
				monName = Lang.EntityName.m448,
				color = "FFFFFF00",
				freshRate =  10000,
				Awards =
				{
{type = 0, id = 22, count = 5, quality = 0, strong = 0, bind = 1, param = 0,name = "等级直升丹碎片"},
{type = 0, id = 1660, count = 5, quality = 0, strong = 0, bind = 1, param = 0,name = "100神灵精魄"},
{type = 0, id = 266, count = 5, quality = 0, strong = 0, bind = 1, param = 0,name = "元宝袋(5W)"},
				},
				otherAwards =
				{
					--{type = 0, id = 1706, count = 1,  bind = 1,name = "檀木保险护送宝箱"},
				},
			},
			{
				id = 449,
				monName = Lang.EntityName.m449,
				color = "FFFFFF00",
				freshRate = 6000,
				Awards =
				{
{type = 0, id = 22, count = 10, quality = 0, strong = 0, bind = 1, param = 0,name = "等级直升丹碎片"},
{type = 0, id = 1660, count = 10, quality = 0, strong = 0, bind = 1, param = 0,name = "100神灵精魄"},
{type = 0, id = 266, count = 10, quality = 0, strong = 0, bind = 1, param = 0,name = "元宝袋(5W)"},
				},
				otherAwards =
				{
					--{type = 0, id = 1707, count = 1,  bind = 1,name = "青铜保险护送宝箱"},
				},
			},
			{
				id = 450,
				monName = Lang.EntityName.m450,
				color = "FFFFFF00",
				freshRate = 4500,
				Awards =
				{
{type = 0, id = 22, count = 15, quality = 0, strong = 0, bind = 1, param = 0,name = "等级直升丹碎片"},
{type = 0, id = 1660, count = 15, quality = 0, strong = 0, bind = 1, param = 0,name = "100神灵精魄"},
{type = 0, id = 266, count = 15, quality = 0, strong = 0, bind = 1, param = 0,name = "元宝袋(5W)"},
				},
				otherAwards =
				{
					--{type = 0, id = 1708, count = 1,  bind = 1,name = "白银保险护送宝箱"},
				},
			},
			{
				id = 451,
				monName = Lang.EntityName.m451,
				color = "FFFFFF00",
				freshRate = 3500,
				Awards =
				{
{type = 0, id = 22, count = 30, quality = 0, strong = 0, bind = 1, param = 0,name = "等级直升丹碎片"},
{type = 0, id = 1660, count = 30, quality = 0, strong = 0, bind = 1, param = 0,name = "100神灵精魄"},
{type = 0, id = 266, count = 30, quality = 0, strong = 0, bind = 1, param = 0,name = "元宝袋(5W)"},
				},
				otherAwards =
				{
					--{type = 0, id = 1709, count = 1,  bind = 1,name = "黄金保险护送宝箱"},
				},
			},
		},
		DartSetup =
		{
			succFollowDist = 8,
			actionTime = 10,
			CampDartStatusIdle = 0,
			CampDartStatusAccept = 1,
			CampDartStatusFinished = 2,
			CampDartStatusGotAward = 3,
			CampDartFailUnknown = 0,
			CampDartFailExpired = 1,
			CampDartFailObjDie=3,
			CampDartFailActorGiveUp=4,
			CampDartFailActorLogout=5,
			CampDartFailBeLoot = 6,
		},
		tDrop = {
			{ type = 0, id = 1475, value = 2000, str = "元宝", count = 10, strong = 0, quality = 0, bind = 1, ExpireTime = 90,},
			{ type = 0, id = 1476, value = 5000, str = "元宝", count = 10, strong = 0, quality = 0, bind = 1, ExpireTime = 90,},
			{ type = 0, id = 1478, value = 20000, str = "元宝", count = 1, strong = 0, quality = 0, bind = 1, ExpireTime = 90,},
		},
		buff = {
			{id = 110, name = "押镖buff",},
			{id = 108, type = 60, groupid = 109, value = 5, interval = 60, name = "无敌镖车", times = 1, timeOverlay = true},
		},
		RwData = {"多倍押送", "土城", "{moveto;20;我也要参加}"},
		Src = {sid = 218, x = 179, y = 114, snpcname = Lang.EntityName.n00081},
		Dest = {sceneid = 219, x = 30, y = 70, name = Lang.EntityName.n00082},
	},
	[9] =
	{
		id = 9,
		name = Lang.dayactivity.name0013,
		timeDesc = Lang.dayactivity.time0013,
		ruleDesc = Lang.dayactivity.rule0013,
		entrance = Lang.dayactivity.talk0013,
		desc = Lang.dayactivity.desc0013,
		rewardicon = "{reward;0;551;1}{reward;0;573;1}{reward;0;574;1}{reward;0;2871;1}",
		Delivery = "moveto,18",
		awardIcons =
			{
				{type = 0, id = 551, count = 1, bind = 0},
				{type = 0, id = 573, count = 1, bind = 0},
				{type = 0, id = 574, count = 1, bind = 0},
				{type = 0, id = 2871, count = 1, bind = 0},
			},
		trackArray = {"21:40:00", "22:10:00",},
--		tracktxt = "{color;FF00c0ff;当前波数: }{color;FF00c0ff;$value1$波}\n{color;FF00c0ff;下波时间: }{color;FF00c0ff;$array2$}\n{color;FF00c0ff;主要掉落: }<(iaward#3#1)><(iaward#4#1)><(iaward#5#1)>",
		activityCfg = "活动规则: \n1.根据行会成员对BOSS造成伤害获得行会积分进行排名,\n2.对BOSS最后一击的玩家可获得额外的奖励",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value7$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"21", "40", "22", "10",},
			},
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;加入任意行会}\n",
				"活动时间: {color;ff00ff00;21:40-20:10}\n",
			},
			dlgDesc =
			{
				"{flag;0}活动奖励：{color;ff00ff00;高转装备、高级宝石}\n",
				"{flag;0}需要{color;ff00ff00;加入行会玩家}均可参与活动,行会成员{color;ff00ff00;参与活动}均可获得奖励\n",
				"{flag;0}活动场景有{color;ff00ff00;1只大BOSS刷新},活动期间根据行会成员{color;ff00ff00;对BOSS造成伤害}获得行会积分进行排名\n",
				"{flag;0}夺冠的行会成员可获得{color;ff00ff00;丰富奖励},其余名次的行会成员均可获得参与奖\n",
				"{flag;0}活动期间有玩家或整个行会退出该地图,{color;ff00ff00;行会积分不会清空}\n",
				"{flag;0}{color;ff00ff00;对BOSS最后一击}的玩家可获得额外的奖励\n",
				"{flag;0}{color;ff00c0ff;PS:PK不增加PK值，死亡不掉落!}\n",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		RwData = {"行会BOSS", "土城", 97, 65, "{moveto;18;[我也要参加]}"},
		level = 250,
		activitytime = 1800,
		sceneId = 216,
		enterX = 29,
		enterY = 9,
		maxBuyBuffTms = 5,
		buffConsume = 100,
		buff = {id = 681, name = "鼓舞",},
		endTimeCD = 30,
		bossInfo =
		{
			{
				monId = 324,
				posX = 20,
				posY = 17,
				liveTime = 1800,
				refreshTime = 0,
			},
		},
		Awards =
		{
			bigAward =
			{
				mgrAward =
				{
					{type = 0, id = 2871, count = 2, quality = 0, strong = 0, bind = 1, param = 0},
				},
				memberAward =
				{
					{type = 0, id = 2870, count = 2, quality = 0, strong = 0, bind = 1, param = 0},
				},
			},
			jionAward =
			{
					{type = 0, id = 2869, count = 2, quality = 0, strong = 0, bind = 1, param = 0},
			},
			killAward =
			{
					{type = 0, id = 2868, count = 2, quality = 0, strong = 0, bind = 1, param = 0},
			},
		},
	},
	[10] = {
		id = 10,
		name = Lang.dayactivity.name0008,
		timeDesc = Lang.dayactivity.time0008,
		ruleDesc = Lang.dayactivity.rule0008,
		entrance = Lang.dayactivity.talk0008,
		desc = Lang.dayactivity.desc0008,
		rewardicon = "{reward;0;274;1}{reward;0;273;1}{reward;0;493;1}",
		Delivery = "moveto,17",
--		tracktxt = "{color;FF00c0ff;积分排行: }\n    第一名:{color;FF00c0ff;$value1$}  第二名:{color;FF00c0ff;$value2$}\n    第三名:{color;FF00c0ff;$value3$}  第四名:{color;FF00c0ff;$value4$}\n    第五名:{color;FF00c0ff;$value5$}  第六名:{color;FF00c0ff;$value6$}\n    第七名:{color;FF00c0ff;$value7$}  第八名:{color;FF00c0ff;$value8$}\n    第九名:{color;FF00c0ff;$value9$}  第十名:{color;FF00c0ff;$value10$}\n  我的积分:{color;FF00c0ff;$value11$}  我的排名:{color;FF00c0ff;$value12$}\n收益统计:\n    累计获得经验 x {color;FF00c0ff;$value13$}",
		activityCfg = "活动规则: \n1.进入场景随机分配至天人或嗜魂阵营\n2.击杀敌对阵营玩家、击杀BOSS怪物、活动场景内每3分钟可获得积分,积分排行前10名的奖励更丰富(离开活动场景积分清除)\n3.场景内每8秒可获得一次奖励,角色等级越高奖励越丰厚\n4.活动结束可通过与NPC对话领取奖励\n5.PK不增加PK值、死亡不掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value10$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"21", "10", "21", "30",},
			}
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上}\n",
				"活动时间: {color;ff00ff00;21:10-21:30(每日)}\n",
			},
			dlgDesc =
			{
				"{flag;0}活动奖励: {color;ff00ff00;魂珠碎片、护盾碎片、元宝}\n",
				"{flag;0}进入场景随机分配至{color;ff00ff00;天人}或{color;ff00ff00;嗜魂}阵营\n",
				"{flag;0}{color;ff00ff00;击杀敌对阵营玩家}、{color;ff00ff00;击杀BOSS怪物}、{color;ff00ff00;活动场景内每3分钟}可获得积分,\n   积分排行{color;ff00ff00;前10名}的奖励更丰富{color;ffff0000;(离开活动场景积分清除)}\n",
				"{flag;0}活动场景内的玩家{color;ff00ff00;每8秒可获得一次奖励},角色等级越高经验越高\n",
				"{flag;0}活动结束可通过与{color;ff00ff00;NPC对话领取奖励}\n",
				"{flag;0}{color;ff00c0ff;PS: PK不增加PK值、死亡不掉落}",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
			awardBtn = "{btn;0;领取奖励;%s;%s}",
		},
		level = 250,
		killPlyNum = 100,
		PaoDianTimeInterval = 8,
		sceneId = 220,
		activitytime = 1200,
		titleAward = {type = 0, id = 1684,count = 1,bind = 1},
		mail_title ="万人斩",
		mail_desc = " 恭喜您在阵营战总击杀了%d个玩家，荣获得万人斩称号，望你再接再厉！！",
		notice = "恭喜%s在阵营战总击杀了%d个玩家，荣获得万人斩称号",
		rankname = "BuLuoDaZhanActRanking.txt",
		pdAward =
		{
			{minlv = 250, maxlv = 399, wards = {{type=2, id=0, count=10000},},},
			{minlv = 400, maxlv = 499, wards = {{type=2, id=0, count=20000},},},
			{minlv = 500, maxlv = 799, wards = {{type=2, id=0, count=50000},},},
			{minlv = 800, maxlv = -1, wards = {{type=2, id=0, count=100000},},},
		},
		chuanSongIdx = 17,
		RwData = {"阵营战", "荒漠土城", 94, 53, "{moveto;20;[我也要参加]}"},
	},
	[11] =
	{
		id = 11,
		name = Lang.dayactivity.name00014,
		timeDesc = Lang.dayactivity.time00014,
		ruleDesc = Lang.dayactivity.rule00014,
		entrance = Lang.dayactivity.talk00014,
		desc = Lang.dayactivity.desc00014,
		rewardicon = "{reward;0;555;1}{reward;0;581;1}{reward;0;2053;1}{reward;0;479;1}",
		Delivery = "moveto,19",
		awardIcons =
			{
				{type = 0, id = 555, count = 1, bind = 0},
				{type = 0, id = 581, count = 1, bind = 0},
				{type = 0, id = 2053, count = 1, bind = 0},
				{type = 0, id = 479, count = 1, bind = 0},
			},
		trackArray = {"11:30:00", "12:00:00",},
		activityCfg = "活动规则: \n1.根据行会成员对BOSS造成伤害获得积分进行排名,\n2.对BOSS最后一击的玩家可获得额外的奖励",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value7$}",
		tOpenTime = {
			weeks={0},
			times = {
				{"15", "15", "15", "45",},
			},
		},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;250级以上}\n",
				"活动时间: {color;ff00ff00;15:15-15:45}\n",
			},
			dlgDesc =
			{
				"{flag;0}活动奖励：{color;ff00ff00;高转基础装、战神神石、圣兽丹}\n",
				"{flag;0}活动期间根据{color;ff00ff00;玩家对BOSS造成伤害}获得积分进行排名\n",
				"{flag;0}{color;ff00ff00;前十名玩家}可获得丰富奖励,其余名次的行会成员均可获得参与奖\n",
				"{flag;0}活动期间有玩家退出该场景,{color;ff00ff00;积分会清空，重新计算}\n",
				"{flag;0}{color;ff00ff00;对BOSS最后一击}的玩家可获得额外的奖励并激活 {color;ff00ff00;屠龙勇士} 称号\n",
				"{flag;0}{color;ff00c0ff;PS:PK不增加PK值,死亡不掉落!}\n",
			},
			enterBtn = "{btn;0;参加活动;%s;%s}",
		},
		RwData = {"世界boss", "土城", 103, 65, "{moveto;19;[我也要参加]}"},
		level = 250,
		activitytime = 1800,
		npcID = 99,
		sceneId = 221,
		enterPos = { x = 63,y = 19},
		chuanSongIdx = 17,
		bossDieKickTimes = 30,
		bossDieNotice = "请大家%d秒内不要退出活动,等候发奖励!",
		killbosstip = "恭喜{color;ffFFFAF0;%s}在击杀{color;ff00BFFF;世界boss}打出{color;ffFF0000;最后一击}将{color;ff00FF00;世界BOSS终结了}，获得丰富奖励！！",
		firstTip = "恭喜{color;ffFFFAF0;%s}在{color;ff00BFFF;世界boss伤害积分}获得{color;ffFF0000;第一名次}，获得丰富奖励！",
		rankname = "WorldBossActRanking.txt",
		buyRankName = "WorldBossActBuy.txt",
		buyInfo =
		{
			limit = 5,
			needYb = 100,
			buff = {id = 681, name = "鼓舞",},
		},
		bossInfo = {
				monId = 325,
				posX = 20,
				posY = 26,
				liveTime = 1800,
				refreshTime = 0,
		},
		Awards =
		{
			rankAward =
			{
				mail_title = "世界boss",
				mail_desc = "恭喜您在世界boss伤害积分获得第%d名次，请您再接再厉！以下是奖励，敬请收纳！",
				award =
				{
					{
						{type = 0, id = 2053, count = 100,  bind = 1},
						{type = 0, id = 2842, count = 50,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 80,  bind = 1},
						{type = 0, id = 2842, count = 40,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 60,  bind = 1},
						{type = 0, id = 2842, count = 30,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 45,  bind = 1},
						{type = 0, id = 2842, count = 20,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 30,  bind = 1},
						{type = 0, id = 2842, count = 20,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 15,  bind = 1},
						{type = 0, id = 2842, count = 10,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 12,  bind = 1},
						{type = 0, id = 2842, count = 10,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 10,  bind = 1},
						{type = 0, id = 2842, count = 10,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 8,  bind = 1},
						{type = 0, id = 2842, count = 10,  bind = 1},
					},
					{
						{type = 0, id = 2053, count = 5,  bind = 1},
						{type = 0, id = 2842, count = 10,  bind = 1},
					},
				},
			},
			jionAward =
			{
				mail_title = "世界boss",
				mail_desc = "恭喜您在世界boss活动中获得参与奖，请您再接再厉！以下是奖励，敬请收纳！",
				award =
				{
						{type = 0, id = 2053, count = 2,  bind = 1},
						{type = 0, id = 2842, count = 5,  bind = 1},
				},
			},
			killAward =
			{
				titleId = 51,
				mail_title = "世界boss",
				mail_desc = "恭喜您在击杀世界boss打出最后一击将世界超级BOSS终结了，获得额外奖励！以下是奖励，敬请收纳！",
				award =
				{
						{type = 0, id = 2053, count = 50,  bind = 1},
						{type = 0, id = 2842, count = 50,  bind = 1},
				},
			},
		},
	},
}