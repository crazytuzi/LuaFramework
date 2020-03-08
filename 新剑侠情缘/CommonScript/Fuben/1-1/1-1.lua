
local tbFubenSetting = {};
Fuben:SetFubenSetting(20, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/1_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/1_1/NpcPath.tab"		    -- 寻路点
tbFubenSetting.tbBeginPoint 			= {2454, 2464}											-- 副本出生点
tbFubenSetting.nStartDir				= 28;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/xuedi07_cam1.controller",
	[2] = "Scenes/camera/xuedi07_cam2.controller",
	[3] = "Scenes/camera/xuedi07_boss.controller",
}

--NPC模版ID，NPC等级，NPC五行；


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 579,			nLevel = 1,  nSeries = -1},  --拦路响马
	[2] = {nTemplate = 524,			nLevel = 1,  nSeries = -1},  --神射手
	[3] = {nTemplate = 598,			nLevel = 1,  nSeries = -1},  --蒙面杀手
	[4] = {nTemplate = 696,			nLevel = 1,  nSeries = -1},  --神秘剑客
 
	[5] = {nTemplate  = 74,			nLevel = -1,  nSeries = 0},  --上升气流
	[6] = {nTemplate  = 104,		nLevel = -1,  nSeries = 0},  --动态障碍墙

	[11] = {nTemplate  = 692,		nLevel = -1, nSeries = -1},  --受伤的村民
	[12] = {nTemplate  = 691,		nLevel = 1, nSeries = -1},  --拦路响马
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1000, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 18},
			--{"IfCase", "self.nStarLevel <= 0 and self.nFubenLevel = 1", {"UnLock", 26}},--指引开启判断
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},	
			{"SetTargetPos", 3047, 2148},
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 1, 1, 8, "guaiwu1", "1_1_1_1", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu2", "1_1_1_2", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu3", "1_1_1_3", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu4", "1_1_1_4", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu5", "1_1_1_5", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu6", "1_1_1_6", 1, 0, 0, 0, 0},
		
			{"ChangeNpcAi", "guaiwu1", "Move", "path5", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu2", "Move", "path6", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu3", "Move", "path7", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu4", "Move", "path8", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu5", "Move", "path9", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu6", "Move", "path10", 0, 1, 1, 0, 1},

			{"ChangeNpcFightState", "guaiwu1", 0, 0},
			{"SetNpcProtected", "guaiwu1", 1},
			{"ChangeNpcFightState", "guaiwu2", 0, 0},
			{"SetNpcProtected", "guaiwu2", 1},
			{"ChangeNpcFightState", "guaiwu3", 0, 0},
			{"SetNpcProtected", "guaiwu3", 1},
			{"ChangeNpcFightState", "guaiwu4", 0, 0},
			{"SetNpcProtected", "guaiwu4", 1},
			{"ChangeNpcFightState", "guaiwu5", 0, 0},
			{"SetNpcProtected", "guaiwu5", 1},
			{"ChangeNpcFightState", "guaiwu6", 0, 0},
			{"SetNpcProtected", "guaiwu6", 1},

			{"SetNpcBloodVisable", "guaiwu1", false, 0},
			{"SetNpcBloodVisable", "guaiwu2", false, 0},
			{"SetNpcBloodVisable", "guaiwu3", false, 0},
			{"SetNpcBloodVisable", "guaiwu4", false, 0},
			{"SetNpcBloodVisable", "guaiwu5", false, 0},
			{"SetNpcBloodVisable", "guaiwu6", false, 0},

			{"AddNpc", 3, 2, 10, "guaiwu7", "1_1_2_1", 1, 11, 0, 0, 0},
			{"AddNpc", 3, 2, 10, "guaiwu7", "1_1_2_2", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10, "guaiwu7", "1_1_2_3", 1, 48, 0, 0, 0},
			{"AddNpc", 1, 1, 10, "guaiwu8", "1_1_2_4", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 10, "guaiwu9", "1_1_2_5", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 10, "guaiwu10", "1_1_2_6", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 10, "guaiwu11", "1_1_2_7", 1, 0, 0, 0, 0},

			{"ChangeNpcAi", "guaiwu8", "Move", "path11", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu9", "Move", "path12", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu10", "Move", "path13", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "guaiwu11", "Move", "path14", 0, 1, 1, 0, 1},


			{"SetNpcBloodVisable", "guaiwu7", false, 0},
			{"SetNpcBloodVisable", "guaiwu8", false, 0},
			{"SetNpcBloodVisable", "guaiwu9", false, 0},
			{"SetNpcBloodVisable", "guaiwu10", false, 0},
			{"SetNpcBloodVisable", "guaiwu11", false, 0},

			{"DoCommonAct", "guaiwu7", 6, 0, 1, 0},
			{"ChangeNpcFightState", "guaiwu7", 0, 0},
			{"SetNpcProtected", "guaiwu7", 1},
			{"ChangeNpcFightState", "guaiwu8", 0, 0},
			{"SetNpcProtected", "guaiwu8", 1},
			{"ChangeNpcFightState", "guaiwu9", 0, 0},
			{"SetNpcProtected", "guaiwu9", 1},
			{"ChangeNpcFightState", "guaiwu10", 0, 0},
			{"SetNpcProtected", "guaiwu10", 1},
			{"ChangeNpcFightState", "guaiwu11", 0, 0},
			{"SetNpcProtected", "guaiwu11", 1},
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[3] = {nTime = 0.1, nNum = 0,
		tbPrelock = {29},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PlayCameraEffect", 9057},
			{"PlayCameraAnimation", 2, 6},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},		    
		    {"RaiseEvent", "ShowPlayer", false},
		    {"RaiseEvent", "ShowPartnerAndHelper", false},
		    {"AddNpc", 11, 1, nil, "npc1", "1_1_5_1", 1, 0, 0, 0, 0},
			{"AddNpc", 11, 1, nil, "npc2", "1_1_5_2", 1, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 8, "npc3", "1_1_5_3", 1, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 8, "npc4", "1_1_5_4", 1, 0, 0, 0, 0},
			{"NpcBubbleTalk", "npc1", "救... 救命啊！！！", 2, 0.5, 1},

			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetNpcBloodVisable", "npc4", false, 0},


			{"ChangeNpcAi", "npc1", "Move", "path1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "npc2", "Move", "path2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "npc3", "Move", "path3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "npc4", "Move", "path4", 0, 0, 0, 0, 1},

			{"ChangeNpcFightState", "npc1", 0, 0},
			{"SetNpcProtected", "npc1", 1},
			{"ChangeNpcFightState", "npc2", 0, 0},
			{"SetNpcProtected", "npc2", 1},
			{"ChangeNpcFightState", "npc3", 0, 0},
			{"SetNpcProtected", "npc3", 1},
			{"ChangeNpcFightState", "npc4", 0, 0},
			{"SetNpcProtected", "npc4", 1},
		},
	},
	[5] = {nTime = 5, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "npc1"},
			{"DelNpc", "npc2"},

		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", true}, 
		    {"SetForbiddenOperation", false},
		    {"LeaveAnimationState", false},
		    {"RaiseEvent", "ShowPlayer", true},
		    {"RaiseEvent", "ShowPartnerAndHelper", true},
		    {"SetTargetPos", 4960, 2137},
		    {"RestoreCameraRotation"},
		    {"DelNpc", "npc3"},
			{"DelNpc", "npc4"},
			{"BlackMsg", "前方村落似乎被响马给占领了！"}, 
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 7},	
			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "guaiwu1", "哈哈，又有肥羊上门了！兄弟们抄家伙上啊！", 4, 0, 1},

			{"ChangeNpcFightState", "guaiwu1", 1, 0},
			{"SetNpcProtected", "guaiwu1", 0},
			{"ChangeNpcFightState", "guaiwu2", 1, 0},
			{"SetNpcProtected", "guaiwu2", 0},
			{"ChangeNpcFightState", "guaiwu3", 1, 0},
			{"SetNpcProtected", "guaiwu3", 0},
			{"ChangeNpcFightState", "guaiwu4", 1, 0},
			{"SetNpcProtected", "guaiwu4", 0},
			{"ChangeNpcFightState", "guaiwu5", 1, 0},
			{"SetNpcProtected", "guaiwu5", 0},
			{"ChangeNpcFightState", "guaiwu6", 1, 0},
			{"SetNpcProtected", "guaiwu6", 0},


			{"SetNpcBloodVisable", "guaiwu1", true, 0},
			{"SetNpcBloodVisable", "guaiwu2", true, 0},
			{"SetNpcBloodVisable", "guaiwu3", true, 0},
			{"SetNpcBloodVisable", "guaiwu4", true, 0},
			{"SetNpcBloodVisable", "guaiwu5", true, 0},
			{"SetNpcBloodVisable", "guaiwu6", true, 0},			
		},
	},
	[8] = {nTime = 0, nNum = 6,
		tbPrelock = {7},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 6481, 4793},
			{"OpenDynamicObstacle", "ops2"},
			{"CloseWindow", "Guide"},--指引技能关闭
			{"BlackMsg", "这群响马真是毫无人性！今日我便要为民除害！"},
			{"AddAnger", 300},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 9},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "guaiwu", "哪里来的家伙，敢妨碍大爷们吃肉！给我宰了他！", 6, 0, 1},

			{"SetNpcBloodVisable", "guaiwu7", true, 0},
			{"SetNpcBloodVisable", "guaiwu8", true, 0},
			{"SetNpcBloodVisable", "guaiwu9", true, 0},
			{"SetNpcBloodVisable", "guaiwu10", true, 0},
			{"SetNpcBloodVisable", "guaiwu11", true, 0},

			{"DoCommonAct", "guaiwu7", 7, 0, 0, 0},
			{"ChangeNpcFightState", "guaiwu7", 1, 0},
			{"SetNpcProtected", "guaiwu7", 0},
			{"ChangeNpcFightState", "guaiwu8", 1, 0},
			{"SetNpcProtected", "guaiwu8", 0},
			{"ChangeNpcFightState", "guaiwu9", 1, 0},
			{"SetNpcProtected", "guaiwu9", 0},
			{"ChangeNpcFightState", "guaiwu10", 1, 0},
			{"SetNpcProtected", "guaiwu10", 0},
			{"ChangeNpcFightState", "guaiwu11", 1, 0},
			{"SetNpcProtected", "guaiwu11", 0},

			{"PlaySceneAnimation", "fb_xueshan_kaorou", "wind", 1, false},
		},
	},
	[10] = {nTime = 0, nNum = 9,
		tbPrelock = {9},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddAnger", 300},
			--{"ChangeTrap", "Jump3", nil, {3387, 5559}},	
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"OpenDynamicObstacle", "ops2"},

			{"TrapUnlock", "TrapLock5", 11},
			{"ChangeTrap", "TrapLock5", nil, nil, nil, nil, nil, true},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 6, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"PlayCameraAnimation", 3, 13},
			{"PlayCameraEffect", 9059},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},
		    {"RestoreCameraRotation"},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 4, 1, 15, "BOSS", "1_1_3", 2, 0, 0, 0, 0},
			{"SetHeadVisiable", "BOSS", false, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},	
			{"SetPos", 2927, 6033},
			{"PauseLock", 18},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 14, 1002, false},
			{"RaiseEvent", "ShowPlayer", true},
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 18},
			{"SetShowTime", 18},
			{"SetAllUiVisiable", true}, 
	    
		    {"RaiseEvent", "ShowPartnerAndHelper", true},
		    {"LeaveAnimationState", false},
		    {"ChangeNpcFightState", "BOSS", 1, 0},
		    {"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"PauseLock", 18},
			{"StopEndTime"},
		},
	},
	[16] = {nTime = 2.1, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"ResumeLock", 18},
			{"SetShowTime", 18},
		},
	},
	[17] = {nTime = 1, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
	[18] = {nTime = 300, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "RegisterTimeoutLock"},
		},
		tbUnLockEvent = 
		{
		    {"CloseWindow", "RockerGuideNpcPanel"},
		    {"SetForbiddenOperation", false, true},
		    {"SetGuidingJoyStick", false},
			{"GameLost"},
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 20},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},	
		},
	},
	[21] = {nTime = 3, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "npc3", "不想死的赶紧给我站住！", 2, 0, 1},
		},
	},
	[22] = {nTime = 5, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "npc4", "妈的，真晦气！让他们给跑了！", 3, 0, 1},
		},
	},
	[23] = {nTime = 2, nNum = 0,
		tbPrelock = {22},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "npc3", "Move", "path15", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "npc4", "Move", "path16", 0, 0, 0, 0, 1},
		},
	},
	[24] = {nTime = 0.35, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlaySound", 5501},
		},
	},
	[25] = {nTime = 1.2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlaySound", 6355},
		},
	},
	[26] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 26},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	--跳崖保护
	[200] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 200},
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 201},
		}
	},
	[201] = {nTime = 3, nNum = 0,
		tbPrelock = {26},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetPos", 3111, 5028},
		},
	},

	[27] = {nTime = 0, nNum = 1,   --指引技能使用
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"OpenGuide", 27, "PopT", "请点击使用武功", "HomeScreenBattle", "Skill2", {0, -40}, false, true},--使用技能
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "Guide"},     --指引技能关闭
		},
	},
	[28] = {nTime = 1, nNum = 0,   --指引摇杆移动
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "按住[FFFE0D]左边的摇杆[-]不松，然后滑动手指\n向前移动！"},     --指引行走
		    {"SetForbiddenOperation", true, true},           --禁止操作
		    {"SetGuidingJoyStick", true},              --显示摇杆
		},
		tbUnLockEvent = 
		{
		},
	},
	[29] = {nTime = 1, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"CloseWindow", "RockerGuideNpcPanel"},
		    {"SetForbiddenOperation", false, true},
		    {"SetGuidingJoyStick", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[30] = {nTime = 1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowPlayer", false},
		    {"RaiseEvent", "ShowPartnerAndHelper", false},
		},
	},

	[31] = {nTime = 0, nNum = 16,						--怒气技能
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 31, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 31, "gw", "guaiwu3", false, 0, 0, 0, 0},
			{"AddNpc", 3, 4, 31, "gw", "guaiwu2", false, 0, 0, 0, 0},
			{"BlackMsg", "糟糕，惊动了大批响马！"},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 5, 1, 7, "1_1_4", "1_1_4", 1},	
			{"ChangeTrap", "Jump1", nil, {4085, 4494}},
			{"ChangeTrap", "Jump2", nil, {3111, 5028}},

			{"SetTargetPos", 5257, 4650},
		},
	},
	[32] = {nTime = 1, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetNpcRange", "gw", 5000, 5000, 0},
			{"NpcBubbleTalk", "gw", "竟敢到俺们的地盘撒野，不想活了？", 4, 1, 4},
			{"AddAnger", 400},
		},
	},
	[33] = {nTime = 5, nNum = 1,   --指引怒气使用
		tbPrelock = {32},
		tbStartEvent = 
		{
			{"OpenGuide", 33, "PopT", "点击使用大招", "HomeScreenBattle", "Skill5", {0, -40}, false, true},--使用技能
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "点击箭头指引的[FFFE0D]怒气技能[-]可施放大招！"},
			{"PlayHelpVoice", "Setting/NpcVoice/15-A.voice"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "Guide"},
			{"CloseWindow", "RockerGuideNpcPanel"},
		},
	},
	[100] = {nTime = 3, nNum = 0,						--boss展示
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "BossReferral", "武", "言道", "忘忧岛响马头领"},
			{"DoCommonAct", "BOSS", 17, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
		},
	},


}
