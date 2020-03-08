
local tbFubenSetting = {};
Fuben:SetFubenSetting(38, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/4_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/4_2/ExtNpcAwardInfo.tab"	-- 掉落表
--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"								-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2145, 6488}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 9,			nLevel = 34, nSeries = -1}, --猴子
	[2] = {nTemplate = 10,			nLevel = 35, nSeries = -1}, --猴子精英
	[3] = {nTemplate = 8,			nLevel = 34, nSeries = -1}, --猛虎
	[4] = {nTemplate = 845,			nLevel = 36, nSeries = -1}, --猴王
	[5] = {nTemplate = 747,			nLevel = 36, nSeries = 0}, --独孤剑

	[6] = {nTemplate = 74,			nLevel = 34, nSeries = 0}, --上升气流
	[7] = {nTemplate = 104,			nLevel = 34, nSeries = 0}, --动态障碍墙
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1048, false},
			--{"AddNpc", 5, 1, 0, "Start_Npc1", "Start_Npc1", 1, 1, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 12},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"AddNpc", 7, 1, 0, "wall", "men1",false, 16},
			{"SetTargetPos", 2139, 5150},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[3] = {nTime = 0, nNum = 8,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 3, "guaiwu", "4_2_1_1", 1, 0, 0, 9005, 0.5},
			{"BlackMsg", "没想到竟会中了这些恶猴的埋伏！"},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 4},
			{"SetTargetPos", 4075, 1851},
			{"AddNpc", 1, 4, 5, "guaiwu", "4_2_2_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 5, "guaiwu", "4_2_2_2", 1, 0, 0, 0, 0},	
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "men2",false, 16},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"AddNpc", 3, 2, 5, "guaiwu", "4_2_2_3", 1, 0, 3, 9005, 0.5},
			{"AddNpc", 3, 2, 5, "guaiwu", "4_2_2_4", 1, 0, 5, 9005, 0.5},
		}, 
		tbUnLockEvent = 
		{
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs2"},
			{"OpenDynamicObstacle", "obs3"},
			{"BlackMsg", "这九猴洞的猴子颇具灵性，得小心点。"},
		},
	}, 
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "GoPoint1", 6},
			{"SetTargetPos", 2249, 1804},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},		
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 7},
			{"SetTargetPos", 4608, 5880},
			{"AddNpc", 1, 3, 8, "guaiwu", "4_2_3_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 8, "guaiwu", "4_2_3_2", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "CloseDynamicObstacle", "obs3"},
			{"AddNpc", 7, 1, 0, "wall", "men3",false, 16},
		},
	},
	[8] = {nTime = 0, nNum = 8,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 3, 2, 8, "guaiwu", "4_2_3_3", 1, 0, 4, 9005, 0.5},
			{"AddNpc", 3, 2, 8, "guaiwu", "4_2_3_4", 1, 0, 6, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 9, "BOSS", "4_2_4", 2, 0, 1, 9011, 1},
			{"AddNpc", 1, 4, 0, "guaiwu", "4_2_4_1", 1, 0, 3, 9005, 0.5},
			{"BlackMsg", "看来这就是猴王了！"},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 12},
			{"StopEndTime"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
		},
	},
	[10] = {nTime = 2.1, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头开始
		},
	},
	[11] = {nTime = 1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 12},
			{"SetShowTime", 12},
			{"GameWin"},
		},
	},
	[12] = {nTime = 300, nNum = 0,
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
}
