
local tbFubenSetting = {};
Fuben:SetFubenSetting(67, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/9_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/9_3/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/9_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1468, 2058}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}
 
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2615,	nLevel = -1,	nSeries = -1},	--山庄护卫
	[2] = {nTemplate = 2616,	nLevel = -1,	nSeries = -1},	--山庄精锐
	[3] = {nTemplate = 2617,	nLevel = -1,	nSeries = -1},	--异域力士
	[4] = {nTemplate = 2618,	nLevel = -1,	nSeries = -1},	--邵骑风

	[5] = {nTemplate = 2619,	nLevel = -1,	nSeries = 0},	--南宫飞云
	[6] = {nTemplate = 2620,	nLevel = -1,	nSeries = 0},	--秋依水
	[7] = {nTemplate = 2621,	nLevel = -1,	nSeries = 0},	--赵无双
	[8] = {nTemplate = 2622,	nLevel = -1,	nSeries = 0},	--唐影
	[9] = {nTemplate = 2623,	nLevel = -1,	nSeries = 0},	--柴嵩

	[100] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1131, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
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
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 2418, 1391},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 100, 1, 0, "wall", "wall_1",false, 32},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 4, "guaiwu", "gw1_1", false, 16, 0.5, 9010, 0.5},
			{"AddNpc", 2, 1, 4, "jingying", "gw1_2", false, 16, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "guaiwu", "凤池山庄是你想来就来的地方？", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "乖乖归顺我们，邵庄主亏待不了你！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs0"},
			{"DoDeath", "wall"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"SetTargetPos", 3587, 3022},
			{"TrapUnlock", "trap2", 5},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 100, 1, 0, "wall", "wall_2",false, 32},
			{"AddNpc", 1, 8, 6, "guaiwu", "gw2_1", false, 16, 0.5, 9010, 0.5},
			{"AddNpc", 2, 1, 6, "jingying", "gw2_2", false, 16, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "guaiwu", "凤池山庄是你想来就来的地方？", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "乖乖归顺我们，邵庄主亏待不了你！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"SetTargetPos", 1935, 5760},
			{"TrapUnlock", "trap3", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"BlackMsg", "擒贼先擒王！"},
			{"AddNpc", 100, 1, 0, "wall", "wall_3",false, 32},
			{"AddNpc", 4, 1, 8, "boss", "boss", false, 32, 0.5, 9010, 0.5},
			{"AddNpc", 3, 2, 0, "lishi", "lishi", false, 16, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "boss", "识时务者为俊杰！", 4, 2, 1},
			{"NpcBubbleTalk", "lishi", "乖乖归顺我们，邵庄主亏待不了你！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
			{"DoDeath", "lishi"},
		},
	},
	[20] = {nTime = 1.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "lishi", 3167, 20, 300},
			{"NpcHpUnlock", "boss", 3, 50},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "顺应天时，何必螳臂当车？", 4, 2, 1},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"SetTargetPos", 4320, 6335},
			{"TrapUnlock", "trap4", 9},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 10, 3, 5391, 6286, 20},
			{"AddNpc", 5, 1, 0, "nangongfeiyun", "nangongfeiyun", false, 48, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "qiuyishui", "qiuyishui", false, 48, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "zhaowushuang", "zhaowushuang", false, 48, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "tangying", "tangying", false, 48, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "chaisong", "chaisong", false, 48, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "nangongfeiyun", "Move", "path1", 11, 0, 0, 0, 0},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 12, 1132, false},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
}