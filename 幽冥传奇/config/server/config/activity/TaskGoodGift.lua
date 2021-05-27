
TaskGoodGiftConfig =
{
	openlimitLevel = 280,
	FirstEffect = 10050,
	task =
	{
		{
			name = "海量钻石任务",
			ItemEffect = 10050,
			list =
			{
{type = 0,param = 0,targetTimes = 1,title = "提升转生",desc="转生到达1转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=15, id=0, count=200,bind=1},},},
{type = 1,param = 0,targetTimes = 1,title = "加入行会",desc="加入一个行会",view_def = "Guild",npcid = nil,award = {{type=15, id=0, count=200,bind=1},},},
{type = 2,param = 0,targetTimes = 5,title = "探索宝藏",desc="寻宝5次",view_def = "Explore",npcid = nil,award = {{type=15, id=0, count=500,bind=1},},},
{type = 3,param = 0,targetTimes = 1,title = "商城限购",desc="限购商城买一个道具",view_def = "Shop#Bind_yuan",npcid = nil,award = {{type=15, id=0, count=500,bind=1},},},
{type = 4,param = 200,targetTimes = 2,title = "击杀BOSS",desc="击杀200级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=15, id=0, count=200,bind=1},},},
{type = 4,param = 300,targetTimes = 2,title = "击杀BOSS",desc="击杀300级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=15, id=0, count=200,bind=1},},},
{type = 4,param = 400,targetTimes = 2,title = "击杀BOSS",desc="击杀400级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=15, id=0, count=500,bind=1},},},
{type = 5,param = 1,targetTimes = 2,title = "穿戴转生装备",desc="穿戴1转以上的装备2件",view_def = "Role",npcid = nil,award = {{type=15, id=0, count=500,bind=1},},},
			},
			awards =
			{
				{type=15, id=495, sex=0,count=500,bind=0},{type=15, id=495,sex=1, count=2500,bind=0},
			},
		},
		{
			name = "热血鞋子任务",
			ItemEffect = 117,
			list =
			{
{type = 0,param = 0,targetTimes = 2,title = "提升转生",desc="转生达到2转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=2053, count=5,bind=1},},},
{type = 6,param = 0,targetTimes = 1,title = "成为VIP",desc="次日登录/达成vip3",view_def = "Vip",npcid = nil,condition = 2,condition1 = 3,award = {{type=0, id=2053, count=5,bind=1},},},
{type = 2,param = 0,targetTimes = 25,title = "探索宝藏",desc="寻宝25次",view_def = "Explore",npcid = nil,award = {{type=0, id=2053, count=10,bind=1},},},
{type = 7,param = 0,targetTimes = 20,title = "试炼关卡",desc="练功房通关第1章第20关",view_def = "Experiment",npcid = nil,award = {{type=0, id=2053, count=10,bind=1},},},
{type = 4,param = 500,targetTimes = 2,title = "击杀BOSS",desc="击杀500级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=2053, count=2,bind=1},},},
{type = 4,param = 600,targetTimes = 3,title = "击杀BOSS",desc="击杀600级以上boss3次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=2053, count=3,bind=1},},},
{type = 8,param = 312,targetTimes = 2,title = "挑战转生BOSS",desc="击杀2转boss2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=2053, count=5,bind=1},},},
{type = 5,param = 1,targetTimes = 5,title = "穿戴转生装备",desc="穿戴1转以上的装备5件",view_def = "Role",npcid = nil,award = {{type=0, id=2053, count=10,bind=1},},},
			},
			awards =
			{
				{type=0, id=1901, sex=0,count=1,bind=0},{type=0, id=1901,sex=1, count=1,bind=0},
			},
		},
		{
			name = "神圣特戒任务",
			ItemEffect = 344,
			list =
			{
{type = 0,param = 0,targetTimes = 3,title = "提升转生",desc="转生达到3转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=2057, count=5,bind=1},},},
{type = 9,param = 0,targetTimes = 3,title = "穿戴热血装备",desc="穿戴3件热血装备",view_def = "Role#RoleInfoList#NewReXueEquip",npcid = nil,award = {{type=0, id=2057, count=5,bind=1},},},
{type = 2,param = 0,targetTimes = 50,title = "探索宝藏",desc="寻宝50次",view_def = "Explore",npcid = nil,award = {{type=0, id=2057, count=50,bind=1},},},
{type = 7,param = 0,targetTimes = 40,title = "试炼关卡",desc="练功房通关第2章第20关",view_def = "Experiment",npcid = nil,award = {{type=0, id=2057, count=8,bind=1},},},
{type = 4,param = 700,targetTimes = 2,title = "击杀BOSS",desc="击杀700级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=2057, count=3,bind=1},},},
{type = 4,param = 800,targetTimes = 2,title = "击杀BOSS",desc="击杀800级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=2057, count=3,bind=1},},},
{type = 8,param = 313,targetTimes = 2,title = "挑战转生BOSS",desc="击杀转生boss3转2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=2057, count=3,bind=1},},},
{type = 5,param = 3,targetTimes = 2,title = "穿戴转生装备",desc="穿戴3转以上的装备2件",view_def = "Role",npcid = nil,award = {{type=0, id=2057, count=5,bind=1},},},
			},
			awards =
			{
				{type=0, id=1580, sex=0,count=1,bind=0},{type=0, id=1580,sex=1, count=1,bind=0},
			},
		},
		{
			name = "灭霸手套任务",
			ItemEffect = 1071,
			list =
			{
{type = 0,param = 0,targetTimes = 4,title = "提升转生",desc="转生达到4转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=306, count=5,bind=1},},},
{type = 9,param = 0,targetTimes = 5,title = "穿戴热血装备",desc="穿戴5件热血装备",view_def = "Role#RoleInfoList#NewReXueEquip",npcid = nil,award = {{type=0, id=308, count=2,bind=1},},},
{type = 2,param = 0,targetTimes = 100,title = "探索宝藏",desc="寻宝100次",view_def = "Explore",npcid = nil,award = {{type=0, id=310, count=2,bind=1},},},
{type = 7,param = 0,targetTimes = 60,title = "试炼关卡",desc="练功房通关第3章第20关",view_def = "Experiment",npcid = nil,award = {{type=0, id=309, count=5,bind=1},},},
{type = 4,param = 900,targetTimes = 2,title = "击杀BOSS",desc="击杀900级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=306, count=5,bind=1},},},
{type = 4,param = 1000,targetTimes = 2,title = "击杀BOSS",desc="击杀1000级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=306, count=5,bind=1},},},
{type = 8,param = 314,targetTimes = 2,title = "挑战转生BOSS",desc="击杀4转boss2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=307, count=10,bind=1},},},
{type = 5,param = 3,targetTimes = 5,title = "穿戴转生装备",desc="穿戴3转以上的装备5件",view_def = "Role",npcid = nil,award = {{type=0, id=308, count=2,bind=1},},},
			},
			awards =
			{
				{type=0, id=299, sex=0,count=1,bind=0},{type=0, id=299,sex=1, count=1,bind=0},
			},
		},
		{
			name = "热血神甲任务",
			ItemEffect = 111,
			list =
			{
{type = 0,param = 0,targetTimes = 5,title = "提升转生",desc="转生达到5转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 9,param = 0,targetTimes = 8,title = "穿戴热血装备",desc="穿戴8件热血装备",view_def = "Role#RoleInfoList#NewReXueEquip",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 2,param = 0,targetTimes = 150,title = "探索宝藏",desc="寻宝150次",view_def = "Explore",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 10,param = 0,targetTimes = 5,title = "提升翅膀",desc="翅膀达到5阶",view_def = "Wing",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 4,param = 1100,targetTimes = 2,title = "击杀BOSS",desc="击杀1100级以上boss2次",view_def = "NewlyBossView",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 11,param = 855,targetTimes = 2,title = "挑战专属BOSS",desc="击杀vip4专属boss2次",view_def = "NewlyBossView#Wild#Specially",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 8,param = 315,targetTimes = 2,title = "挑战转生BOSS",desc="击杀5转boss2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
{type = 8,param = 239,targetTimes = 2,title = "挑战星魂BOSS",desc="击杀星魂600级boss2次",view_def = "NewlyBossView#Rare#XhBoss",npcid = nil,award = {{type=0, id=2052, count=8,bind=1},},},
			},
			awards =
			{
				{type=0, id=1713, sex=0,count=1,bind=0},{type=0, id=1716,sex=1, count=1,bind=0},
			},
		},
		{
			name = "热血神兵任务",
			ItemEffect = 110,
			list =
			{
{type = 0,param = 0,targetTimes = 6,title = "提升转生",desc="转生达到6转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 9,param = 0,targetTimes = 10,title = "穿戴热血装备",desc="穿戴10件热血装备",view_def = "Role#RoleInfoList#NewReXueEquip",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 2,param = 0,targetTimes = 200,title = "探索宝藏",desc="寻宝200次",view_def = "Explore",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 10,param = 0,targetTimes = 7,title = "提升翅膀",desc="翅膀达到7阶",view_def = "Wing",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 11,param = 272,targetTimes = 1,title = "挑战龙皇秘境",desc="击杀龙皇·千年魅狐王1次",view_def = "NewlyBossView#Rare#MiJing",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 11,param = 857,targetTimes = 2,title = "挑战专属BOSS",desc="击杀vip6专属boss2次",view_def = "NewlyBossView#Wild#Specially",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 8,param = 316,targetTimes = 2,title = "挑战转生BOSS",desc="击杀6转boss2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
{type = 8,param = 304,targetTimes = 2,title = "挑战星魂BOSS",desc="击杀星魂700级boss2次",view_def = "NewlyBossView#Rare#XhBoss",npcid = nil,award = {{type=0, id=2051, count=8,bind=1},},},
			},
			awards =
			{
				{type=0, id=1710, sex=0,count=1,bind=0},{type=0, id=1710,sex=1, count=1,bind=0},
			},
		},
--			name = "魔幻影翼任务",
--{type = 0,param = 0,targetTimes = 7,title = "提升转生",desc="转生达到7转",view_def = "Role#ZhuanSheng",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 9,param = 0,targetTimes = 12,title = "穿戴热血装备",desc="穿戴12件热血装备",view_def = "Role#RoleInfoList#NewReXueEquip",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 2,param = 0,targetTimes = 300,title = "探索宝藏",desc="寻宝300次",view_def = "Explore",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 10,param = 0,targetTimes = 28,title = "提升翅膀",desc="翅膀达到10阶",view_def = "Wing",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 11,param = 278,targetTimes = 1,title = "挑战龙皇BOSS",desc="击杀龙皇秘境2600级boss1次",view_def = "Explore#Rareplace",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 11,param = 859,targetTimes = 2,title = "挑战专属BOSS",desc="击杀vip8专属boss2次",view_def = "NewlyBossView#Wild#Specially",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 8,param = 316,targetTimes = 2,title = "挑战转生BOSS",desc="击杀7转boss2次",view_def = "NewlyBossView#Wild#CircleBoss",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
--{type = 8,param = 305,targetTimes = 2,title = "挑战星魂BOSS",desc="击杀星魂800级boss2次",view_def = "NewlyBossView#Rare#XhBoss",npcid = nil,award = {{type=0, id=342, count=12,bind=1},},},
	},
}