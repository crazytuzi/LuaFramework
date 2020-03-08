
local tbFubenSetting = {};
Fuben:SetFubenSetting(23, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/1_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_6/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/1_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2267, 2786}											-- 副本出生点
tbFubenSetting.nStartDir				= 56;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
	[2] = "Scenes/camera/bosscamer110.controller",
}

--NPC模版ID，NPC等级，NPC五行；

--[[
变身buff=2216
]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 768,						nLevel = 9,  nSeries = -1},	--恶狼
	[2] = {nTemplate = 767,						nLevel = 9,  nSeries = -1},  --蝎子
	[3] = {nTemplate = 738,						nLevel = 9,  nSeries = -1},  --蜘蛛
	[4] = {nTemplate = 740,						nLevel = 9,  nSeries = -1},  --大型蜘蛛
	[5] = {nTemplate = 5,						nLevel = 10,  nSeries = -1},  --骷髅
	[6] = {nTemplate = 764,						nLevel = -1,  nSeries = 0},  --纳兰真-走
	[7] = {nTemplate = 682,						nLevel = -1,  nSeries = 0},  --受伤的杨影枫

	[8] = {nTemplate = 104, 					nLevel = -1,  nSeries = 0},  --动态障碍墙

	[9] = {nTemplate = 680,						nLevel = -1,  nSeries = 0},  --纳兰真-跑
	[16] = {nTemplate = 742,					nLevel = 10,  nSeries = 0},	--玄天武机-变身
} 

