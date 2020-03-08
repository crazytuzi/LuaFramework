
local tbFubenSetting = {};
Fuben:SetFubenSetting(66, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/9_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/9_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/9_2/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {6878, 3905}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}
 
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2609,	nLevel = -1,	nSeries = -1},	--雷同
	[2] = {nTemplate = 2610,	nLevel = -1,	nSeries = -1},	--霹雳堂守卫
	[3] = {nTemplate = 2611,	nLevel = -1,	nSeries = -1},	--霹雳堂弟子
	[4] = {nTemplate = 2612,	nLevel = -1,	nSeries = -1},	--霹雳堂高手
	[5] = {nTemplate = 2614,	nLevel = -1,	nSeries = -1},	--雷晃
	[6] = {nTemplate = 2613,	nLevel = -1,	nSeries = 0},	--圣旗
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1129, false},
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
	[3] = {nTime = 0, nNum = 2,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 0, "wall", "wall_1",false, 32},
			{"AddNpc", 2, 2, 3, "guaiwu1", "gw1", false, 16, 0, 0, 0},	
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs0"},
			{"DoDeath", "wall"},
			{"SetTargetPos", 4214, 3694}, 
			{"AddNpc", 7, 2, 0, "wall", "wall_2",false, 16},
		},
	},
	[4] = {nTime = 3, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "guaiwu1", "何人擅闯霹雳堂！莫非是找死不成？", 3, 0, 1},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 5},			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 8, 6, "guaiwu1", "gw2", false, 16, 0.5, 9010, 0.5},
			{"AddNpc", 4, 2, 6, "jingying", "gw3", false, 16, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "哪里来的狂徒，竟然不识我霹雳堂威名？", 3, 2, 1},	
			{"NpcBubbleTalk", "jingying", "擅闯者格杀勿论！", 3, 2, 1},	
		},
	},
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
			{"SetTargetPos", 3212, 7308}, 
			{"AddNpc", 7, 1, 0, "wall", "wall_3",false, 32},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 7},			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 3, 8, 8, "guaiwu2", "gw4", false, 16, 0.5, 9010, 0.5},
			{"AddNpc", 4, 2, 8, "jingying", "gw5", false, 16, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "guaiwu2", "哪里来的狂徒，竟然不识我霹雳堂威名？", 3, 2, 1},	
			{"NpcBubbleTalk", "jingying", "擅闯者格杀勿论！", 3, 2, 1},	
		},
	},
	[8] = {nTime = 0, nNum = 10,
		tbPrelock = {7},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
			{"SetTargetPos", 6715, 7591}, 
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap0", 9},			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"ChangeFightState", 0},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 10, 2, 10511, 7578, 10},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 11, 1130, false},
			{"AddNpc", 1, 1, 12, "boss", "boss", false, 16, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "shouling", "shouling", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "boss", "Move", "path1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "shouling", "Move", "path1", 0, 1, 1, 0, 0},
			{"LeaveAnimationState", true},
			{"ChangeFightState", 1},
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
			{"AddNpc", 3, 16, 0, "guaiwu2", "gw6", false, 48, 0, 0, 0},
			{"AddNpc", 4, 4, 0, "jingying", "gw7", false, 48, 0, 0, 0},
			{"AddNpc", 6, 4, 0, "qizi", "qizi", false, 48, 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu2", "誓与霹雳堂共存亡！", 3, 1, 1},
			{"NpcBubbleTalk", "jingying", "霹雳堂千秋万代！", 3, 1, 1},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "qizi"},
			{"DoDeath", "shouling"},
			{"DoDeath", "gw6"},
			{"DoDeath", "gw7"},
		},
	},
	[13] = {nTime = 2.1, nNum = 0,
		tbPrelock = {12},
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
}