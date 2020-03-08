
local tbFubenSetting = {};
Fuben:SetFubenSetting(150, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "白水之围"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/WLDS/NpcPos500-1.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/WLDS/NpcPath500-1.tab"		    -- 寻路点
tbFubenSetting.tbBeginPoint 			= {1985, 11065}											-- 副本出生点
tbFubenSetting.nStartDir				= 16;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	--[1] = "Scenes/camera/xuedi07_cam1.controller",
	--场景对象：baishuisi_cam1；动画名：baishuisi_cam1；特效：9221
}

--NPC模版ID，NPC等级，NPC五行；


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2722,			nLevel = -1,	nSeries = 0},  --旋风陷阱
	[2] = {nTemplate = 2723,			nLevel = -1,	nSeries = 0},  --毒水陷阱
	[3] = {nTemplate = 2724,			nLevel = -1,	nSeries = 0},  --射箭机关
	[4] = {nTemplate = 2725,			nLevel = -1,	nSeries = 0},  --巡逻金兵
	[5] = {nTemplate = 2726,			nLevel = -1,	nSeries = 0},  --支援金兵
	[6] = {nTemplate = 2727,			nLevel = -1,	nSeries = 0},  --boss

	[7] = {nTemplate = 2728,			nLevel = -1,	nSeries = 0},  --南宫飞云
	[8] = {nTemplate = 2729,			nLevel = -1,	nSeries = 0},  --完颜洪烈
	[9] = {nTemplate = 2730,			nLevel = -1,	nSeries = 0},  --报信探子

	[11] = {nTemplate = 2731,			nLevel = -1,	nSeries = 0},  --传送门
	[12] = {nTemplate = 104,			nLevel = -1,	nSeries = 0},  --动态障碍墙
}


