
local tbFubenSetting = {};
Fuben:SetFubenSetting(36, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_7/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_7/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_7/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2320, 3214}											-- 副本出生点
tbFubenSetting.nStartDir				= 13;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/shanzhuang06_cam1.controller",
	[2] = "Scenes/camera/fb_shanzhuang06/fb_shanzhuang06.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 832,				nLevel = 30, nSeries = -1}, --无忧弟子 
	[2] = {nTemplate = 1486,			nLevel = 30, nSeries = -1}, --无忧杀手
	[3] = {nTemplate = 836,				nLevel = 31, nSeries = -1}, --无忧弟子精英
	[4] = {nTemplate = 1487,			nLevel = 32, nSeries = -1}, --无忧高级杀手
	[5] = {nTemplate = 841,				nLevel = 32, nSeries = 0}, --纳兰潜凛

	[7] = {nTemplate = 104,				nLevel = 30, nSeries = 0},	--动态障碍墙

	[8] = {nTemplate = 765,				nLevel = 32, nSeries = 0}, --杨影枫
	[9] = {nTemplate = 764,				nLevel = 32, nSeries = 0}, --纳兰真
	[10] = {nTemplate = 834,			nLevel = 32, nSeries = 0}, --月眉儿
	[11] = {nTemplate = 1348,			nLevel = 32, nSeries = 0}, --蔷薇
	[12] = {nTemplate = 1286,			nLevel = 32, nSeries = 0}, --紫轩
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1044, false},	
			--{"AddNpc", 6, 1, 3, "Start_Npc1", "Start_Npc1", 1, 13, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 20},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
			{"PlayCameraAnimation", 1, 2},
			{"PlayCameraEffect", 9060},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},
		    {"AddNpc", 7, 2, 0, "wall1", "wall_1_1", false, 32},
		  	{"AddNpc", 1, 2, 4, "menwei", "3_7_1_1", 1, 0, 0, 0, 0},----刷出门卫

			{"ChangeNpcFightState", "menwei", 0, 0},
			{"SetNpcProtected", "menwei", 1},
			
			
			---直接刷出Stage1中的怪-----
			{"AddNpc", 3, 1, 6, "guaiwu1", "Stage_1_2", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 6, 6, "guaiwu1", "Stage_1_1", 1, 0, 0, 0, 0},
			{"ChangeNpcFightState", "guaiwu1", 0, 0},
			{"SetNpcProtected", "guaiwu1", 1},
			
			{"AddNpc", 4, 1, 7, "guaiwu2", "3_7_2_2_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 3, 7, "guaiwu2", "3_7_2_2_2", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 7, "guaiwu2", "3_7_2_3_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 3, 7, "guaiwu2", "3_7_2_3_2", false, 0, 0, 0, 0},
			{"ChangeNpcFightState", "guaiwu2", 0, 0},		
			{"SetNpcProtected", "guaiwu2", 1},

			----直接刷出BOSS---
			{"AddNpc", 5, 1, 17, "BOSS", "3_7_6", 2, 48, 0, 0, 0},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"AddNpc", 1, 2, 15, "guaiwu4", "Stage_4_1_1", 2, 0, 0, 0, 0},
			{"AddNpc", 1, 2, 15, "guaiwu4", "Stage_4_1_2", 2, 60, 0, 0, 0},
			{"ChangeNpcFightState", "guaiwu4", 0, 0},
			{"SetNpcProtected", "guaiwu4", 1},

			----隱藏所有怪物头顶UI----
			{"SetHeadVisiable", "menwei", false, 0},
			{"SetHeadVisiable", "guaiwu1", false, 0},
			{"SetHeadVisiable", "guaiwu2", false, 3},
			{"SetHeadVisiable", "guaiwu4", false, 0},
			{"SetHeadVisiable", "BOSS", false, 0},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", true}, 
		    {"SetForbiddenOperation", false},
		    {"LeaveAnimationState", true},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 3},
 			{"SetTargetPos", 3843, 3009},		
		},
			tbUnLockEvent = 
		{
			{"AddAnger", 260}, 
			{"ClearTargetPos"},
			{"ChangeNpcFightState", "menwei", 1, 0},
			{"SetNpcProtected", "menwei", 0},
			{"SetNpcBloodVisable", "menwei", true, 0},
			{"NpcBubbleTalk", "menwei", "想要见到教主，先过我这关！", 3, 0.5, 1},

			{"SetHeadVisiable", "menwei", true, 0},
			{"SetHeadVisiable", "guaiwu1", true, 0},
			{"SetHeadVisiable", "BOSS", true, 0},	
			{"SetNpcBloodVisable", "BOSS", false, 0},		
		},
	},
	[4] = {nTime = 0, nNum = 2,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddAnger", 260}, 
			{"DoDeath", "wall1"},
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 7, 2, 0, "wall2", "wall_1_2",false, 16},
			{"SetTargetPos", 5081, 3058},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 5},
		},
		tbUnLockEvent = 
		{
			{"AddAnger", 260}, 
			{"ClearTargetPos"},
			{"ChangeNpcFightState", "guaiwu1", 1, 0},
			{"SetNpcProtected", "guaiwu1", 0},
			{"SetNpcBloodVisable", "guaiwu1", true, 0},
			{"NpcBubbleTalk", "guaiwu1", "今日定叫你有来无回！！", 4, 0.5, 1},
		},
	},
	[6] = {nTime = 0, nNum = 7,
		tbPrelock = {5},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetHeadVisiable", "guaiwu2", true, 0},
			{"ChangeNpcFightState", "guaiwu2", 1, 0},
			{"SetNpcProtected", "guaiwu2", 0},		
		},
	},
	[7] = {nTime = 0, nNum = 8,
		tbPrelock = {6},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "ops2"},
			{"AddNpc", 7, 1, 0, "wall3", "wall_1_3",false, 16},
			{"SetTargetPos", 5784, 6144},
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
			{"AddAnger", 260}, 
			{"ClearTargetPos"},
			{"AddNpc", 1, 4, 9, "guaiwu3", "Stage_3_1", 1, -1, 0, 0, 0},
			{"AddNpc", 2, 4, 9, "guaiwu3", "Stage_3_2", 1, -1, 2, 0, 0},
			{"AddNpc", 1, 4, 9, "guaiwu3", "Stage_3_3", 1, -1, 4, 0, 0},
		--	{"AddNpc", 7, 4, 9, "guaiwu3", "Stage_3_4", 1, -1, 6, 0, 0},			
			{"NpcBubbleTalk", "guaiwu3", "大伙一起上，将此人擒下交予教主！", 4, 2, 1},
		},
	},
	[9] = {nTime = 0, nNum = 12,
		tbPrelock = {8},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "ops3"},
			{"OpenDynamicObstacle", "ops4"},

			{"ChangeNpcFightState", "guaiwu4", 0, 0},
			{"SetNpcProtected", "guaiwu4", 1},
			--{"NpcBubbleTalk", "Start_Npc1", "无忧教的实力还真是不可小觑！", 4, 0, 1},
		},
	},
	
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock5", 10},
			{"ChangeTrap", "TrapLock5", nil, nil, nil, nil, nil, true},
			{"SetTargetPos", 3745, 8534},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "CloseDynamicObstacle", "ops4"},	
			{"AddNpc", 7, 2, 0, "wall2", "wall_1_4",false, 32},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"ShowAllRepresentObj", false},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},
		    {"PlayCameraAnimation", 2, 13},
		    {"PlayCameraEffect", 9126},
			{"PlayEffect", 9127, 0, 0, 0, 1},
			{"PlaySound", 48},
		},
		tbUnLockEvent = 
		{
			{"LeaveAnimationState", true},
			{"ShowAllRepresentObj", true},
		},
	},
	[11] = {nTime = 0, nNum = 1,											--剧情镜头
		tbPrelock = {13},
		tbStartEvent = 
		{
			--{"PlayCameraEffect", 9119},
			{"MoveCameraToPosition", 0, 3, 6054, 8566, 10},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},

			{"AddNpc", 8, 1, 0, "npc", "yangyingfeng", false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "npc1", "nalanzhen", false, 0, 0, 0, 0},
			{"AddNpc", 10, 1, 0, "npc2", "yuemeier", false, 0, 0, 0, 0},
			{"AddNpc", 11, 1, 0, "npc3", "qiangwei", false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 0, "npc4", "zixuan", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc", "Move", "path_yyf", 11, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "path_nlz", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "path_yme", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "path_qw", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "path_zx", 0, 1, 1, 0, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetNpcBloodVisable", "npc4", false, 0},
		},
		tbUnLockEvent = 
		{
			{"SetNpcDir", "npc", 48},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 12, 1102, false, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetNpcDir", "npc", 16},
			{"RaiseEvent", "ShowTaskDialog", 14, 1103, false, 2},
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"SetAllUiVisiable", true}, 
		    {"SetForbiddenOperation", false},
		    {"LeaveAnimationState", true},
		},
	},

	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"DelNpc", "npc1"},
		    {"DelNpc", "npc2"},
		    {"DelNpc", "npc3"},
		    {"DelNpc", "npc4"},
		    {"SetNpcBloodVisable", "npc", true, 0},
			{"SetHeadVisiable", "guaiwu4", true, 0},
			{"ChangeNpcFightState", "guaiwu4", 1, 0},
			{"SetNpcProtected", "guaiwu4", 0},

			{"NpcBubbleTalk", "guaiwu4", "哪里来的家伙，竟敢对教主无理！", 4, 0.5, 1},
			{"NpcBubbleTalk", "BOSS", "杨影枫，就让你见识一下我无忧教的实力吧！", 4, 0.5, 1},
			{"NpcBubbleTalk", "npc", "纳兰潜凛！今日就让我来终结你的野心吧！", 4, 3, 1},

			{"AddNpc", 3, 1, 0, "guaiwu4", "3_7_5_1_1", false, 0, 5, 0, 0},
			{"AddNpc", 4, 1, 0, "guaiwu4", "3_7_5_1_2", false, 0, 5, 0, 0},
			{"AddNpc", 2, 4, 0, "guaiwu5", "3_7_6_3", false, 0, 5, 9004, 0.5},

			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"ChangeNpcFightState", "BOSS", 1, 0},
			{"SetAiActive", "BOSS", 1},	

			{"NpcHpUnlock", "BOSS", 17, 30},
			{"BlackMsg", "击败纳兰潜凛！"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "guaiwu4"},
			{"DoDeath", "guaiwu5"},
		},
	},
	[18] = {nTime = 0.2, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"DelNpc", "BOSS"},
			{"DelNpc", "npc"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[20] = {nTime = 600, nNum = 0,
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

	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "GoPoint1", 30},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 3768, 8453},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
			{"TrapUnlock", "GoPoint2", 31},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4796, 8559},
		},
	},


	---------------------------剧情镜头-------------------
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 32, 1, 5700, 8564, 5},
			{"SetAllUiVisiable", false}, 
		    {"SetForbiddenOperation", true},
		    {"RaiseEvent", "ShowPartnerAndHelper", false},
		    {"RaiseEvent", "ShowPlayer", false},
		    --{"SetPos", 5071, 8574},

			{"AddNpc", 5, 1, 0, "BOSS", "nalanqianlin", false, 48, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"DoCommonAct", "BOSS", 36, 0, 1, 0},
			{"AddNpc", 8, 1, 0, "npc", "path_yyf", false, 48, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "npc1", "nalanzhen1", false, 64, 0, 0, 0},
			{"DoCommonAct", "npc1", 37, 0, 1, 0},
			{"AddNpc", 10, 1, 0, "npc2", "yuemeier1", false, 36, 0, 0, 0},
			{"AddNpc", 11, 1, 0, "npc3", "qiangwei1", false, 16, 0, 0, 0},
			{"AddNpc", 12, 1, 0, "npc4", "zixuan1", false, 16, 0, 0, 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetNpcBloodVisable", "npc4", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[33] = {nTime = 25, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "爹……你不要死……", 3, 0.5, 1},
			{"NpcBubbleTalk", "BOSS", "真儿……这是我咎由自取……你不要难过了……", 3, 3.5, 1},
			{"NpcBubbleTalk", "npc2", "……爹……", 3, 6.5, 1},
			{"NpcBubbleTalk", "BOSS", "眉儿……你终于肯叫我爹了……", 3, 9.5, 1},
			{"NpcBubbleTalk", "npc3", "爹……你的仇……影枫哥已经替你报了……", 3, 12.5, 1},
			{"NpcBubbleTalk", "npc", "唉……", 3, 15.5, 1},
			{"NpcBubbleTalk", "BOSS", "杨影枫……你要好好待我两个女儿……否则我……", 3, 18.5, 1},
			{"NpcBubbleTalk", "npc", "你放心，我会的。", 3, 21.5, 1},
			{"NpcBubbleTalk", "npc1", "……爹……", 3, 24.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
			{"BlackMsg", "一代枭雄纳兰潜凛死去了"},
		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", true}, 
		    {"SetForbiddenOperation", false},
		    {"LeaveAnimationState", true},
		    {"GameWin"},
		},
	},

	[35] = {nTime = 7.6, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[36] = {nTime = 2, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "BossReferral", "纳", "兰潜凛", "无忧教主、忘忧岛主"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
		},
	},
}