tbFubenSetting.bForbidPartner = true;--隐藏同伴

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			--{"RaiseEvent", "ShowPartnerAndHelper", false},	
			{"RaiseEvent", "ShowTaskDialog", 1, 1009, false},						   --播放剧情对话
			{"AddNpc", 9, 1, 0, "Start_Npc1", "Start_Npc1", 1, 58, 0, 0, 0},	
			{"AddNpc", 7, 1, 0, "Start_Npc2", "Start_Npc2", 1, 58, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{			
			{"AddNpc", 8, 1, 1, "wall", "wall_1_1",false, 16},   --刷动态障碍墙
			{"AddNpc", 8, 1, 1, "wall", "wall_1_2",false, 32},
			{"SetShowTime", 19},
		},
	},
	
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			--{"RaiseEvent", "ShowPartnerAndHelper", true},
			{"ChangeFightState", 1},												--改变战斗状态
			{"SetTargetPos", 1900, 3833},										   --设置目标寻路点
			{"TrapUnlock", "TrapLock1", 2},										    --Trap点
		},	
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "CallPartner"},
			{"AddNpc", 2, 2, 3, "guaiwu1", "Stage_1_1", 1, 32, 0, 9005, 0.2},	
			{"AddNpc", 1, 1, 3, "guaiwu", "Stage_1_2", 1, 32, 1.5, 0, 0},	
			{"AddNpc", 2, 3, 3, "guaiwu", "Stage_1_3", 1, 32, 2.5, 0, 0},	
			{"BlackMsg", "去山洞深处会合！"},
			--{"NpcBubbleTalk", "guaiwu1", "来人止步，否则格杀勿论！！", 3, 0.5, 1},
		},
	},
	[3] = {nTime = 0, nNum = 6,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 1697, 5656},
		},
	},
	[4] = {nTime = 0, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops1"},										--解锁动态障碍
			{"DoDeath", "wall"},														--删除动态障碍墙
			{"AddNpc", 8, 1, 4, "wall", "wall_1_2",false, 32},
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
			{"ClearTargetPos"},			
		},
	},
	[6] = {nTime = 0, nNum = 9,		
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 4, 6, "guaiwu", "Stage_2_1", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "guaiwu", "Stage_2_2", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 6, "guaiwu", "Stage_2_3", 1, 0, 2, 9009, 0.5},
			{"AddNpc", 2, 2, 6, "guaiwu", "Stage_2_4", 1, 0, 2, 9009, 0.5},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4193, 5476},
			{"TrapCastSkill", "BuffPoint", 1508, 1, -1, -1, 1, 206, 3156, 5492},	
			{"DoDeath", "wall"},		
			{"OpenDynamicObstacle", "ops2"},	
			{"OpenDynamicObstacle", "ops3"},
		},
	},
	[7] = {nTime = 0, nNum = 1,		
		tbPrelock = {6},
		tbStartEvent = 
		{				
			{"TrapUnlock", "TrapLock3", 7},
		},
		tbUnLockEvent = 
		{
			{"BatchPlaySceneAnimation", "wyqf0", 1, 9, "Take 001", 0.8, true},
			{"BatchPlaySceneAnimation", "wyqf", 10, 11, "Take 001", 0.8, true},
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
			--{"NpcBubbleTalk", "guaiwu2", "哪里来的家伙，真是自寻死路！", 3, 0.5, 1},
			{"AddNpc", 8, 2, 9, "wall", "wall_1_4",false, 48},
		},
	},
	[9] = {nTime = 0, nNum = 9,		
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"AddNpc", 3, 6, 9, "guaiwu", "Stage_3_1", 1, 0, 0.5, 9009, 0.5},
			{"AddNpc", 2, 1, 9, "guaiwu", "Stage_3_2", 1, 8, 1.5, 0, 0},
			{"AddNpc", 4, 1, 9, "guaiwu", "Stage_3_3", 1, 39, 2.5, 0, 0},
			{"AddNpc", 1, 1, 9, "guaiwu", "Stage_3_4", 1, 29, 3.5, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	
	[10] = {nTime = 0, nNum = 8,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 2, 3, 10, "guaiwu", "Stage_4_1", 1, 0, 0, 9009, 0},
			{"AddNpc", 4, 1, 10, "guaiwu", "Stage_4_2", 1, 0, 0, 9009, 0},
			{"AddNpc", 3, 2, 10, "guaiwu", "Stage_4_3", 1, 0, 0, 9009, 0},
			{"AddNpc", 1, 2, 10, "guaiwu", "Stage_4_4", 1, 0, 0, 9009, 0},
			{"NpcAddBuff", "guaiwu", 2401, 1, 100},									--增加荆棘buff
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops4"},
			{"SetTargetPos", 5151, 3072},
			{"DoDeath", "wall"},
		},
	},
	[11] = {nTime = 0, nNum = 1,		
		tbPrelock = {10},
		tbStartEvent = 
		{		
			{"TrapUnlock", "TrapLock6", 11},		
		},
		tbUnLockEvent = 
		{
			{"PlayEffect", 2801, 0, 0, 0},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 12},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

	------------------boss镜头---------------------
	[13] = {nTime = 3, nNum = 0,					--boss出场
		tbPrelock = {36},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", true},		--禁止玩家操作
			{"SetAllUiVisiable", false}, 			--显示/隐藏UI
			{"PlayCameraAnimation", 2, 0},			--播放摄像机动画
			{"AddNpc", 5, 1, 16, "BOSS", "Stage_5_BOSS", false, 42},
			{"ChangeNpcCamp", "BOSS", 0},			--改变NPC所在阵营
			{"SetHeadVisiable", "BOSS", false},		--设置NPC头顶血条文字是否可见
		},
		tbUnLockEvent = 
		{
			{"PlaySceneAnimation", "fb_erengu_men01_open", "open", 1, false},  --播放场景动画
		},
	},
	[14] = {nTime = 0.5, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops5"},
		},
	},

	[15] = {nTime = 3, nNum = 0,
		tbPrelock = {102},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "BossReferral", "烈", "焰骷髅", "离忧山洞霸主"},
			{"DoCommonAct", "BOSS", 17, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
			{"RaiseEvent", "CloseDynamicObstacle", "ops5"},     --关闭动态障碍
			{"LeaveAnimationState", true},						--摄像机动画结束，视角切回玩家
			{"SetForbiddenOperation", false},					--解开操作
			{"SetAllUiVisiable", true}, 						--显示UI
			{"ChangeNpcCamp", "BOSS", 1},						--改变BOSS阵营
			{"SetHeadVisiable", "BOSS", true},					--显示BOSS血条以及名字

			{"SetNpcBloodVisable", "Start_Npc1", true, 0},
			{"SetNpcBloodVisable", "Start_Npc2", true, 0},
			{"RaiseEvent", "ShowPartnerAndHelper", true},

			{"NpcBubbleTalk", "BOSS", "这里就是你的葬身之地！", 3, 0.5, 1},
			{"NpcBubbleTalk", "Start_Npc1", "杨大哥，这个家伙...长得好丑啊！", 3, 2.5, 1},
			{"NpcBubbleTalk", "Start_Npc2", "没事，外强中干而已！", 3, 3.5, 1},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"AddNpc", 2, 4, 0, "guaiwu", "Stage_5_1", 1, 0, 0.5, 9009, 0.5},
			{"AddNpc", 3, 4, 0, "guaiwu", "Stage_5_2", 1, 0, 0.5, 9009, 0.5},
			{"AddNpc", 1, 2, 0, "guaiwu", "Stage_5_2", 1, 0, 1, 9009, 0.5},
			{"StartTimeCycle", "cycle", 8, 5, {"AddNpc", 1, 2, 0, "guaiwu", "Stage_5_1", false, 0, 0.5, 9009, 0.5}},
			{"StartTimeCycle", "cycle1", 8, 5, {"AddNpc", 2, 4, 0, "guaiwu", "Stage_5_1", false, 0, 0.5, 9009, 0.5}},
			{"StartTimeCycle", "cycle2", 8, 5, {"AddNpc", 3, 4, 0, "guaiwu", "Stage_5_2", false, 0, 0.5, 9009, 0.5}},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 19},
			{"StopEndTime"},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"CloseCycle", "cycle"},
			{"CloseCycle", "cycle1"},
			{"CloseCycle", "cycle2"},
		},
	},
	[17] = {nTime = 2.1, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.3},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"ResumeLock", 19},
			{"SetShowTime", 19},
		},
	},
	[18] = {nTime = 0, nNum = 2,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 18, 2, 5931, 2653, 10},

			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"SetNpcBloodVisable", "Start_Npc2", false, 0},
			{"RaiseEvent", "ShowPartnerAndHelper", false},

			{"ChangeNpcAi", "Start_Npc1", "Move", "npath1", 18, 1, 1, 0, 0},
			{"ChangeNpcAi", "Start_Npc2", "Move", "npath2", 0, 1, 1, 0, 0},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 300, nNum = 0,
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
	[20] = {nTime = 1, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "Start_Npc1", "这里什么都没有的样子，好无聊！", 3, 0, 1},
			{"NpcBubbleTalk", "Start_Npc2", "真儿，你在找什么呀？", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Start_Npc1", "Move", "npath3", 21, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 1, nNum = 0,
		tbPrelock = {21},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "Start_Npc1", "这也空无一物！", 3, 0, 1},
			{"NpcBubbleTalk", "Start_Npc2", "......", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "Start_Npc1", "Move", "npath4", 23, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[24] = {nTime = 2, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "Start_Npc1", "咦？这是什么？", 3, 0, 1},
			{"NpcBubbleTalk", "Start_Npc1", "啊......", 3, 2, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[25] = {nTime = 1, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
			{"DoCommonAct", "Start_Npc1", 26, 0, 0, 0},--掉下
			{"NpcAddBuff", "Start_Npc2", 2452, 1, 100},
			{"ChangeNpcAi", "Start_Npc2", "Move", "npath5", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "Start_Npc2", "真儿！！", 3, 0.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[26] = {nTime = 2, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
			{"DelNpc", "Start_Npc1"},
			{"BlackMsg", "纳兰真忽然掉了下去！"},
		},
		tbUnLockEvent = 
		{
			--{"SetAllUiVisiable", true},
			{"RemovePlayerSkillState", 2216},
			{"SetForbiddenOperation", false},
			{"GameWin"},
		},
	},
	---------------------技能指引---------------------
	--[28] = {nTime = 0, nNum = 1,		
	--	tbPrelock = {9},
	--	tbStartEvent = 
	--	{		
	--		{"TrapUnlock", "TrapLock7", 28},
	--		{"SetTargetPos", 4977, 5149},
	--	},
	--	tbUnLockEvent = 
	--	{
	--		{"ClearTargetPos"},
	--	},
	--},
	-- [29] = {nTime = 5, nNum = 1,   --指引怒气使用
	-- 	tbPrelock = {28},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"RaiseEvent", "PartnerSay", "怒气已满，可以[FFFE0D]施放大招[-]了！", 4, 1},
	-- 		{"OpenGuide", 29, "PopT", "请点击使用大招", "HomeScreenBattle", "Skill5", {0, -40}, false, true},--使用技能
	-- 		{"OpenWindowAutoClose", "RockerGuideNpcPanel", "点击箭头指引的[FFFE0D]怒气技能[-]可施放大招！"},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"CloseWindow", "Guide"},
	-- 		{"CloseWindow", "RockerGuideNpcPanel"},
	-- 	},
	-- },
	--[30] = {nTime = 5, nNum = 1,   --指引打坐使用
	--	tbPrelock = {10},
	--	tbStartEvent = 
	--	{
	--		{"RaiseEvent", "PartnerSay", "你受伤了！赶紧[FFFE0D]打坐疗伤[-]！！", 4, 1},
	--		{"RaiseEvent", "ChangeAutoFight", false},
	--		{"OpenGuide", 30, "PopT", "请点击使用打坐", "HomeScreenBattle", "BtnDazuo", {0, -40}, true, true},--使用技能
	--		{"OpenWindowAutoClose", "RockerGuideNpcPanel", "点击箭头指引的[FFFE0D]打坐技能[-]可进行生命恢复！"},
	--		{"PlayHelpVoice", "Setting/NpcVoice/23-A.voice"},
	--	},
	--	tbUnLockEvent = 
	--	{
	--		{"AddAnger", -300}, 
	--		{"CloseWindow", "Guide"},
	--		{"CloseWindow", "RockerGuideNpcPanel"},
	--	},
	--},