--是否允许同伴出战
tbFubenSetting.bForbidPartner = true;
tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1139, false},	--剧情1
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"ChangeFightState", 1},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	[2] = {nTime = 1800, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetShowTime", 2},
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
			{"BlackMsg", "探查金方营地并找到南宫飞云"},
			{"TrapUnlock", "trap1", 3},	
			{"SetTargetPos", 3622, 11060},

			{"AddNpc", 1, 3, 0, "xj1", "xianjing1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 8, 0, "xj2", "xianjing2", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg1", "jiguan1", false, 32, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg2", "jiguan2", false, 1, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg3", "jiguan3", false, 32, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg4", "jiguan4", false, 1, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg5", "jiguan5", false, 32, 0, 0, 0},
			{"AddNpc", 3, 1, 0, "jg6", "jiguan6", false, 1, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 4, 5, 5210, 11032, 0},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},

			{"CastSkillCycle", "cycle1", "jg1", 3, 3744, 10, -1, -1},
			{"CastSkillCycle", "cycle2", "jg2", 3, 3744, 10, -1, -1},
			{"CastSkillCycle", "cycle3", "jg3", 3, 3744, 10, -1, -1},
			{"CastSkillCycle", "cycle4", "jg4", 3, 3744, 10, -1, -1},
			{"CastSkillCycle", "cycle5", "jg5", 3, 3744, 10, -1, -1},
			{"CastSkillCycle", "cycle6", "jg6", 3, 3744, 10, -1, -1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
		},
	},
	[5] = {nTime = 2, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
			--{"RaiseEvent", "ShowTaskDialog", 5, 1140, false},	--剧情2
			{"BlackMsg", "通过金军精心布下的机关陷阱！"},
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"LeaveAnimationState", true},
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1-1", 6},
			{"PlayerBubbleTalk", "金人果然狠毒，布下如此机关陷阱，这岂能难倒我？"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{	
			{"TrapUnlock", "trap2", 7},
			{"SetTargetPos", 8364, 11001},

			{"AddNpc", 4, 1, 0, "xl1", "xunluo1", 0, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "xl2", "xunluo2", 0, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "xl3", "xunluo3", 0, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "xl4", "xunluo4", 0, 0, 0, 0, 0},
			{"ChangeNpcAi", "xl1", "Move", "xunluo1_r", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "xl2", "Move", "xunluo2_r", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "xl3", "Move", "xunluo3_r", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "xl4", "Move", "xunluo4_r", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "xl1", 2402, 1, 1800},
			{"NpcAddBuff", "xl2", 2402, 1, 1800},
			{"NpcAddBuff", "xl3", 2402, 1, 1800},
			{"NpcAddBuff", "xl4", 2402, 1, 1800},

			{"AddNpc", 11, 1, 0, "cs", "chuansong", 0, 0, 0, 0, 0},		--传送门
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
			{"MoveCameraToPosition", 8, 5, 12674, 10988, 0},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true, false},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 9, 1140, false},		--剧情3
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"LeaveAnimationState", true},
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false, true},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"BlackMsg", "躲避金兵巡逻并进入元帅大营"},
			{"TrapUnlock", "trap_cs", 10},
		},
		tbUnLockEvent = 
		{
			{"DoPlayerCommonAct", 16, 0, 0, 0},
			
			{"CloseCycle", "cycle1"},
			{"CloseCycle", "cycle2"},
			{"CloseCycle", "cycle3"},
			{"CloseCycle", "cycle4"},
			{"CloseCycle", "cycle5"},
			{"CloseCycle", "cycle6"},

			{"DelNpc", "xl1"},
			{"DelNpc", "xl2"},
			{"DelNpc", "xl3"},
			{"DelNpc", "xl4"},
			{"DelNpc", "cs"},
			{"DelNpc", "xj1"},
			{"DelNpc", "xj2"},
			{"DelNpc", "jg1"},
			{"DelNpc", "jg2"},
			{"DelNpc", "jg3"},
			{"DelNpc", "jg4"},
			{"DelNpc", "jg5"},
			{"DelNpc", "jg6"},
		},
	},
	[100] = {nTime = 1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetPos", 7230, 1371},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"AddNpc", 12, 2, 0, "wall", "wall1", false, 64, 0, 0, 0},
			{"OpenWindow", "StoryBlackBg", "小心的躲过金兵巡逻后，终于进入了元帅的营帐...", nil, 5, 1, 0},

			{"TrapUnlock", "trap3", 11},

			{"AddNpc", 6, 1, 0, "boss", "boss", false, 48, 0, 0, 0},
			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcProtected", "boss", 1},
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
			{"RaiseEvent", "ShowTaskDialog", 12, 1141, false},		--剧情4
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetNpcBloodVisable", "boss", true, 0},
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},

			{"BlackMsg", "击败神秘武人"},
			{"NpcHpUnlock", "boss", 13, 15},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 5, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcProtected", "boss", 1},
			{"SetAiActive", "boss", 0},

			{"DoCommonAct", "boss", 3, 5007, 1, 0},		--重伤倒地
			{"NpcBubbleTalk", "boss", "咳咳...这或许就是我的宿命吧....哈哈哈....", 3, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "boss"},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 15},
			{"SetTargetPos", 9294, 1391},
			{"BlackMsg", "找到南宫飞云"},

			{"AddNpc", 7, 1, 0, "npc1", "nangongfeiyun", false, 16, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "npc2", "wanyanhonglie", false, 48, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 16, 3, 10135, 1433, 0},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true, false},	
		},
		tbUnLockEvent = 
		{
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 17, 1142, false},		--剧情5		
		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true, false},	
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 18, 1.5, 8028, 1381, 0},
			{"AddNpc", 9, 1, 0, "npc3", "boss", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 5, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc3", "元帅大人，属下有要事禀报！", 2, 0, 1},
			{"NpcBubbleTalk", "npc3", "什么？有刺客！", 2, 2, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc3", "来人哪，有刺客！", 3, 0, 1},
			{"ChangeNpcAi", "npc3", "Move", "tanzi", 20, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"SetNpcDir", "npc1", 48},
			{"LeaveAnimationState", true},
			{"RaiseEvent", "ShowTaskDialog", 21, 1143, false, 0.5},	--剧情6
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 5, nNum = 0,
		tbPrelock = {21},
		tbStartEvent = 
		{
			{"OpenWindow", "StoryBlackBg", "你们挟持着完颜洪烈离开大帅营帐去面对万千金兵...", nil, 5, 1, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true, false},	
			{"PlaySceneCameraAnimation", "baishuisi_cam1", "baishuisi_cam1", 23},
			{"PlayEffect", 9221, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[24] = {nTime = 5, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
			{"OpenWindow", "StoryBlackBg", "击伤完颜洪烈后，南宫大侠带着你施展绝世轻功离开了金军大营...", nil, 5, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},

-----------------------------------副本失败：被巡逻金兵发现------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"NpcFindEnemyUnlock", "xl1", 30},
			{"NpcFindEnemyUnlock", "xl2", 30},
			{"NpcFindEnemyUnlock", "xl3", 30},
			{"NpcFindEnemyUnlock", "xl4", 30},
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 10},
		},
	},
	[31] = {nTime = 5, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
			{"NpcRemoveBuff", "xl1", 2402},
			{"NpcRemoveBuff", "xl2", 2402},
			{"NpcRemoveBuff", "xl3", 2402},
			{"NpcRemoveBuff", "xl4", 2402},
			{"SetNpcRange", "xl1", 5000, 5000, 1},
			{"SetNpcRange", "xl2", 5000, 5000, 1},
			{"SetNpcRange", "xl3", 5000, 5000, 1},
			{"SetNpcRange", "xl4", 5000, 5000, 1},
			{"BlackMsg", "你被发现了，惊动了金军大营的兵马！"},
			{"NpcBubbleTalk", "xl1", "哪里来的家伙，竟敢擅闯大营！", 5, 1, 1},
			{"NpcBubbleTalk", "xl2", "真是不知死活！！", 5, 1, 1},
			{"NpcBubbleTalk", "xl3", "有刺客，来人！", 5, 1, 1},
			{"NpcBubbleTalk", "xl4", "兄弟们，出来干活啦！", 5, 1, 1},

			{"AddNpc", 5, 30, 0, "gw", "xunluo_gw", false, 0, 0.5, 9005, 0.5},
			{"SetNpcRange", "gw", 5000, 5000, 1.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[32] = {nTime = 8, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"OpenWindow", "StoryBlackBg", "你被巡逻的金兵发现，万千兵马涌来，你不得不狼狈撤退...", nil, 6, 3, 0},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},


}
