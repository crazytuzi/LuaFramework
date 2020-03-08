
local tbFubenSetting = {};
Fuben:SetFubenSetting(40, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/4_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/4_4/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/4_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1196, 1423}											-- 副本出生点
tbFubenSetting.nStartDir				= 7;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate  = 850,  				nLevel = 39,   nSeries = -1}, --杀手精英
	[2] = {nTemplate  = 29,					nLevel = 38,   nSeries = -1}, --刺客
	[3] = {nTemplate  = 849,				nLevel = 38,   nSeries = -1}, --神秘杀手
	[4] = {nTemplate  = 851,				nLevel = 40,   nSeries = -1}, --杀手头目
	[5] = {nTemplate  = 747, 	    		nLevel = 40,   nSeries = 0}, --独孤剑

	[6] = {nTemplate  = 74,					nLevel = 38,   nSeries = 0}, --上升气流
	[7] = {nTemplate  = 104,				nLevel = 38,   nSeries = 0}, --动态障碍墙

	[8] = {nTemplate  = 853,				nLevel = 40,   nSeries = 0},	--张琳心
}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 1, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"BlackMsg", "这里就是那碧霞岛？真是个鸟不生蛋的鬼地方！"},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 18},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock2", 2},
			{"SetTargetPos", 2172, 2263},
			{"AddNpc", 7, 1, 2, "wall", "wall_1_1",false, 15},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[3] = {nTime = 0, nNum = 5,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 3, 2, 3, "guaiwu1", "4_4_1_1", 1, 0, 0, 9008, 0.5},
			{"AddNpc", 3, 3, 3, "guaiwu", "4_4_1_2", 1, 0, 1.5, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "兄弟们，有肥羊来了！大伙一起上啊！", 4, 1, 1},			
		},
			tbUnLockEvent = 
		{
			{"AddAnger", 150}, 		
		},
	},
	[4] = {nTime = 0, nNum = 5,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 3, 2, 4, "guaiwu", "4_4_2_1", 1, 0, 0, 9008, 0.5},
			{"AddNpc", 3, 3, 4, "guaiwu", "4_4_2_2", 1, 0, 1.5, 9008, 0.5},		
		},
			tbUnLockEvent = 
		{
			{"AddAnger", 150}, 	
			{"SetTargetPos", 2061, 5296},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall"},	
			{"AddNpc", 7, 1, 0, "wall", "wall_1_2",false, 32},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 5},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[6] = {nTime = 0, nNum = 4,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 3, 6, "guaiwu", "4_4_3_1", 1, 0, 0, 9008, 0.5},
			{"AddNpc", 1, 1, 6, "guaiwu2", "4_4_3_2", 1, 0, 0, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu2", "不知死活的家伙，我马上送你去见阎王！", 4, 1, 1},			
		},
			tbUnLockEvent = 
		{
			{"AddAnger", 150}, 
			{"SetTargetPos", 3267, 5537},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall"},	
			{"AddNpc", 7, 1, 0, "wall", "wall_1_3",false, 32},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 7},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 4,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 2, 1, 8, "guaiwu", "4_4_4_1", 1, 51, 0, 0, 0},
			{"AddNpc", 2, 1, 8, "guaiwu", "4_4_4_2", 1, 35, 0.3, 0, 0},
			{"AddNpc", 2, 1, 8, "guaiwu", "4_4_4_3", 1, 12, 0.6, 0, 0},
			{"AddNpc", 2, 1, 8, "guaiwu", "4_4_4_4", 1, 22, 0.9, 0, 0},			
		},
			tbUnLockEvent = 
		{
			{"AddAnger", 160}, 
			{"SetTargetPos", 5081, 5441},
			{"OpenDynamicObstacle", "ops3"},
			{"DoDeath", "wall"},	
		},
	},  
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 9},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[10] = {nTime = 0, nNum = 11,		-- 总计时
		tbPrelock = {9},
		tbStartEvent = 
		{			
			{"AddAnger", 1000}, 
			{"AddNpc", 3, 4, 10, "guaiwu", "4_4_5_1", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 4, 10, "guaiwu", "4_4_5_2", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 3, 10, "guaiwu", "4_4_5_3", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4561, 4646},				
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"AddNpc", 6, 1, 0, "4_4_8", "4_4_8", 1},			
			{"ChangeTrap", "Jump1", nil, {3983, 4058}},
			{"ChangeTrap", "Jump2", nil, {3170, 3798}},	
			{"ChangeTrap", "Jump3", nil, {3998, 2517}},	
			{"TrapUnlock", "Jump1", 11},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},			
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock7", 12},
			{"ChangeTrap", "TrapLock7", nil, nil, nil, nil, nil, true},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4826, 2237},	
			{"CloseLock", 200},		
		},
	},
	--跳崖保护
	[200] = {nTime = 4, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetPos", 3998, 2517},
		},
	},

	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock6", 13},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "BOSS", "4_4_7", false, 4, 0, 0, 0},
			{"NpcHpUnlock", "BOSS", 14, 30},
			{"AddNpc", 8, 1, 0, "npc", "zhanglinxin", false, 36, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcProtected", "npc", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetAiActive", "npc", 0},	
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 600, nNum = 0,
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

	-----------------剧情表现-----------------
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 19, 2, 5203, 2145, 10},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 20, 1051, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[21] = {nTime = 1.5, nNum = 0,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"DoCommonAct", "npc", 16, 0, 0, 0},
			{"CastSkill", "npc", 2382, 1, 5191, 2031},
			{"DoCommonAct", "BOSS", 16, 0, 0, 0},
			{"CastSkill", "BOSS", 2384, 1, 5397, 2276},
		},
		tbUnLockEvent = 
		{
			{"DoCommonAct", "npc", 36, 0, 1, 0},			--张琳心重伤昏迷
			{"NpcBubbleTalk", "npc", "啊！", 2, 0, 1},
			{"NpcBubbleTalk", "BOSS", "可惜一个娇滴滴的女子却要舞剑弄枪......", 4, 0.5, 1},
		},
	},

	[22] = {nTime = 2, nNum = 0,
		tbPrelock = {21},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[23] = {nTime = 4, nNum = 0,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"AddNpc", 5, 1, 0, "npc1", "dugujian",false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"ChangeNpcAi", "npc1", "Move", "path1", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc1", "住手！", 4, 0.5, 1},
			{"NpcBubbleTalk", "BOSS", "哪来的野小子，敢破坏大爷的好事。找死！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},
			{"SetAiActive", "BOSS", 1},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
			{"BlackMsg", "击败采花贼救下张琳心。"},
		},
	},
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"RaiseEvent", "ShowTaskDialog", 24, 1052, false},
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 1},
			{"ChangeNpcAi", "BOSS", "Move", "path2", 0, 0, 0, 1, 0},
		},
	},
	[25] = {nTime = 2, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
			{"NpcAddBuff", "BOSS", 2452, 1, 100},
			{"NpcBubbleTalk", "BOSS", "算你小子运气好！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
}
