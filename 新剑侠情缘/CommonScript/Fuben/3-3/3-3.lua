
local tbFubenSetting = {};
Fuben:SetFubenSetting(32, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {4338, 1195}											-- 副本出生点
tbFubenSetting.nStartDir				= 42;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 789,			nLevel = 22, nSeries = -1},  --飞龙堡弟子 
	[2] = {nTemplate = 524,			nLevel = 23, nSeries = -1},  --神射手
	[3] = {nTemplate = 790,			nLevel = 24, nSeries = -1},  --飞龙堡护法
	[4] = {nTemplate = 778,			nLevel = 24, nSeries = 0},  --月眉儿
	[5] = {nTemplate = 684,			nLevel = 24, nSeries = 0},  --杨影枫

	[6] = {nTemplate = 104,			nLevel = -1, nSeries = 0},  --动态障碍墙

	[12] = {nTemplate = 764,		nLevel = 24, nSeries = 0},		--纳兰真
}

--是否允许同伴出战
-- tbFubenSetting.bForbidPartner = true;
-- tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1033, false},	
			--{"AddNpc", 5, 1, 3, "Start_Npc1", "Start_Npc1", 1, 48, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 16},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"AddNpc", 6, 2, 0, "wall1", "wall_1_1",false, 45},
			{"SetTargetPos", 3937, 1138},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 4, 3, "guaiwu1", "Stage_1_1", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 4, 3, "guaiwu", "Stage_1_2", 1, 0, 3, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "你总算是来了！准备好受死吧！！", 4, 1, 1},
			{"BlackMsg", "没想到这里竟会有埋伏！"},	
		},
	},
	[3] = {nTime = 0, nNum = 8,
		tbPrelock = {2},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 1, 5, 4, "guaiwu1", "Stage_1_3", 1, 0, 0, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "你已是瓮中之鳖！还不乖乖束手就擒！", 4, 1, 1},
		},
	},
	[4] = {nTime = 0, nNum = 5,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall1"},
			{"AddNpc", 6, 2, 0, "wall2", "wall_1_2",false, 16},
			{"SetTargetPos", 1378, 1651},
			{"RaiseEvent", "PartnerSay", "没想到飞龙堡还安排了伏兵...", 4, 1},
			--{"NpcBubbleTalk", "Start_Npc1", "没想到这里竟会有飞龙堡的伏兵...", 4, 0, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 5},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 1, 6, "guaiwu", "Stage_2_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 6, "guaiwu", "Stage_2_2", 1, 0, 0.5, 0, 0},
			{"AddNpc", 2, 1, 6, "guaiwu", "Stage_2_3", 1, 0, 1, 0, 0},
			{"AddNpc", 2, 1, 6, "guaiwu", "Stage_2_4", 1, 0, 1.5, 0, 0},
		},
	},
	[6] = {nTime = 0, nNum = 4,
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "ops2"},
			{"SetTargetPos", 1551, 2931},
			{"AddNpc", 6, 1, 0, "wall3", "wall_1_3",false, 28},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 7},
			{"AddNpc", 1, 2, 8, "guaiwu2", "Stage_3_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 8, "guaiwu", "Stage_3_2", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8, "guaiwu", "Stage_3_3", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 4, 8, "guaiwu", "Stage_3_4", 1, 0, 3, 9008, 0.5},
			{"AddNpc", 2, 3, 8, "guaiwu", "Stage_3_5", 1, 0, 5, 0, 0},
		},
	},
	[8] = {nTime = 0, nNum = 12,
		tbPrelock = {6},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			--{"NpcBubbleTalk", "Start_Npc1", "月眉儿就在前方！", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "月眉儿应该就在前方！", 4, 1},
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "ops3"},
			{"OpenDynamicObstacle", "ops4"},
			{"SetTargetPos", 1808, 4228},

			{"AddNpc", 5, 1, 3, "Start_Npc1", "yangyingfeng", false, 24, 0, 0, 0},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"AddNpc", 4, 1, 0, "BOSS", "Stage_4_BOSS", false, 56, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetAiActive", "BOSS", 0},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 9},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetTargetPos", 3993, 3794},	
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 10},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PauseLock", 16},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 11, 1034, false},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", false},
			--{"ChangeNpcAi", "Start_Npc1", "Move", "path1", 0, 1, 1, 0, 0},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowPartnerAndHelper", true},
			{"RaiseEvent", "CloseDynamicObstacle", "ops3"},	
			{"AddNpc", 6, 1, 0, "wall3", "wall_1_3",false, 28},
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "Start_Npc1", true, 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"ChangeNpcFightState", "BOSS", 1, 0},
			{"SetAiActive", "BOSS", 1},
			{"RaiseEvent", "CloseDynamicObstacle", "ops3"},	
			{"NpcBubbleTalk", "BOSS", "杨影枫，有本事你就杀了我替纳兰真报仇吧！", 4, 2, 1},
			{"NpcBubbleTalk", "Start_Npc1", "月眉儿，你......", 4, 4, 1},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "BOSS", 12, 30},
		},
		tbUnLockEvent = 
		{
			--{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
		},
	},
	-- [13] = {nTime = 2.1, nNum = 0,
	-- 	tbPrelock = {12},
	-- 	tbStartEvent = 
	-- 	{
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"SetGameWorldScale", 1},		-- 慢镜头结束
	-- 	},
	-- },
	[14] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},		--需要月眉儿重伤动作
			{"DoCommonAct", "BOSS", 36, 0, 1, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"SetAiActive", "Start_Npc1", 0},
		},
		tbUnLockEvent = 
		{			
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1035, false},					
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 300, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "RegisterTimeoutLock"},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
-------------------------结束剧情-------------------------
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 0, 1, 4125, 3426, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"RaiseEvent", "ShowPlayer", false},

			{"AddNpc", 12, 1, 0, "npc", "nalanzhen", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc", "Move", "path2", 17, 1, 1, 0, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc", "不要啊！影枫哥！", 3, 0, 1},
			{"SetAiActive", "npc", 0},
			{"ChangeNpcFightState", "npc", 0, 0},
			{"ChangeNpcFightState", "Start_Npc1", 0, 0},
			{"SetAiActive", "Start_Npc1", 1},
			{"ChangeNpcAi", "Start_Npc1", "Move", "path3", 18, 1, 1, 0, 0},
			{"NpcBubbleTalk", "Start_Npc1", "真儿！", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 13, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"SetAiActive", "Start_Npc1", 0},
			{"NpcBubbleTalk", "Start_Npc1", "真儿！原来你没死！", 3, 1, 1},
			{"NpcBubbleTalk", "npc", "影枫哥！你为什么要杀月姑娘？", 3, 3, 1},
			{"NpcBubbleTalk", "Start_Npc1", "真儿！不是她把你绑架了吗？", 3, 5, 1},
			{"NpcBubbleTalk", "npc", "影枫哥！你太糊涂了……", 3, 7, 1},
			{"NpcBubbleTalk", "Start_Npc1", "真儿！这到底是怎么回事？", 3, 9, 1},
			{"NpcBubbleTalk", "BOSS", "咳咳...", 3, 10, 1},
			{"NpcBubbleTalk", "npc", "先别说了，把月姑娘带回悲魔山庄救治要紧！", 3, 11, 1},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"GameWin"},
		},
	},



}
