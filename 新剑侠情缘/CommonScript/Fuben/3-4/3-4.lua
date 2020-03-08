
local tbFubenSetting = {};
Fuben:SetFubenSetting(33, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_4/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {3259, 10812}											-- 副本出生点
tbFubenSetting.nStartDir				= 32;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate  = 832,		nLevel = 24, nSeries = -1},  --无忧弟子
	[2] = {nTemplate  = 836,		nLevel = 24, nSeries = -1},  --无忧高级弟子
	[3] = {nTemplate  = 837,		nLevel = 26, nSeries = -1},  --禁地守卫-首领
	[4] = {nTemplate  = 1600,		nLevel = 25, nSeries = 2},  --禁地护法
	[5] = {nTemplate  = 684,		nLevel = 26, nSeries = 0},  --杨影枫
	[6] = {nTemplate  = 1348,		nLevel = 26, nSeries = 0},  --蔷薇
	[7] = {nTemplate  = 838,		nLevel = 26, nSeries = 0},  --纳兰真
	[8] = {nTemplate  = 834,		nLevel = 26, nSeries = 0},  --月眉儿

	[9] = {nTemplate  = 104,		nLevel = 24, nSeries = 0},  --动态障碍墙

	[10] = {nTemplate  = 833,		nLevel = 26, nSeries = 0},  --无忧教徒-展示
	[11] = {nTemplate  = 835,		nLevel = 26, nSeries = 0},  --无忧教头目-展示
	[12] = {nTemplate = 1430,		nLevel = 26, nSeries = 0},  --滚石烈焰
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1036, false},
			--{"AddNpc", 5, 1, 0, "npc", "yangyingfeng", false, 40, 0, 0, 0},
			--{"AddNpc", 6, 1, 0, "npc1", "qiangwei", false, 40, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
			--{"RaiseEvent", "FllowPlayer", "npc", true},
			--{"RaiseEvent", "FllowPlayer", "npc1", true},
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
			{"SetTargetPos", 3299, 9476},
			{"AddNpc", 9, 1, 0, "wall", "men1",false, 16},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 4,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 4, "gw1", "guaiwu1", false, 32, 0, 0, 0},
			{"AddNpc", 4, 3, 4, "gw", "guaiwu2", false, 64, 0, 0, 0},
			{"SetNpcProtected", "gw", 1},
			{"SetNpcProtected", "gw1", 1},
			-- {"BlackMsg", "击败忽然出现的无忧弟子。"},
			-- {"NpcBubbleTalk", "npc", "有人！", 4, 0, 1},
			-- {"NpcBubbleTalk", "npc1", "小心呀！", 4, 2, 1},
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
			{"SetTargetPos", 3452, 3729},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 1, 0, "wall", "men2",false, 32},
		},
	},
	[6] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 6, 6, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 2, 6, "gw", "guaiwu4", false, 0, 1.5, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "npc", "看来此处很不平静！", 4, 0, 1},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 7237, 3333},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 1, 0, "wall", "men3",false, 16},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 0, "gw", "guaiwu5", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 1, 8, "gw", "guaiwu5", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 2, 0, "gw", "guaiwu6", false, 0, 2, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
			{"DoDeath", "wall"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 9},
			{"SetTargetPos", 7773, 7029},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	---------------结束剧情------------------
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 10, 2, 7735, 7927, 10},
			{"AddNpc", 5, 1, 0, "npc", "yangyingfeng", false, 64, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "npc1", "qiangwei", false, 64, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "npc2", "nalanzhen", false, 32, 0, 0, 0},
			{"AddNpc", 8, 1, 0, "npc3", "yuemeier", false, 32, 0, 0, 0},
			--{"RaiseEvent", "FllowPlayer", "npc", false},
			--{"RaiseEvent", "FllowPlayer", "npc1", false},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetAiActive", "npc2", 0},
			{"SetAiActive", "npc3", 0},
			{"ChangeNpcAi", "npc", "Move", "path1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "path2", 0, 1, 1, 0, 0},
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
			{"RaiseEvent", "ShowTaskDialog", 11, 1038, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "path3", 12, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc", "我们先离开吧！", 3, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc", "不好！有埋伏！", 3, 0, 1},
			{"SetNpcDir", "npc", 64},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "StoryBlackBg", "忽然周围出现一大群无忧教徒，将你们团团围住", nil, 2, 1, 1},
			{"AddNpc", 11, 1, 0, "sl", "shouling", false, 32, 0, 0, 0},
			{"SetNpcProtected", "sl", 1},
			{"SetNpcBloodVisable", "sl", false, 0},
			{"ChangeNpcAi", "sl", "Move", "path4", 0, 1, 1, 0, 0},
			{"NpcBubbleTalk", "sl", "嘿嘿，还想走？天真！", 6, 3, 1},
			{"RaiseEvent", "ShowTaskDialog", 14, 1039, false, 4},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "sl", "杨影枫，你还想轻举妄动？", 3, 0, 1},
			{"ChangeNpcAi", "sl", "Move", "path5", 15, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 16, 1093, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
			{"NpcBubbleTalk", "sl", "想救她们的话就来摘星楼吧。", 3, 0, 1},
			{"ChangeNpcAi", "sl", "Move", "path6", 0, 1, 1, 0, 0},
		},
	},
	[17] = {nTime = 3, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"DelNpc", "npc1"},
			{"DelNpc", "npc2"},
			{"DelNpc", "npc3"},
			{"DelNpc", "sl"},
			{"DelNpc", "gw"},
		},
	},
	[18] = {nTime = 1, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 2, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc", "我还是先去落叶谷找孟老前辈帮忙吧。", 3, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"GameWin"},
		},
	},
	[20] = {nTime = 1, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 10, 18, 0, "gw", "guaiwu7", false, 32, 0, 0, 0},
			{"SetNpcProtected", "gw", 1},
			{"SetAiActive", "gw", 0},
			{"SetNpcBloodVisable", "gw", false, 0},
		},
	},


	[21] = {nTime = 6, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"NpcBubbleTalk", "gw1", "什么人？", 3, 0, 1},
			{"SetNpcDir", "gw1", 64},
			{"NpcBubbleTalk", "gw1", "好大的胆子，擅闯无忧禁地！", 3, 2, 1},
			{"NpcBubbleTalk", "gw1", "让你们尝尝我禁地机关的厉害！", 4, 4, 1},

			{"AddNpc", 12, 1, 0, "jg1", "jiguan1", false, 0, 0, 0, 0},--机关
			{"AddNpc", 12, 1, 0, "jg2", "jiguan2", false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 0, "jg3", "jiguan3", false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 0, "jg4", "jiguan4", false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 0, "jg5", "jiguan5", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "jg1", "Move", "jpath1", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg2", "Move", "jpath2", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg3", "Move", "jpath3", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg4", "Move", "jpath4", 0, 0, 0, 0, 1},
			{"ChangeNpcAi", "jg5", "Move", "jpath5", 0, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "躲避机关，击败无忧弟子！"},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"SetNpcProtected", "gw", 0},
			{"SetNpcProtected", "gw1", 0},
		},
	},
}
