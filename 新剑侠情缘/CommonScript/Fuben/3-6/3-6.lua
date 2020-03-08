
local tbFubenSetting = {};
Fuben:SetFubenSetting(35, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_6/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_6/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_6/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1422, 4915}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1486,			nLevel = 28, nSeries = -1}, --无忧杀手
	[2] = {nTemplate = 1488,			nLevel = 28, nSeries = -1}, --守卫弟子
	[3] = {nTemplate = 1487,			nLevel = 29, nSeries = -1}, --杀手精英
	[4] = {nTemplate = 29,				nLevel = 28, nSeries = -1}, --刺客
	[5] = {nTemplate = 1489,			nLevel = 30, nSeries = -1}, --杀手头目
	[6] = {nTemplate = 684,				nLevel = 30, nSeries = 0}, --杨影枫

	[7] = {nTemplate = 104,				nLevel = 28, nSeries = 0}, --动态障碍墙
	
	[8] = {nTemplate = 1348,			nLevel = 30, nSeries = 0},--蔷薇
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1042, false},	
			--{"AddNpc", 6, 1, 0, "Start_Npc1", "Start_Npc1", 1, 32, 0, 0, 0},
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
			{"AddNpc", 7, 2, 0, "wall1", "wall_1_1",false, 32},
			{"SetTargetPos", 1246, 2664},
			{"AddNpc", 1, 4, 3, "guaiwu", "3_6_1_1", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 3, "guaiwu", "3_6_1_2", false, 0, 0, 0, 0},
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
			{"AddNpc", 2, 3, 3, "guaiwu", "3_6_1_2", false, 0, 1, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu", "来者何人，通天塔已归我无忧教，闲杂人等还不速速退去！？", 4, 2, 1},
		},
			tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall1"},
			{"AddNpc", 7, 2, 0, "wall2", "wall_1_2",false, 16},
			{"SetTargetPos", 4977, 2328},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 4},
			{"AddNpc", 1, 3, 5, "guaiwu", "3_6_2_1", 1, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 2, 5, "guaiwu1", "3_6_2_2", 1, 0, 0, 9005, 0.5},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 4, 5, "guaiwu", "3_6_2_3", 1, 0, 3, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "大胆狂徒，真是活的不耐烦了！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "ops2"},
			{"OpenDynamicObstacle", "ops3"},
			{"SetTargetPos", 5476, 5360},
			--{"NpcBubbleTalk", "Start_Npc1", "守卫越来越多了，我们得尽快行动！", 4, 1, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 6},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "CloseDynamicObstacle", "ops2"},	
			{"AddNpc", 7, 2, 0, "wall2", "wall_1_2",false, 16},
		},
	},
	[7] = {nTime = 0, nNum = 10,
		tbPrelock = {6},
		tbStartEvent = 
		{	
			{"AddNpc", 1, 2, 7, "guaiwu", "3_6_3_3", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 3, 7, "guaiwu", "3_6_3_1", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 7, "guaiwu", "3_6_3_2", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 3, 7, "guaiwu", "3_6_3_3", 1, 0, 2, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "擅闯通天塔，杀无赦！", 4, 2, 2},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 5, 1, 8, "BOSS", "3_6_4", 2, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS", "到此为止了！这通天塔可不是你想来能来的地方！", 4, 3, 1},
			--{"NpcBubbleTalk", "Start_Npc1", "哼，你们是阻止不了我的！", 4, 5, 1},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 12},
			{"StopEndTime"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
		},
	},
	[9] = {nTime = 2.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
		},
	},
	-------------------剧情镜头------------------
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 10, 2, 5424, 6744, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"AddNpc", 6, 1, 0, "Start_Npc1", "Start_Npc1", 1, 32, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "npc", "qiangwei", false, 32, 0, 0, 0},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"ChangeNpcAi", "Start_Npc1", "Move", "path1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc", "Move", "path2", 0, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 11, 1043, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
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