-------------------------------变身玩法---------------
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"AddNpc", 16, 1, 0, "bs", "bianshen", false, 8},
			{"AddNpc", 6, 1, 0, "Start_Npc1", "Start_Npc1_1", 1, 24, 0, 0, 0},	
			{"AddNpc", 7, 1, 0, "Start_Npc2", "Start_Npc2_1", 1, 24, 0, 0, 0},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
			{"SetNpcBloodVisable", "Start_Npc2", false, 0},

			{"MoveCameraToPosition", 32, 1.5, 5368, 2372, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{	
		},
	},
	
	[34] = {nTime = 7, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "Start_Npc1", "啊，这个是...我小时候玩的玄天武机？", 3, 0, 1},
			{"NpcBubbleTalk", "Start_Npc1", "没想到还能找到它！", 3, 2, 1},
			{"NpcBubbleTalk", "Start_Npc2", "好大啊！", 3, 4, 1},
			{"NpcBubbleTalk", "Start_Npc1", "少侠，你进去试试吧！", 3, 6, 1},
		},
		tbUnLockEvent = 
		{	
		},
	},
	[35] = {nTime = 3, nNum = 0,
		tbPrelock = {34},
		tbStartEvent = 
		{
			{"RaiseEvent", "PlayerRunTo", 5399, 2286},
		},
		tbUnLockEvent = 
		{	
		},
	},
	[36] = {nTime = 4, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{
			{"DelNpc", "bs"},
			{"AddBuff", 2216, 1, 300, 0, 0},
			{"NpcBubbleTalk", "Start_Npc1", "太好了！", 3, 0.5, 1},
			{"NpcBubbleTalk", "Start_Npc2", "好像有什么声音？", 3, 2.5, 1},
		},
		tbUnLockEvent = 
		{	
		},
	},

	[100] = {nTime = 1, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "Start_Npc1", "你们快点来呀！", 3, 0, 1},
			{"NpcAddBuff", "Start_Npc1", 2452, 1, 100},
			{"NpcAddBuff", "Start_Npc2", 2452, 1, 100},
			{"ChangeNpcAi", "Start_Npc1", "Move", "path1_1", 0, 0, 0, 1, 0},
		},	
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "Start_Npc2", "Move", "path1_2", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "Start_Npc2", "真儿等等我！", 3, 0, 1},
		},
	},

	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "BOSS", "Move", "Path4", 101, 1, 1, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[102] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 102, 0.5, 5813, 2615, -10},
		},
		tbUnLockEvent = 
		{
		},
	},
}
