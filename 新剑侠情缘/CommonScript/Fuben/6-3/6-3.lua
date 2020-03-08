
local tbFubenSetting = {};
Fuben:SetFubenSetting(49, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/6_3/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/5_7/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/6_3/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1957, 5705}											-- 副本出生点
tbFubenSetting.nStartDir				= 38;




-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/luoyegu06/luoyegu06_chuchang.controller",
	[2] = "Scenes/camera/luoyegu06/luoyegu06_taouzou.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1402,		nLevel = -1, nSeries = -1},  --五色教徒
	[2] = {nTemplate = 1403,		nLevel = -1, nSeries = -1},  --五色教杀手
	[3] = {nTemplate = 1405,		nLevel = -1, nSeries = -1},  --无相
	[4] = {nTemplate = 747,			nLevel = -1, nSeries = 0},  --独孤剑
	[5] = {nTemplate = 853,			nLevel = -1, nSeries = 0},  --张琳心
	[6] = {nTemplate = 1404,		nLevel = -1, nSeries = 0},  --狗肉和尚


	[9] = {nTemplate = 104,			nLevel = -1, nSeries = 0},  --动态障碍墙
}

--是否允许同伴出战
--tbFubenSetting.bForbidPartner = true;
--tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1072, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
		},
	},
	[2] = {nTime = 600, nNum = 0,		--总计时
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
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 1701, 5249},
			{"AddNpc", 9, 1, 0, "wall", "men1",false, 45},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 4, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 1, 4, 4, "gw", "guaiwu2", false, 0, 2, 9005, 0.5},
			--{"AddNpc", 1, 6, 0, "gw", "guaiwu2_1", false, 0, 4, 0, 0},
			{"BlackMsg", "看来五色教的人已经开始行动了！"},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},

	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 1752, 1695},
			--{"BlackMsg", "看来五色教早来一步，武夷派怕是凶多吉少了！"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 1, 0, "wall", "men2",false, 36},
		},
	},
	[6] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 6, 6, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 2, 6, "gw", "guaiwu4", false, 0, 2, 0, 0},
			--{"AddNpc", 1, 8, 0, "gw", "guaiwu4_1", false, 0, 4, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
			--{"BlackMsg", "居然还有高手，林对儿在此处干嘛？"},
		},
	},

	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "gopos1", 100},
			{"SetTargetPos", 3381, 562},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 4415, 1380},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 9, 1, 0, "wall", "men3",false, 32},
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 8,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 8, "gw", "guaiwu5", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 8, "gw", "guaiwu6", false, 0, 2, 0, 0},
			--{"AddNpc", 1, 8, 0, "gw", "guaiwu4_1", false, 0, 4, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
			{"DoDeath", "wall"},
			--{"BlackMsg", "居然还有高手，林对儿在此处干嘛？"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "gopos2", 9},
			{"SetTargetPos", 3999, 2819},
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
			{"TrapUnlock", "gopos3", 10},
			{"SetTargetPos", 5401, 3435},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 11},
			{"SetTargetPos", 4783, 3990},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[101] = {nTime = 0, nNum = 8,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 101, "gw", "guaiwu7", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 101, "gw", "guaiwu8", false, 0, 2, 0, 0},
			--{"AddNpc", 1, 8, 0, "gw", "guaiwu4_1", false, 0, 4, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},

	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap5", 12},
			{"SetTargetPos", 5109, 5137},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	-- [12] = {nTime = 0, nNum = 1,
	-- 	tbPrelock = {11},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"AddNpc", 3, 1, 0, "boss", "boss", false, 8, 0, 0, 0},
	-- 		{"NpcHpUnlock", "boss", 12, 30},
	-- 		{"SetNpcProtected", "boss", 1},
	-- 		{"SetNpcBloodVisable", "boss", false, 0},
	-- 		{"SetAiActive", "boss", 0},
	-- 		{"ChangeNpcFightState", "boss", 0, 0},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 		{"DoDeath", "gw"},
	-- 	},
	-- },

	---------------结束剧情------------------
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 13, 2, 5883, 5003, 0},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"AddNpc", 4, 1, 0, "npc", "dugujian", false, 8, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc1", "zhanglinxin", false, 8, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "npc2", "gourouheshang", false, 40, 0, 0, 0},

			{"SetNpcProtected", "npc2", 1},

			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"ChangeNpcFightState", "npc", 0, 0},
			{"ChangeNpcFightState", "npc1", 0, 0},
			{"ChangeNpcFightState", "npc2", 0, 0},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
	},
	[14] = {nTime = 8, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "我们就在这里躲起来。", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "那个黄剑堂堂主会上钩吗？", 3, 2, 1},
			{"NpcBubbleTalk", "npc1", "你放心吧，他一定会来！", 3, 4, 1},
			{"NpcBubbleTalk", "npc1", "他来了！", 3, 6, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 0, 2, 5694, 5801, 0},
			--{"SetForbiddenOperation", true},
			--{"SetAllUiVisiable", false},

			{"AddNpc", 3, 1, 0, "boss", "boss", false, 8, 0, 0, 0},
			{"SetNpcProtected", "boss", 1},
			{"SetNpcBloodVisable", "boss", false, 0},
			{"ChangeNpcFightState", "boss", 0, 0},
			{"ChangeNpcAi", "boss", "Move", "path3", 15, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 4, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"SetNpcDir", "boss", 8},
			{"SetAiActive", "boss", 0},
			{"NpcBubbleTalk", "npc2", "堂主，救……救我……", 3, 0, 1},
			{"NpcBubbleTalk", "boss", "要怪就怪你自己太笨！", 3, 2, 1},
			{"NpcBubbleTalk", "npc2", "啊？！你？！", 3, 4, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[17] = {nTime = 1, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
			{"CastSkill", "boss", 2384, 1, 5817, 5913},
		},
		tbUnLockEvent = 
		{
			{"DoCommonAct", "npc2", 3, 0, 0, 0},
		},
	},
	[19] = {nTime = 1, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoCommonAct", "npc2", 36, 0, 1, 0},
		},
	},
	[20] = {nTime = 0, nNum = 2,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "path1", 20, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "path2", 20, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc", "原来黄剑堂堂主竟然是你！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[21] = {nTime = 12, nNum = 0,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"SetNpcDir", "boss", 40},
			{"NpcBubbleTalk", "boss", "原来你们……", 4, 0, 1},
			{"NpcBubbleTalk", "npc1", "我们当然没走，不这样，怎么能引你出来呢？", 4, 2, 1},
			{"NpcBubbleTalk", "npc", "无相！放下屠刀，立地成佛。你这是何苦？", 4, 4, 1},
			{"NpcBubbleTalk", "boss", "哼！区区一个戒律院首座，我可不甘心。时至今日，有死而已，你们上吧。", 4, 7, 1},
			{"NpcBubbleTalk", "npc1", "哼！你这样的少林叛徒，看招！", 4, 10, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {21},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowPlayer", true},
			{"RaiseEvent", "ShowPartnerAndHelper", true},

			{"NpcHpUnlock", "boss", 22, 30},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},
			{"SetNpcBloodVisable", "boss", true, 0},
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},

			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},

			{"BlackMsg", "击败无相"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},

			{"MoveCameraToPosition", 23, 1.5, 5672, 5792, 0},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"SetNpcProtected", "boss", 1},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "boss", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[24] = {nTime = 2.5, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "boss", "黄毛小儿，竟敢戏弄于我！我一定不会放过你的！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
			--{"NpcAddBuff", "boss", 2452, 1, 100},
			--{"ChangeNpcAi", "boss", "Move", "path4", 0, 0, 0, 1, 0},
		},
	},
	[25] = {nTime = 0, nNum = 1,
		tbPrelock = {27},
		tbStartEvent = 
		{
			{"DelNpc", "boss"},
			{"RaiseEvent", "ShowTaskDialog", 25, 1073, false, 1},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
----------------------------动画添加------------
	[26] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			--{"LeaveAnimationState", true},
			{"ShowAllRepresentObj", false},
			{"PlayCameraAnimation", 1, 26},
			{"PlayEffect", 9142, 0, 0, 0, 1},
			{"PlayCameraEffect", 9140},
			{"PlaySound", 50},
		},
		tbUnLockEvent = 
		{
			{"LeaveAnimationState", true},
			{"ShowAllRepresentObj", true},
			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
	},

	[27] = {nTime = 0, nNum = 1,
		tbPrelock = {24},
		tbStartEvent = 
		{
			{"LeaveAnimationState", true},
			{"ShowAllRepresentObj", false},
			{"PlayCameraAnimation", 2, 27},
			{"PlayEffect", 9143, 0, 0, 0, 1},
			{"PlayCameraEffect", 9141},
		},
		tbUnLockEvent = 
		{
			{"LeaveAnimationState", true},
			{"ShowAllRepresentObj", true},
		},
	},

	[28] = {nTime = 9.3, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[29] = {nTime = 1, nNum = 0,
		tbPrelock = {28},
		tbStartEvent = 
		{
			{"OpenWindow", "BossReferral", "无", "相", "戒律院首座"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
		},
	},

}