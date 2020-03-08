
local tbFubenSetting = {};
Fuben:SetFubenSetting(2, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "XinShouFuben";									-- 副本类型
tbFubenSetting.szName 					= "新手副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/XinshouFuben/NpcPos.tab"			        -- NPC点
tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/XinshouFuben/ExtNpcAwardInfo.tab"	        -- 掉落表
tbFubenSetting.szPathFile               = "Setting/Fuben/XinshouFuben/NpcPath.tab"			        -- 寻路点
tbFubenSetting.tbBeginPoint 			= {21482, 38881}									        -- 副本出生点
tbFubenSetting.nStartDir				= 40;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM =
{
}
tbFubenSetting.ANIMATION =
{
	[1] = "Scenes/camera/cj_xinshouguan02/xsg_cam4.controller",   --眨眼
}

tbFubenSetting.NPC =
{
	[1] = {nTemplate = 1150, nLevel = 50, nSeries = 0},--重伤士兵
	[4] = {nTemplate = 1151, nLevel = 50, nSeries = 0},--金兵
	[5] = {nTemplate = 1158, nLevel = 50, nSeries = 0},--金兵头目
	[6] = {nTemplate = 2711, nLevel = 30, nSeries = 0},--金征南将军
	[7] = {nTemplate = 1153, nLevel = 50, nSeries = 0},--将军
	[10] = {nTemplate = 452, nLevel = 1, nSeries = 0},--指引圈
	[11] = {nTemplate = 74, nLevel = 1, nSeries = 0},--上升气流
	[12] = {nTemplate = 104, nLevel = 1, nSeries = 0},--墙
	[13] = {nTemplate = 2712, nLevel = 50, nSeries = 0},--尸体
	[14] = {nTemplate = 2713, nLevel = 50, nSeries = 0},--尸体
	[15] = {nTemplate = 2714, nLevel = 50, nSeries = 0},--尸体
	[16] = {nTemplate = 2715, nLevel = 50, nSeries = 0},--尸体
	[17] = {nTemplate = 2716, nLevel = 50, nSeries = 0},--尸体
	[18] = {nTemplate = 2717, nLevel = 50, nSeries = 0},--尸体
}

tbFubenSetting.LOCK =
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 13, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent =
		{
			{"SetNearbyRange", 5},
		    {"PreLoadWindow", "CreateNameInput"},		--预加载界面
		    --{"SetDialogueSoundScale", 250},
		    {"OpenWindowAutoClose", "StoryBlackBg", "南宋初年，完颜洪烈挥师百万南下，意图覆灭大宋。由于宋朝将寡兵疲，金军一路势如破竹，竟直逼襄阳城下。在此国难当头之际，武林盟主独孤剑率领江湖有识之士星夜驰援襄阳……", nil, 2, 3, 0},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
			{"RaiseEvent", "Tlog", 2},
			{"AddNpc", 13, 3, 0, "shiti", "shiti1", false, 16, 0, 0, 0},
			{"AddNpc", 14, 3, 0, "shiti", "shiti2", false, 16, 0, 0, 0},
			{"AddNpc", 15, 1, 0, "shiti", "shiti3", false, 16, 0, 0, 0},
			{"AddNpc", 16, 1, 0, "shiti_1", "shiti4", false, 16, 0, 0, 0},
			{"AddNpc", 17, 1, 0, "shiti", "shiti5", false, 16, 0, 0, 0},
			--{"AddNpc", 18, 1, 0, "shiti", "shiti6", false, 16, 0, 0, 0},

			{"SetNpcProtected", "shiti", 1},
			{"SetHeadVisiable", "shiti", false, 2},
			{"SetNpcProtected", "shiti_1", 1},
			{"SetHeadVisiable", "shiti_1", false, 2},
			{"DoCommonAct", "shiti", 3, 5005, 1, 0},
			{"DoCommonAct", "shiti_1", 3, 5007, 1, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent =
		{
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent =
		{
			{"ChangeFightState", 1},
			{"BlackMsg", "前去支援，守住襄阳城！"},
			--{"OpenWindow", "RockerGuidePanel"},
		    {"OpenWindow", "RockerGuideNpcPanel", "按住[FFFE0D]左边的摇杆[-]不松，然后滑动手指\n移动到[FFFE0D]光圈[-]内！"},     --指引行走
		    {"PlayHelpVoice", "Setting/NpcVoice/13-A.voice"},
		    {"SetForbiddenOperation", true, true},           --禁止操作
		    {"SetGuidingJoyStick", true},              --显示摇杆
			{"TrapUnlock", "zhiyin1", 2},
			{"AddNpc", 10, 1, 0, "zy", "zhiyin1", false, 0, 0, 0, 0},
			{"SetTargetPos", 21279, 38319},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
		    {"CloseWindow", "RockerGuideNpcPanel"},     --指引行走关闭
		    {"SetForbiddenOperation", false, true},
		    {"SetGuidingJoyStick", false},
			{"DelNpc", "zy"},
			{"OpenWindow", "QYHLeavePanel", "XinShouFuben", {BtnChallenge=true}},     --需要在指引关闭后
			{"RaiseEvent", "ShowTaskDialog", 3, 993, false},
		},
	},
	[3] = {nTime = 0, nNum = 2,
		tbPrelock = {2},
		tbStartEvent =
		{
			{"TrapUnlock", "zhiyin2", 3},
			{"AddNpc", 10, 1, 0, "zy", "zhiyin2", false, 0, 0, 0, 0},
			{"SetTargetPos", 21268, 37569},

			{"AddNpc", 5, 1, 5, "jy", "jingying1", false, 0, 0, 0, 0},
			{"AddNpc", 4, 7, 5, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"SetNpcBloodVisable", "jy", false, 0.2},
			{"SetNpcBloodVisable", "gw", false, 0.2},
			{"SetNpcProtected", "jy", 1},
			{"SetNpcProtected", "gw", 1},
		},
		tbUnLockEvent =
		{
			{"AddNpc", 12, 1, 0, "wall", "wall_1", false, 32},
			{"ClearTargetPos"},
			{"DelNpc", "zy"},
			{"BlackMsg", "继续前进！"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent =
		{
			{"TrapUnlock", "trap1", 4},
			{"AddNpc", 10, 1, 0, "zy", "zhiyin3", false, 0, 0, 0, 0},
			{"SetTargetPos", 21228, 36750},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"DelNpc", "zy"},

			{"BlackMsg", "击杀守桥金兵！"},
			{"SetNpcBloodVisable", "jy", true, 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcProtected", "jy", 0},
			{"SetNpcProtected", "gw", 0},

			{"NpcBubbleTalk", "jy", "花里不阿将军这招围点打援真是高啊，你看又来一个送死的！", 4, 0, 1},
			{"NpcBubbleTalk", "gw", "来一个杀一个，来两个杀一双！", 4, 1, 1},
		},
	},
	[5] = {nTime = 0, nNum = 8,
		tbPrelock = {2},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"CloseWindow", "Guide"},     --指引技能关闭
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent =
		{
			{"BlackMsg", "前往襄阳城下！"},
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 22444, 36199},
		},
		tbUnLockEvent =
		{
			{"DoPlayerCommonAct", 1, 0, 0, 0},
			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent =
		{
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		    {"PlayEffect", 9208, 0, 0, 0, true},

		    {"SetPlayerProtected", 1},
		    {"RaiseEvent", "PlaySceneCameraAnimation", 1, 7},     ---------金兵动画
		},
		tbUnLockEvent =
		{
			{"SetPlayerProtected", 0},
			{"SetPos", 23099, 36018},
			{"AddNpc", 12, 2, 0, "wall", "wall_2", false, 16},
		},
	},

	[23] = {nTime = 1, nNum = 0,			--传送玩家
		tbPrelock = {6},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{

			{"SetPos", 21290, 35492},
		},
	},
	[24] = {nTime = 0.3, nNum = 0,
		tbPrelock = {23},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetPlayerDir", 9},		--设置朝向
		},
	},

	[8] = {nTime = 0, nNum = 11,
		tbPrelock = {7},
		tbStartEvent =
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"AddNpc", 5, 1, 8, "jy", "jingying2", false, 48, 0, 0, 0},
			{"AddNpc", 4, 10, 8, "gw", "guaiwu2", false, 48, 0, 0, 0},

			{"NpcBubbleTalk", "jy", "乌图鲁这个废物，让他守个桥都守不住！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "拿下襄阳！", 4, 1, 1},
		},
		tbUnLockEvent =
		{
			{"AddNpc", 1, 1, 0, "npc", "npc", false, 48, 0, 0, 0},
			{"BlackMsg", "前去查看伤兵伤势"},
			{"DoCommonAct", "npc", 36, 0, 1, 0},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs2"},
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			{"TrapUnlock", "npc", 20},
			{"SetTargetPos", 23811, 34648},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent =
		{
			{"RaiseEvent", "ShowTaskDialog", 21, 994, false},
		},
		tbUnLockEvent =
		{
			{"OpenDynamicObstacle", "yinxing"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {21},
		tbStartEvent =
		{
			{"AddNpc", 11, 1, 0, "qg", "qinggong", false, 0, 0, 0, 0},--轻功点
			{"TrapUnlock", "qinggong", 9},
			{"SetTargetPos", 23571, 34259},
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
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"ClearTargetPos"},
			{"SetPos", 16795, 37930},
		    {"PlayEffect", 9209, 0, 0, 0, true},
		    {"PlayFactionEffect", {{9201, 9275}, {0, 9194}, {0, 9198}, {9203, 9322}, {9205, 9231}, {9326, 9200}, {9197, 0}, {0, 9193}, {9204, 0}, {9252, 9196}, {9195, 9967}, {0, 9202}, {9207, 0}, {0, 9192}, {9206, 9199}, {9230, 9229}, {9253, 9254}, {9276, 9274}, {9320, 9321}, {9969, 9968}, {9327, 9328}}},   --------轻功特效
		    {"RaiseEvent", "PlaySceneCameraAnimation", 2, 10},    ----------轻功动画
		},
		tbUnLockEvent =
		{
		    --{"BlackMsg", "少侠跳的真远！"},
		    --{"SetTargetPos", 18480, 17630},
		    {"SetPos", 18458, 18548},
		    {"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
		},
	},
	[11] = {nTime = 0, nNum = 9,
		tbPrelock = {10},
		tbStartEvent =
		{
			{"AddNpc", 12, 2, 0, "wall", "wall_3", false, 16},
			{"AddNpc", 5, 1, 11, "jy", "jingying3", false, 0, 0, 0, 0},
			{"AddNpc", 4, 8, 11, "gw", "guaiwu3", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "jy", "宋国之中果有人物！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "拿下襄阳！", 4, 1, 1},
		},
		tbUnLockEvent =
		{
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs3"},
		},
	},
	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{
			{"TrapUnlock", "boss", 22},
			{"SetTargetPos", 18473, 16811},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent =
		{
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"PlayEffect", 9215, 0, 0, 0, true},
			{"RaiseEvent", "PlaySceneCameraAnimation", 3, 12},
		},
		tbUnLockEvent =
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"CloseWindow", "BossReferral"},
		},
	},
	[50] = {nTime = 5, nNum = 0,
		tbPrelock = {22},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"OpenWindowAutoClose", "BossReferral", "完", "颜华黎", "金征南将军"},
		},
	},
	[13] = {nTime = 0.1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent =
		{
			{"AddNpc", 6, 1, 0, "boss", "boss", false, 0, 0, 0, 0},
		    {"AddNpc", 5, 1, 0, "jy", "jingying4", false, 0, 0, 0, 0},
			{"AddNpc", 4, 12, 0, "gw", "guaiwu4", false, 0, 0, 0, 0},
		},
		tbUnLockEvent =
		{
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent =
		{
			{"NpcHpUnlock", "boss", 14, 50},
		},
		tbUnLockEvent =
		{
			{"PlayEffect", 9101, 0, 0, 0, true},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"DoDeath", "jy"},
			{"DoDeath", "gw"},
			{"SetPos", 18576, 16550},
			{"SetPlayerDir", 42},
			{"DelNpc", "boss"},
			{"AddNpc", 6, 1, 0, "boss", "boss", false, 0, 0, 0, 0},
			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcProtected", "boss", 1},
			{"SetHeadVisiable", "boss", false, 0},
			{"PlayEffect", 9210, 0, 0, 0, true},
		    {"PlaySceneAnimation", "cj_xinshouguan02_chuan01_s02", "baozha", 1, false},
		    {"SetAiActive", "boss", 0},
		    {"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		    {"RaiseEvent", "PlaySceneCameraAnimation", 4, 39},   ---------船毁动画
		},
	},
	[17] = {nTime = 1, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[18] = {nTime = 2, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[19] = {nTime = 3, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[25] = {nTime = 4, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[15] = {nTime = 5, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			--{"DoCommonAct", "boss", 16, 0, 0, 0},
		    --{"DoPlayerCommonAct", 16, 0, 0, 0},
			{"DoPlayerCommonAct", 26, 0, 0, 0},
			{"DoCommonAct", "boss", 26, 0, 0, 0},
		},
	},
	[26] = {nTime = 6, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 1, 0},
		    {"DoPlayerCommonAct", 16, 0, 1, 0},
		},
	},
	[27] = {nTime = 7, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[28] = {nTime = 8, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[29] = {nTime = 9, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[31] = {nTime = 10, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[32] = {nTime = 11, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoCommonAct", "boss", 16, 0, 0, 0},
		    {"DoPlayerCommonAct", 16, 0, 0, 0},
		},
	},
	[16] = {nTime = 12, nNum = 0,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DoPlayerCommonAct", 26, 0, 0, 0},
			{"DoCommonAct", "boss", 26, 0, 0, 0},
		},
	},
	----------技能使用指引---------------
	[30] = {nTime = 0, nNum = 1,           --指引技能使用
		tbPrelock = {4},
		tbStartEvent =
		{
		    {"OpenGuide", 30, "PopT", "请点击使用武功", "HomeScreenBattle", "Skill2", {0, -40}, false, true, true},
		    {"PlayHelpVoice", "Setting/NpcVoice/14-A.voice"},
		    --{"SetForbiddenOperation", false},
		},
		tbUnLockEvent =
		{
			{"CloseWindow", "Guide"},     --指引技能关闭
		},
	},
	-----------------角色取名流程---------

	[39] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		    {"SetGameWorldScale", 1},
		    {"RaiseEvent", "OpenBgBlackAll"},--全黑
		},
	},

	[40] = {nTime = 0.2, nNum = 0,--黑屏延迟后打开，不然层级有问题
		tbPrelock = {39},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		},
	},
	[41] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent =
		{
			{"RaiseEvent", "ShowTaskDialog", 41, 1081, false},      --剧情1
			{"PreLoadWindow", "CreateNameInput"},

		},
		tbUnLockEvent =
		{
		},
	},
	[42] = {nTime = 4.6, nNum = 0,
		tbPrelock = {41},
		tbStartEvent =
		{
		    {"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"PlayEffect", 9216, 0, 0, 0, true},
			{"PlayCameraAnimation", 1, 0},
		},
		tbUnLockEvent =
		{
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {42},
		tbStartEvent =
		{
			{"CloseWindow", "QYHLeavePanel"},
			{"RaiseEvent", "OpenBgBlackAll"},			--测试关闭
			{"RaiseEvent", "ShowTaskDialog", 43, 1082, false},    --  剧情2 --到你叫什么名字
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "ShowTaskDialog", 0, 1083, false},      --剧情3 --我叫。。。。。
			{"SetAllUiVisiable", false},
			{"RaiseEvent", "OpenCreatNamePanel"},			--测试关闭
			{"RaiseEvent", "Tlog", 6},
		},
	},

	[44] = {nTime = 0, nNum = 1, --代码里起名字成功解锁
		tbPrelock = {43},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		},
	},
	[45] = {nTime = 0, nNum = 1,
		tbPrelock = {44},
		tbStartEvent =
		{

			{"RaiseEvent", "ShowTaskDialog", 45, 1084, false},      --剧情4 名字不错。。。。。
		},
		tbUnLockEvent =
		{
			{"SetAllUiVisiable", false},
			{"RaiseEvent", "PostXinshouData", 8},			--测试关闭
			{"GameWin"},
		},
	},

	[46] = {nTime = 3000, nNum = 0, --计时
		tbPrelock = {1},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"GameLost"},
		},
	},

	[47] = {nTime = 0.1, nNum = 0,  --播放镜头动画延迟关闭黑屏
		tbPrelock = {41},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		    {"CloseWindow", "BgBlackAll"},
		},
	},
}

