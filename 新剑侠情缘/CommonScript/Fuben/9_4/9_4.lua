 
local tbFubenSetting = {};
Fuben:SetFubenSetting(68, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/9_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/9_4/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/9_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {6034, 5042}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}
 
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2631,	nLevel = -1,	nSeries = -1},	--赵节
	[2] = {nTemplate = 2632,	nLevel = -1,	nSeries = -1},	--卫队长
	[3] = {nTemplate = 2633,	nLevel = -1,	nSeries = -1},	--镰枪卫
	[4] = {nTemplate = 2634,	nLevel = -1,	nSeries = -1},	--御射卫
	[5] = {nTemplate = 2647,	nLevel = -1,	nSeries = 0},	--机关
	[6] = {nTemplate = 2646,	nLevel = -1,	nSeries = 0},	--南宫飞云
	[7] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1137, false},
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
			{"SetTargetPos", 5683, 3633},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 1, 4, "jingying", "gw1_1", false, 16, 0, 0, 0},
			{"AddNpc", 3, 4, 4, "guaiwu", "gw1_2", false, 16, 0, 0, 0},
			{"AddNpc", 4, 4, 4, "guaiwu", "gw1_3", false, 16, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "wall_1", "wall_1",false, 28},

			{"NpcBubbleTalk", "guaiwu", "受死吧！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，居然敢闯将军府！", 4, 2, 1},
			{"PlayerBubbleTalk", "后方似有响动，不好，被包围了！"},
			{"BlackMsg", "回头消灭埋伏"},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"SetTargetPos", 6094, 4495},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall_1"},
			{"AddNpc", 7, 1, 0, "wall_2", "wall_2",false, 16},
			{"AddNpc", 7, 1, 0, "wall_3", "wall_3",false, 10},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"SetTargetPos", 4462, 2893},
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
			{"AddNpc", 2, 1, 6, "jingying", "gw2_1", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 3, 4, 6, "guaiwu", "gw2_2", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 4, 4, 6, "guaiwu", "gw2_3", false, 8, 0.5, 9010, 0.5},

			{"NpcBubbleTalk", "guaiwu", "受死吧！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，居然敢闯将军府！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 5, 1, 8, "jiguan", "jiguan", false, 10},
			{"SetHeadVisiable", "jiguan", false, 0.1},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"SetTargetPos", 2793, 3500},
			{"TrapUnlock", "trap3", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PlayerBubbleTalk", "前路不通，此处必有机关！"},
			{"BlackMsg", "四处探查寻找机关"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall_2"},
			{"CloseLock", 20},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"SetTargetPos", 4111, 4598},
			{"TrapUnlock", "trap4", 9},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[10] = {nTime = 0, nNum = 9,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 2, 1, 10, "jingying", "gw3_1", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 3, 4, 10, "guaiwu", "gw3_2", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 4, 4, 10, "guaiwu", "gw3_3", false, 8, 0.5, 9010, 0.5},

			{"NpcBubbleTalk", "guaiwu", "受死吧！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，居然敢闯将军府！", 4, 2, 1},
			{"PlayerBubbleTalk", "赵节真是精明，险些又掉入包围圈！"},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
			{"DoDeath", "wall_3"},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"SetTargetPos", 2554, 4245},
			{"TrapUnlock", "trap5", 11},

			{"AddNpc", 1, 1, 14, "boss", "boss", false, 30, 0, 0, 0},
			{"SetNpcProtected", "boss", 1},

			{"AddNpc", 6, 1, 0, "nangong", "nangongfeiyun", false, 60, 0, 0, 0},

			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcBloodVisable", "nangong", false, 0},
			{"SetAiActive", "boss", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 13, 1, 2082, 4821, 2},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 0, nNum = 2,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 13, 1138, false},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 2, 0, "jingying", "gw4_1", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 3, 4, 0, "guaiwu", "gw4_2", false, 8, 0.5, 9010, 0.5},
			{"AddNpc", 4, 4, 0, "guaiwu", "gw4_3", false, 8, 0.5, 9010, 0.5},

			{"NpcBubbleTalk", "guaiwu", "受死吧！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，居然敢闯将军府！", 4, 2, 1},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},

			{"BlackMsg", "击败赵节！"},

			{"SetNpcProtected", "boss", 0},
			{"SetNpcBloodVisable", "boss", true, 0},
			{"SetNpcBloodVisable", "nangong", true, 0},
			{"SetAiActive", "boss", 1},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "guaiwu"}, 
			{"DoDeath", "jingying"}, 
		},
	},
	[15] = {nTime = 2.1, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
-------------照顾视力差的玩家----------------
	[20] = {nTime = 60, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "难道机关就在左近？"},
			{"SetTargetPos", 2515, 3244},
		},
	},
}