
local tbFubenSetting = {};
Fuben:SetFubenSetting(53, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/7_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/7_1/ExtNpcAwardInfo.tab"	-- 掉落表
--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPath.tab"								-- 寻路点
tbFubenSetting.tbBeginPoint 			= {4461, 1062}											-- 副本出生点
tbFubenSetting.nStartDir				= 48;



tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1672,		nLevel = -1, nSeries = -1},	--老虎
	[2] = {nTemplate = 1673,		nLevel = -1, nSeries = -1},	--猛虎-精英
	[3] = {nTemplate = 1674,		nLevel = -1, nSeries = -1},	--野狼
	[4] = {nTemplate = 1675,		nLevel = -1, nSeries = -1},	--野狼-精英
	[5] = {nTemplate = 1676,		nLevel = -1, nSeries = -1},	--雪莲姥姥-首领
	[6] = {nTemplate = 853, 		nLevel = -1, nSeries = 0},	--张琳心
	[7] = {nTemplate = 104,			nLevel = -1, nSeries = 0},	--障碍墙
}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1104, false},	
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
		},
	},
	[2] = {nTime = 600, nNum = 0,
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
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 3629, 1181},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 7, 4, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 4, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"RaiseEvent", "PartnerSay", "呀！有老虎！", 3, 1},
			{"BlackMsg", "击败忽然出现的老虎！"},

			{"AddNpc", 7, 1, 0, "wall", "wall1", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trapgo1", 5},
			{"SetTargetPos", 1439, 1351},
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 1439, 2967},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 7,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 3, 6, 7, "gw", "guaiwu2", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 7, "gw", "guaiwu2", false, 0, 0, 0, 0},
			{"RaiseEvent", "PartnerSay", "这些狼真是凶恶呀！", 3, 1},
			{"BlackMsg", "击败野狼！"},

			{"AddNpc", 7, 1, 0, "wall", "wall2", false, 16, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "wall", "wall3", false, 32, 0, 0, 0},
			{"RaiseEvent", "CloseDynamicObstacle", "obs2"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 7,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 3, 6, 8, "gw", "guaiwu3", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 8, "gw", "guaiwu3", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"OpenDynamicObstacle", "obs3"},
			{"OpenDynamicObstacle", "obs4"},
			{"DoDeath", "wall"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trapgo2", 9},
			{"SetTargetPos", 2230, 4407},
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 10},
			{"SetTargetPos", 3797, 3873},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "wall4", false, 40, 0, 0, 0},
			{"RaiseEvent", "CloseDynamicObstacle", "obs4"},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 5, 1, 0, "sl", "shouling", false, 40, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "npc", "zhanglinxin", false, 8, 0, 0, 0},

			{"NpcHpUnlock", "sl", 11, 30},

			{"SetNpcProtected", "sl", 1},
			{"SetNpcProtected", "npc", 1},
			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "npc", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"SetNpcProtected", "sl", 1},
			{"SetNpcProtected", "npc", 1},
			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "npc", 0},
			
			{"RaiseEvent", "ShowTaskDialog", 12, 1106, false},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},

	-------------------------剧情展现-------------------
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 13, 1105, false},	
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "sl", 0},
			{"SetNpcProtected", "npc", 0},
			{"SetNpcBloodVisable", "sl", true, 0},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetAiActive", "sl", 1},
			{"SetAiActive", "npc", 1},
			{"BlackMsg", "击败雪莲姥姥！"},
		},
	},

}