
local tbFubenSetting = {};
Fuben:SetFubenSetting(57, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/7_5/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/7_5/ExtNpcAwardInfo.tab"	-- 掉落表
--tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/7_5/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1490, 4713}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;


tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1692,		nLevel = -1, nSeries = -1},	--五色教徒
	[2] = {nTemplate = 1693,		nLevel = -1, nSeries = -1},	--五色教护卫
	[3] = {nTemplate = 1694,		nLevel = -1, nSeries = -1},	--五色杀手-精英
	[4] = {nTemplate = 1697,		nLevel = -1, nSeries = -1},	--林对儿-首领
	[5] = {nTemplate = 1698,		nLevel = -1, nSeries = -1},	--无相-首领
	[6] = {nTemplate = 1699, 		nLevel = -1, nSeries = -1},	--封玉书-首领

	[7] = {nTemplate = 104,			nLevel = -1, nSeries = 0},	--障碍墙

	[8] = {nTemplate = 747,			nLevel = -1, nSeries = 0},	--独孤剑
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1111, false},	
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
			{"SetTargetPos", 1637, 2942},
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
			{"AddNpc", 1, 7, 4, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 1, 4, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "招惹我五色教的人都得死！", 3, 1, 1},

			{"RaiseEvent", "PartnerSay", "有埋伏！", 3, 1},
			{"BlackMsg", "击败忽然出现的五色教徒！"},

			{"AddNpc", 7, 1, 0, "wall", "wall1", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},

	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 4641, 2188},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 8,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 2, 7, 7, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 1, 7, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "休想过去！", 3, 1, 2},
			{"RaiseEvent", "PartnerSay", "五色教徒真是没完没了！", 3, 1},

			{"AddNpc", 7, 1, 0, "wall", "wall2", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},

	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 8},
			{"SetTargetPos", 5261, 5915},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[9] = {nTime = 0, nNum = 8,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"AddNpc", 1, 3, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"AddNpc", 2, 3, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 2, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "兄弟们一起上！", 3, 1, 2},
			{"RaiseEvent", "PartnerSay", "小心！", 3, 1},

			{"AddNpc", 7, 1, 0, "wall", "wall3", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
			{"OpenDynamicObstacle", "obs4"},
			{"DoDeath", "wall"},
		},
	},

	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 10},
			{"SetTargetPos", 8783, 5414},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "wall4", false, 32, 0, 0, 0},
			{"RaiseEvent", "CloseDynamicObstacle", "obs4"},
		},
	},

	[11] = {nTime = 0, nNum = 3,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 11, "sl", "shouling1", false, 48, 0, 0, 0},
			{"AddNpc", 5, 1, 11, "sl", "shouling2", false, 32, 0, 0, 0},
			{"AddNpc", 6, 1, 11, "sl", "shouling3", false, 64, 0, 0, 0},
			{"SetNpcProtected", "sl", 1},

			{"AddNpc", 8, 1, 0, "npc", "dugujian", false, 16, 0, 0, 0},

			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetAiActive", "sl", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 2.1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},
			{"DoDeath", "gw"},
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},
		},
	},
	[13] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
	-------------------------剧情展现-------------------
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 14, 1, 9394, 5440, 10},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1112, false},	
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},

			{"SetNpcProtected", "sl", 0},
			{"SetNpcProtected", "npc", 0},
			{"SetNpcBloodVisable", "sl", true, 0},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetAiActive", "sl", 1},
			{"SetAiActive", "npc", 1},
			{"BlackMsg", "击败三魔！"},

			{"NpcBubbleTalk", "sl", "明年今日就是你的忌日！", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "我和你们拼了！", 3, 1, 1},

			{"NpcBubbleTalk", "sl", "兄弟们，该你们出来了！！", 4, 6, 1},
			{"AddNpc", 1, 3, 9, "gw", "guaiwu4", false, 0, 6, 9005, 0.5},
			{"AddNpc", 2, 3, 9, "gw", "guaiwu4", false, 0, 6, 9005, 0.5},
			{"AddNpc", 3, 2, 9, "gw", "guaiwu4", false, 0, 6, 9005, 0.5},
		},
	},

}