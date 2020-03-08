
local tbFubenSetting = {};
Fuben:SetFubenSetting(39, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/4_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/4_3/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/4_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {7429, 2439}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 846,			nLevel = 36, nSeries = -1}, --流氓
	[2] = {nTemplate = 867,			nLevel = 36, nSeries = -1}, --打手
	[3] = {nTemplate = 29,			nLevel = 36, nSeries = -1}, --刺客
	[4] = {nTemplate = 848,			nLevel = 38, nSeries = -1}, --路达

	[5] = {nTemplate = 104,		    nLevel = 36, nSeries = 0}, --动态障碍墙
	
	[6] = {nTemplate = 747, 		nLevel = 38, nSeries = 0},--独孤剑
	[7] = {nTemplate = 1373,		nLevel = 38, nSeries = 0},--张如梦
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1049, false},	
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
			{"NpcBubbleTalk", "guaiwu", "你这家伙真是好胆，竟敢辱骂路达大哥！今日兄弟们就让你吃些苦头！", 4, 0, 1},
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
			{"AddNpc", 3, 2, 5, "guaiwu", "4_3_1_5", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 5, "guaiwu", "4_3_1_6", 1, 0, 1, 0, 0},
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
			{"AddNpc", 1, 5, 7, "guaiwu", "4_3_2_2", 1, 0, 3, 9008, 0.5},
			{"AddNpc", 1, 5, 7, "guaiwu", "4_3_2_3", 1, 0, 5, 9008, 0.5},
			{"AddNpc", 1, 5, 7, "guaiwu", "4_3_2_4", 1, 0, 7, 9008, 0.5},
			{"NpcBubbleTalk", "guaiwu", "你这家伙真是好胆，竟敢辱骂路达大哥！今日兄弟们就让你吃些苦头！", 4, 0, 1},
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
			{"AddNpc", 3, 2, 9, "guaiwu", "4_3_2_5", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 9, "guaiwu", "4_3_2_6", 1, 0, 1, 0, 0},
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
			{"AddNpc", 4, 1, 12, "BOSS", "4_3_3", false, 32, 0, 0, 0},
			{"AddNpc", 1, 4, 0, "guaiwu", "4_3_3_1", false, 32, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcProtected", "guaiwu", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetNpcBloodVisable", "guaiwu", false, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetAiActive", "guaiwu", 0},
			--{"NpcBubbleTalk", "BOSS", "不知道死活的家伙，竟敢辱骂你路达大爷，今日我就送你去见阎王！", 4, 3, 1},
			--{"AddNpc", 1, 4, 0, "guaiwu", "4_3_3_2", false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 16},
			{"StopEndTime"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
		},
	},
	[13] = {nTime = 2.1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
		},
	},
	[14] = {nTime = 1, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 16},
			{"SetShowTime", 16},
			{"GameWin"},
		},
	},
	[16] = {nTime = 300, nNum = 0,
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
			{"RaiseEvent", "ShowTaskDialog", 18, 1050, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"AddNpc", 6, 1, 0, "npc", "dugujian",false, 0},
			{"AddNpc", 7, 1, 0, "npc1", "zhangrumeng",false, 0},
			{"ChangeNpcAi", "npc", "Move", "path1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "path2", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc", "简直是胡说八道！", 4, 0.5, 1},
			{"RaiseEvent", "ShowTaskDialog", 19, 1095, false, 1},
			--{"NpcBubbleTalk", "npc1", "果然是胡说八道！大宋子民说出这样不知廉耻的话，简直辱没了祖宗！", 4, 1.5, 1},
			--{"NpcBubbleTalk", "BOSS", "你敢骂你爷爷？", 4, 3.5, 1},
			--{"NpcBubbleTalk", "npc", "象你这样的败类，就应该骂！", 4, 5.5, 1},
			--{"NpcBubbleTalk", "npc1", "而且应该揍一顿！", 4, 7.5, 1},
			--{"NpcBubbleTalk", "BOSS", "看你们是不想活了！", 4, 9.5, 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcProtected", "guaiwu", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetNpcBloodVisable", "guaiwu", true, 0},
			{"SetAiActive", "BOSS", 1},
			{"SetAiActive", "guaiwu", 1},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
			{"BlackMsg", "击败路达及其走狗！"},
			{"NpcBubbleTalk", "BOSS", "兄弟们出来帮忙啊！", 4, 1, 1},
			{"AddNpc", 1, 4, 0, "guaiwu", "4_3_3_1", 1, 0, 1, 9008, 0.5},
			{"AddNpc", 1, 4, 0, "guaiwu", "4_3_3_2", 1, 0, 2, 9008, 0.5},
			{"AddNpc", 1, 6, 0, "guaiwu", "4_3_3_3", 1, 0, 3, 9008, 0.5},
		},
	},


}
