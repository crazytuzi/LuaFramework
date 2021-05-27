
BaoZangShangRenCfg =
{
			id = 14,
		name = Lang.dayactivity.name0014,
		timeDesc = Lang.dayactivity.time0014,
		ruleDesc = Lang.dayactivity.rule0014,
		entrance = Lang.dayactivity.talk0014,
		desc = Lang.dayactivity.desc0014,
		rewardicon = "{reward;0;2036;1}{reward;0;862;1}{reward;0;843;1}{reward;0;836;1}",
		Delivery = "moveto,28",
		-- tracktxt = "{color;FFff0000;$value1$/$value2$}\n{color;FF00c0ff;活动奖励:}\n    <(iaward#4#1)><(iaward#5#1)><(iaward#6#1)>",
		activityCfg = "1.击杀BOSS拾取龙魂宝箱，将获得持宝人称号，并每8秒获得1次丰厚奖励；\n2.持宝人死亡或者下线，宝箱都会掉落在地上，其他人可随意拾取；\n3.活动结束，持宝人可获得一个龙魂宝箱，开启获得大量斗笠结晶；\n4.活动场景内的玩家每8秒可获得一次奖励；\n5.活动地图内PK不增加PK值、死亡不掉落",
		residuetime = "{color;FFff0000;剩余时间: }{color;FFff0000;$value14$}",
		tOpenTime =
		{
			weeks={1,3,5,7},
			times =
			{
				{"21", "05", "21", "25",},
			}
		},
		tScene = {"荒漠土城", 61, 61,},
		NpcDlg =
		{
			enterCond =
			{
				"等级限制: {color;ff00ff00;70级以上\n}",
				"活动时间: {color;ff00ff00;08:00-24:00}\n",
				"剩余次数: {color;ff00ff00;%d}",
			},
			dlgDesc =
			{
                "{flag;1}活动期间花费1000元宝购买藏宝图进行宝藏挖掘{color;ff00ff00;挖掘必须到达指定地图和坐标};\n",
				"{flag;1}活动奖励: {color;ff00ff00;各种装备和材料、引诱出隐藏BOSS、发现隐藏的秘境\n}",
				"{flag;1}{color;ff00c0ff;PS:隐藏秘境很危险,进入需要慎重！\n}",
				"{flag;1}{color;ff00c0ff;PS:释放出的BOSS只有2小时存在时限\n}",
				"{flag;1}{color;ff00c0ff;PS:可以使用行会召集令召唤帮众一起群殴BOSS.}",
			},
			buyOneBtn = "{btn;0;购买一张;%s;%s}",
			buyTenBtn = "{btn;0;购买十张;%s;%s}",
		},
		sceneid = {2,3,4},
		point = {
			[2] = {{14,22},{19,60},{18,60},{69,108}},
			[3] = {{92,50},{86,8}},
			[4] = {{53,94},{69,78},{11,51},{41,24},{52,50},{85,48}},
		},
		canBuyCBTTime = 100,
		itemId = 2557,
		consumYb = 1000,
		time = {8,24},
		treasure = {
			{id = 1, rate = 5000,},
			{id = 2, rate = 8500,},
			{id = 3, rate = 10000,},
		},
		awards =
		{
{type=0,id=835,count=10,bind=1,rate=600,name="金龟召唤令牌",prompt=0,},	--"金龟召唤令牌"
{type=0,id=2548,count=1,bind=0,rate=1600,name="1888摸金铲",prompt=1,},	--"1888摸金铲"
{type=0,id=558,count=10,bind=1,rate=2500,name="神秘锦囊",prompt=0,},	--"神秘锦囊"
{type=0,id=677,count=2,bind=1,rate=3300,name="超级金币箱",prompt=1,},	--"超级金币箱"
{type=0,id=850,count=1,bind=1,rate=3800,name="三倍经验(4小时)",prompt=1,},	--"三倍经验(4小时)"
{type=0,id=853,count=1,bind=1,rate=4300,name="四倍经验(3小时)",prompt=1,},	--"四倍经验(3小时)"
{type=0,id=17,count=1,bind=0,rate=5300,name="裂天战刀",prompt=0,},	--"裂天战刀"
{type=0,id=18,count=1,bind=0,rate=6300,name="裂天魔杖",prompt=0,},	--"裂天魔杖"
{type=0,id=19,count=1,bind=0,rate=7300,name="裂天道剑",prompt=0,},	--"裂天道剑"
{type=0,id=20,count=1,bind=0,rate=7600,name="真武战刃",prompt=1,},	--"真武战刃"
{type=0,id=21,count=1,bind=0,rate=7900,name="真武权杖",prompt=1,},	--"真武权杖"
{type=0,id=22,count=1,bind=0,rate=8200,name="真武宝剑",prompt=1,},	--"真武宝剑"
{type=0,id=23,count=1,bind=0,rate=8400,name="圣武战刃",prompt=1,},	--"圣武战刃"
{type=0,id=24,count=1,bind=0,rate=8600,name="圣武权杖",prompt=1,},	--"圣武权杖"
{type=0,id=25,count=1,bind=0,rate=8800,name="圣武宝剑",prompt=1,},	--"圣武宝剑"
{type=0,id=646,count=1,bind=0,rate=9200,name="太初灵镜",prompt=1,},	--"太初灵镜"
{type=0,id=656,count=1,bind=0,rate=9600,name="太初铃铛",prompt=1,},	--"太初铃铛"
{type=0,id=666,count=1,bind=0,rate=10000,name="太初圣笛",prompt=1,},	--"太初圣笛"
		},
		monsterId = {
			{id = 992,rate = 6000,name = "藏.猪王",},
			{id = 996,rate = 8000,name = "藏.魔窟教主",},
			{id = 1002,rate = 10000,name = "藏.神殿魔王",},
		},
		monsterLiveTime = 7200,
		teleportId = {
			{toSceneid =  194,toPosx = 15, toPosy = 17,name = Lang.SceneName.s00002,rate = 3000},
			{toSceneid =  195,toPosx = 14, toPosy = 55,name = Lang.SceneName.s00003,rate = 6000},
			{toSceneid =  196,toPosx = 77, toPosy = 20,name = Lang.SceneName.s00004,rate = 10000},
		},
		limitLevel = 70,
		exitInfo = {2,62,70},
}