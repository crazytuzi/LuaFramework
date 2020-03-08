
local tbFubenSetting = {};
Fuben:SetFubenSetting(55, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/7_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/7_3/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/7_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {7429, 2439}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;



tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1686,			nLevel = -1, nSeries = -1}, --五色教徒
	[2] = {nTemplate = 1687,			nLevel = -1, nSeries = -1}, --天王叛徒
	[3] = {nTemplate = 1688,			nLevel = -1, nSeries = -1}, --天王叛徒-精英
	[4] = {nTemplate = 1689,			nLevel = -1, nSeries = -1}, --封玉书

	[5] = {nTemplate = 104,				nLevel = -1, nSeries = 0}, --动态障碍墙
	
	[6] = {nTemplate = 747,				nLevel = -1, nSeries = 0},--独孤剑
	[7] = {nTemplate = 1690,			nLevel = -1, nSeries = 0},--杨瑛
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
			{"BlackMsg", "此处就是封玉书为盗宝图，原形毕露的地方！"},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 16},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"AddNpc", 5, 2, 0, "wall1", "wall_1_1",false, 16},
			{"SetTargetPos", 7371, 3928},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 4, 3, "guaiwu", "4_3_1_1", 1, 0, 0, 9008, 0.5},
			{"AddNpc", 1, 4, 3, "guaiwu", "4_3_1_2", 1, 0, 3, 9008, 0.5},
			{"AddNpc", 1, 4, 3, "guaiwu", "4_3_1_3", 1, 0, 5, 9008, 0.5},
			{"AddNpc", 1, 4, 3, "guaiwu", "4_3_1_4", 1, 0, 7, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu", "束手就擒吧，别无谓挣扎了！", 4, 0, 1},
			{"BlackMsg", "看来此处已被五色教占领了！"},

		},
	},
	[3] = {nTime = 0, nNum = 16,
		tbPrelock = {2},
		tbStartEvent = 
		{	
		},
			tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall1"},
			{"AddNpc", 5, 2, 0, "wall2", "wall_1_2",false, 16},
			{"SetTargetPos", 7360, 5557},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 4},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 2, 5, "guaiwu", "4_3_1_5", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 5, "guaiwu", "4_3_1_6", 1, 0, 1, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 4,
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 7386, 7434},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall2"},
			{"AddNpc", 5, 2, 0, "wall3", "wall_1_3",false, 16},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 6},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 5, 7, "guaiwu", "4_3_2_1", 1, 0, 0, 9008, 0.5},
			{"AddNpc", 2, 5, 7, "guaiwu", "4_3_2_2", 1, 0, 3, 9008, 0.5},
			{"AddNpc", 2, 5, 7, "guaiwu", "4_3_2_3", 1, 0, 5, 9008, 0.5},
			{"AddNpc", 3, 2, 7, "guaiwu", "4_3_2_4", 1, 0, 7, 9008, 0.5},
		},
	},
	[7] = {nTime = 0, nNum = 17,
		tbPrelock = {6},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "ops3"},
			{"AddNpc", 5, 2, 0, "wall4", "wall_1_4",false, 16},
			{"SetTargetPos", 7348, 9809},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock4", 8},
		},
			tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 3, 9, "guaiwu", "4_3_2_5", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 9, "guaiwu", "4_3_2_6", 1, 0, 1, 0, 0},
		},
	},
	[9] = {nTime = 0, nNum = 4,
		tbPrelock = {8},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 7348, 11534},
			{"OpenDynamicObstacle", "ops4"},
			{"DoDeath", "wall4"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock5", 10},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "CloseDynamicObstacle", "ops3"},	
			{"AddNpc", 5, 2, 0, "wall3", "wall_1_2",false, 16},
		},
	},
	--[11] = {nTime = 0, nNum = 14,
	--	tbPrelock = {10},
	--	tbStartEvent = 
	--	{
	--		{"AddNpc", 1, 4, 11, "guaiwu", "4_3_3_1", 1, 0, 1, 9008, 0.5},
	--		{"AddNpc", 1, 4, 11, "guaiwu", "4_3_3_2", 1, 0, 3, 9008, 0.5},
	--		{"AddNpc", 1, 6, 11, "guaiwu", "4_3_3_3", 1, 0, 5, 9008, 0.5},
	--	},
	--	tbUnLockEvent = 
	--	{
	--	},
	--},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "BOSS", "4_3_3", false, 32, 0, 0, 0},
			{"AddNpc", 2, 4, 0, "guaiwu", "4_3_3_1", false, 32, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcProtected", "guaiwu", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetNpcBloodVisable", "guaiwu", false, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetAiActive", "guaiwu", 0},

			{"NpcHpUnlock", "BOSS", 12, 30},

			{"AddNpc", 6, 1, 0, "npc", "dugujian",false, 64},
			{"AddNpc", 7, 1, 0, "npc1", "yangying",false, 64},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
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
			{"SetAllUiVisiable", false},
			{"DoDeath", "guaiwu"},

			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},

			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 2, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"SetAiActive", "BOSS", 1},
			{"NpcAddBuff", "BOSS", 2452, 1, 100},
			{"NpcBubbleTalk", "BOSS", "这次算你们狠，咱们后会有期！", 4, 0, 1},
			{"ChangeNpcAi", "BOSS", "Move", "path1", 0, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1108, false},
			{"SetNpcDir", "npc", 16},
			{"SetNpcDir", "npc1", 48},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
	[16] = {nTime = 600, nNum = 0,
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

	------------剧情表现---------
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 17, 2, 7332, 12368, 10},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 18, 1107, false, 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcProtected", "guaiwu", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetNpcBloodVisable", "guaiwu", true, 0},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},
			{"SetAiActive", "BOSS", 1},
			{"SetAiActive", "guaiwu", 1},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
			{"BlackMsg", "击败封玉书及其走狗！"},
			{"NpcBubbleTalk", "BOSS", "兄弟们出来帮忙啊！", 4, 1, 1},
			{"AddNpc", 1, 4, 0, "guaiwu", "4_3_3_1", 1, 0, 1, 9008, 0.5},
			{"AddNpc", 3, 2, 0, "guaiwu", "4_3_3_2", 1, 0, 2, 9008, 0.5},
			{"AddNpc", 2, 6, 0, "guaiwu", "4_3_3_3", 1, 0, 3, 9008, 0.5},
		},
	},

}
