
local tbFubenSetting = {};
Fuben:SetFubenSetting(61, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/8_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/8_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/8_2/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2035, 5427}											-- 副本出生点
tbFubenSetting.nStartDir				= 48;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1919,	nLevel = -1,	nSeries = -1},	--山贼
	[2] = {nTemplate = 1920,	nLevel = -1,	nSeries = -1},	--山贼精英
	[3] = {nTemplate = 1921,	nLevel = -1,	nSeries = -1},	--顾武--头目
	[4] = {nTemplate = 2533,	nLevel = -1,	nSeries = -1},	--山贼巡卫
	[5] = {nTemplate = 2534,	nLevel = -1,	nSeries = -1},	--山贼头目
	[6] = {nTemplate = 2653,	nLevel = -1,	nSeries = 0},	--怒气机关
	[7] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
}
tbFubenSetting.bForbidPartner = true;
tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ChangeAutoFight", false},	
			{"MoveCameraToPosition", 1, 4, 1557, 1338, 10},
			{"SetAllUiVisiable", false}, 		
			{"SetForbiddenOperation", true},

			{"AddNpc", 4, 1, 34, "Patrol_1", "Stage_1_1", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 34, "Patrol_2", "Stage_1_2", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 34, "Patrol_3", "Stage_1_3", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 34, "Patrol_4", "Stage_1_4", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 43, "Patrol_5", "Stage_1_5", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 43, "Patrol_6", "Stage_1_6", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 43, "Patrol_7", "Stage_1_7", 1, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "toumu", "toumu", 1, 0, 0, 0, 0},


			{"ChangeNpcAi", "Patrol_1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_2", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_4", "Move", "Path4", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_5", "Move", "Path5", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_6", "Move", "Path6", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_7", "Move", "Path7", 0, 1, 1, 0, 1},

			{"NpcFindEnemyUnlock", "Patrol_1", 30, 0},
			{"NpcFindEnemyUnlock", "Patrol_2", 31, 0},
			{"NpcFindEnemyUnlock", "Patrol_3", 32, 0},
			{"NpcFindEnemyUnlock", "Patrol_4", 33, 0},
			{"NpcFindEnemyUnlock", "Patrol_5", 40, 0},
			{"NpcFindEnemyUnlock", "Patrol_6", 41, 0},
			{"NpcFindEnemyUnlock", "Patrol_7", 42, 0},
			--{"NpcFindEnemyUnlock", "toumu", 50, 0},

			{"NpcAddBuff", "Patrol_1", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_2", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_3", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_4", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_5", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_6", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_7", 2402, 1, 300},
			{"NpcAddBuff", "toumu", 2403, 1, 300}, 
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"LeaveAnimationState", false},
			{"DoCommonAct", "toumu", 36, 10002, 1, 0},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 2, 1121, false},
		},
		tbUnLockEvent = 
		{
			{"SetShowTime", 3},
			{"SetAllUiVisiable", true}, 
			{"BlackMsg", "前方有山贼巡逻，注意别被发现！"},
		},
	},
	[3] = {nTime = 600, nNum = 0,
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
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {{51,52}},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap4", 4},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 8, 0, "gw1", "guaiwu1", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 2, 2, 0, "gw2", "guaiwu2", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 3, 1, 5, "sl", "shouling", false, 32, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "sl", "我的大刀早已饥渴难耐了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw1", "知不知道这是什么地方？！", 4, 1, 1},
			{"NpcBubbleTalk", "gw2", "跪下求饶，爷爷们饶你一命！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 2.1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"DoDeath", "gw1"},
			{"DoDeath", "gw2"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
------第一区巡逻设置--------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_1", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_1", 28, 10, -1, -1},
			{"CloseLock", 31, 33},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_2", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_2", 28, 10, -1, -1},
			{"CloseLock", 32, 33},
			{"CloseLock", 30},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_3", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_3", 28, 10, -1, -1},
			{"CloseLock", 30, 31},
			{"CloseLock", 33},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_4", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_4", 28, 10, -1, -1},
			{"CloseLock", 30, 32},
		},
	},
	[34] = {nTime = 0, nNum = 20,
		tbPrelock = {{30, 31, 32, 33}},
		tbStartEvent = 
		{
			{"CloseLock", 35},

			{"SetNpcAi", "Patrol_1", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_2", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_3", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_4", "Setting/Npc/Ai/CommonActive4.ini"},

			{"AddNpc", 7, 2, 0, "wall", "wall_1",false, 26},
			{"NpcRemoveBuff", "Patrol_1", 2402},
			{"NpcRemoveBuff", "Patrol_2", 2402},
			{"NpcRemoveBuff", "Patrol_3", 2402},
			{"NpcRemoveBuff", "Patrol_4", 2402},
			{"SetNpcRange", "Patrol_1", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_2", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_3", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_4", 5000, 5000, 2},

			{"BlackMsg", "你被发现了，惊动了大批山贼！"},
			{"AddNpc", 2, 2, 34, "guaiwu2", "guaiwu4", 1, 0, 1.5, 9011, 1},
			{"AddNpc", 1, 14, 34, "guaiwu1", "guaiwu3", 1, 0, 2, 0, 0},
			{"NpcBubbleTalk", "guaiwu2", "活得不耐烦了，这里都敢闯！！", 5, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs0"},
			{"SetTargetPos", 3621, 1597},
			{"DoDeath", "wall"},
			{"BlackMsg", "这里居然藏了这么多山贼，真是凶险异常"},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	[35] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"TrapUnlock", "trap1", 35},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs0"},
			{"RaiseEvent", "ChangeAutoFight", false},
			{"DoDeath", "Patrol_1"},
			{"DoDeath", "Patrol_2"},
			{"DoDeath", "Patrol_3"},
			{"DoDeath", "Patrol_4"},
			{"AddNpc", 6, 1, 36, "jiguan", "jiguan_1",false, 38},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {35},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddAnger", 1000},
		},
	},
------第二区巡逻设置--------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_5", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_5", 28, 10, -1, -1},
			{"CloseLock", 41, 42},
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_6", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_6", 28, 10, -1, -1},
			{"CloseLock", 42},
			{"CloseLock", 40},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_7", "哈哈，这有群不怕死的来闯葬马岗！", 4, 0, 1},
			{"CastSkill", "Patrol_7", 28, 10, -1, -1},
			{"CloseLock", 40, 41},
		},
	},
	[43] = {nTime = 0, nNum = 14,
		tbPrelock = {{40, 41, 42}},
		tbStartEvent = 
		{
			{"CloseLock", 44},

			{"SetNpcAi", "Patrol_5", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_6", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_7", "Setting/Npc/Ai/CommonActive4.ini"},

			{"AddNpc", 7, 1, 0, "wall", "wall_2",false, 20},
			{"NpcRemoveBuff", "Patrol_5", 2402},
			{"NpcRemoveBuff", "Patrol_6", 2402},
			{"NpcRemoveBuff", "Patrol_7", 2402},
			{"SetNpcRange", "Patrol_5", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_6", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_7", 5000, 5000, 2},

			{"BlackMsg", "你被发现了，惊动了大批山贼！"},
			{"AddNpc", 2, 2, 43, "guaiwu2", "guaiwu6", 1, 0, 1.5, 9011, 1},
			{"AddNpc", 1, 9, 43, "guaiwu1", "guaiwu5", 1, 0, 2, 0, 0},
			{"NpcBubbleTalk", "guaiwu2", "活得不耐烦了，这里都敢闯?！", 5, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"SetTargetPos", 3437, 4594},
			{"DoDeath", "wall"},
			{"BlackMsg", "这里居然藏了这么多山贼，真是凶险异常！"},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	[44] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"TrapUnlock", "trap2", 44},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"BlackMsg", "小心！别惊动醉酒的山贼头目！"},
			{"RaiseEvent", "ChangeAutoFight", false},
			{"DoDeath", "Patrol_5"},
			{"DoDeath", "Patrol_6"},
			{"DoDeath", "Patrol_7"},
			{"AddNpc", 6, 1, 45, "jiguan", "jiguan_2",false, 34},
		},
	},
	[45] = {nTime = 0, nNum = 1,
		tbPrelock = {44},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddAnger", 1000},
		},
	},
------第三区巡逻设置--------------
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"TrapUnlock", "trap6", 50},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"DelNpc", "toumu"},
			{"AddNpc", 5, 1, 51, "toumu", "toumu", 1, 0, 0, 0, 0},
			{"NpcBubbleTalk", "toumu", "又有杂碎来打扰大爷的酒兴！", 4, 1, 1},
		},
	},
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
			{"CastSkill", "toumu", 28, 10, -1, -1},
			{"CloseLock", 52},
			{"AddNpc", 7, 1, 0, "wall", "wall_3",false, 6},
			{"BlackMsg", "糟糕！你被发现了！"},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"SetTargetPos", 5483, 2941},
			{"DoDeath", "wall"},
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"TrapUnlock", "trap3", 52},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"RaiseEvent", "CallPartner"},
			{"DoDeath", "toumu"},
			{"SetTargetPos", 5483, 2941},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
}