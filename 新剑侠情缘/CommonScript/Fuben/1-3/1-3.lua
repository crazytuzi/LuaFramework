
local tbFubenSetting = {};
Fuben:SetFubenSetting(22, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/1_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_5/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/1_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1484, 4677}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 764,  		    	nLevel = -1, nSeries = 0},  --纳兰真
	[2] = {nTemplate = 765,  		    	nLevel = -1, nSeries = 0},  --杨影枫
	[3] = {nTemplate = 766,       			nLevel = -1, nSeries = 0},  --纳兰潜凛
	[4] = {nTemplate = 1317,  		    	nLevel = -1, nSeries = 0},  --无忧弟子-路异
	[5] = {nTemplate = 1318,  		    	nLevel = -1, nSeries = 0},  --无忧弟子-商芹
	[6] = {nTemplate = 104,				 	nLevel = -1, nSeries = 0},  --动态障碍墙

	[7] = {nTemplate = 1430,				nLevel = 6, nSeries = 0},  --滚石烈焰
}

--是否允许同伴出战
tbFubenSetting.bForbidPartner = true;
tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 1, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 0, "fnpc1", "fnpc1", false, 32, 0, 0, 0},--纳兰真
			{"AddNpc", 2, 1, 0, "fnpc2", "fnpc2", false, 32, 0, 0, 0},--杨影枫
			{"AddNpc", 3, 1, 0, "npc", "nalanqianling", false, 16, 0, 0, 0},--纳兰潜凛

			{"BlackMsg", "深入禁地看看！"},
			{"NpcBubbleTalk", "fnpc1", "我们前去禁地看看吧！", 4, 1, 1},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
			{"RaiseEvent", "FllowPlayer", "fnpc1", true},
			{"RaiseEvent", "FllowPlayer", "fnpc2", true},
			{"ChangeNpcFightState", "fnpc1", 0},
			{"ChangeNpcFightState", "fnpc2", 0},
			{"ChangeNpcFightState", "npc", 0},
			{"AddNpc", 6, 1, 0, "wall", "wall",false, 32},
		},
	},
	[2] = {nTime = 300, nNum = 0,
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
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap0", 100},
			{"SetTargetPos", 1470, 3785},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"MoveCameraToPosition", 101, 1.5, 1627, 2328, 2},
			
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
		},
		tbUnLockEvent = 
		{
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 3, 1005, false},
			{"SetForbiddenOperation", false},
			{"ChangeFightState", 1},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[4] = {nTime = 2, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		    {"SetNpcDir", "npc", 56},
		},
		tbUnLockEvent = 
		{
			{"SetNpcDir", "npc", 40},
		},
	},
	[5] = {nTime = 1, nNum = 0,		--等待时间
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "path1", 6, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 1, 0, "npc", "nalanqianling1", false, 64, 0, 0, 0},--纳兰潜凛
			{"ChangeNpcFightState", "npc", 0},
			--{"SetNpcBloodVisable", "npc", false},
		},
	},
	[7] = {nTime = 1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 0, "jg1", "jiguan1", false, 0, 0, 0, 0},--机关
			{"AddNpc", 7, 1, 0, "jg2", "jiguan2", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg3", "jiguan3", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg4", "jiguan4", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg5", "jiguan5", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg6", "jiguan6", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg7", "jiguan7", false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "jg8", "jiguan8", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "jg1", "Move", "path6_1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg2", "Move", "path6_2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg3", "Move", "path6_3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg4", "Move", "path6_4", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg5", "Move", "path6_5", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg6", "Move", "path6_6", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg7", "Move", "path6_7", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg8", "Move", "path6_8", 0, 0, 0, 0, 1},

			{"SetForbiddenOperation", false},
			{"RaiseEvent", "ShowTaskDialog", 8, 1006, false},
		},
		tbUnLockEvent = 
		{
			{"LeaveAnimationState", true},
			{"PlayCameraEffect", 9119},
			{"SetAllUiVisiable", true},
		},
	},
	[9] = {nTime = 0, nNum = 1,	
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 9},
			{"SetTargetPos", 4058, 2201},
		}, 
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	}, 
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "npc1", "npc1", false, 32, 0, 0, 0},--无忧教弟子
			{"AddNpc", 5, 1, 0, "npc2", "npc2", false, 32, 0, 0, 0},--无忧教弟子
			{"ChangeNpcFightState", "npc1", 0},
			{"ChangeNpcFightState", "npc2", 0},
			--{"SetNpcBloodVisable", "npc1", false},
			--{"SetNpcBloodVisable", "npc2", false},
			{"MoveCameraToPosition", 10, 1, 5226, 2731, 5},
			{"PlayCameraEffect", 9119},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0, nNum = 2,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"BlackMsg", "纳兰潜凛拍了三下手后，两个人走了出来！"},
			{"ChangeNpcAi", "npc1", "Move", "path2_1", 11, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "path2_2", 11, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 12, 1007, false},
			{"SetForbiddenOperation", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", true},
			{"NpcBubbleTalk", "npc", "什么人？！", 5, 0, 1},
			{"SetNpcDir", "npc", 40},
			{"ChangeNpcAi", "npc1", "Move", "path4_1", 11, 0, 0, 1, 0},--无忧弟子离开
			{"ChangeNpcAi", "npc2", "Move", "path4_2", 11, 0, 0, 1, 0},
			{"NpcBubbleTalk", "npc1", "属下告退！", 3, 0, 1},
			{"NpcBubbleTalk", "npc2", "属下告退！", 3, 0, 1},
			{"RaiseEvent", "FllowPlayer", "fnpc1", false},
			{"RaiseEvent", "FllowPlayer", "fnpc2", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 2,	
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "fnpc1", "Move", "path3_1", 14, 0, 0, 0, 0},
			{"ChangeNpcAi", "fnpc2", "Move", "path3_2", 14, 0, 0, 0, 0},
		}, 
		tbUnLockEvent = 
		{
		},
	}, 
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", false},
		   {"RaiseEvent", "ShowTaskDialog", 15, 1008, false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 2, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "fnpc1", "Move", "path5_1", 16, 0, 0, 1, 0},
			{"ChangeNpcAi", "fnpc2", "Move", "path5_2", 16, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
}
