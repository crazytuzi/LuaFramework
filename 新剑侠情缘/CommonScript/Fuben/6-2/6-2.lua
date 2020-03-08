
local tbFubenSetting = {};
Fuben:SetFubenSetting(48, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/6_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/5_5/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/6_2/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {7407, 4015}											-- 副本出生点
tbFubenSetting.nStartDir				= 48;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量


tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1394,		nLevel = -1, nSeries = -1},  --华山弟子
	[2] = {nTemplate = 1398,		nLevel = -1, nSeries = -1},  --华山派护法
	[3] = {nTemplate = 1399,		nLevel = -1, nSeries = -1},  --林海
	[4] = {nTemplate = 747,			nLevel = -1, nSeries = 0},  --独孤剑
	[5] = {nTemplate = 853,			nLevel = -1, nSeries = 0},  --张琳心
	[6] = {nTemplate = 1396,		nLevel = -1, nSeries = 0},  --林对儿
	[7] = {nTemplate = 1400,		nLevel = -1, nSeries = 0},  --方勉
	[8] = {nTemplate = 1401,		nLevel = -1, nSeries = 0},  --江湖人士

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
			{"RaiseEvent", "ShowTaskDialog", 1, 1069, false},
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
			{"SetTargetPos", 4976, 3619},
			{"AddNpc", 9, 2, 0, "wall", "men1",false, 16},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetNpcProtected", "gw", 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetAiActive", "gw", 1},
			{"SetNpcProtected", "gw1", 0},
			{"SetNpcBloodVisable", "gw1", true, 0},
			{"SetAiActive", "gw1", 1},
			{"NpcBubbleTalk", "gw1", "胆敢擅闯华山派，活得不耐烦了？", 5, 0, 1},
		},
	},
	[4] = {nTime = 0, nNum = 12,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 1, 10, 4, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 4, "gw1", "guaiwu2", false, 0, 0, 0, 0},
			{"SetNpcProtected", "gw", 1},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetAiActive", "gw", 0},
			{"SetNpcProtected", "gw1", 1},
			{"SetNpcBloodVisable", "gw1", false, 0},
			{"SetAiActive", "gw1", 0},
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
			{"SetTargetPos", 3177, 6749},
			--{"BlackMsg", "看来五色教早来一步，武夷派怕是凶多吉少了！"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 1, 0, "wall", "men2",false, 32},
			{"ChangeNpcAi", "gw", "Move", "path1", 0, 1, 1, 0, 0},
		},
	},
	[6] = {nTime = 0, nNum = 15,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"AddNpc", 1, 12, 6, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 3, 6, "gw", "guaiwu4", false, 0, 2, 9005, 0.5},
			--{"AddNpc", 1, 8, 0, "gw", "guaiwu4_1", false, 0, 4, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"OpenDynamicObstacle", "obs3"},
			{"DoDeath", "wall"},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 8378, 7522},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 2, 0, "wall", "men3",false, 32},
			{"RaiseEvent", "CloseDynamicObstacle", "obs3"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 8, "boss", "boss", false, 48, 0, 0, 0},
			{"AddNpc", 1, 16, 0, "gw", "guaiwu5_1", false, 32, 0, 0, 0},
			{"AddNpc", 1, 16, 0, "gw1", "guaiwu5_2", false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 0, "gw", "guaiwu6", false, 48, 0, 0, 0},

			{"SetNpcProtected", "boss", 1},
			{"SetNpcProtected", "gw", 1},
			{"SetNpcProtected", "gw1", 1},
			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetNpcBloodVisable", "gw1", false, 0},
			{"SetAiActive", "boss", 0},
			{"SetAiActive", "gw", 0},
			{"SetAiActive", "gw1", 0},
			{"ChangeNpcFightState", "boss", 0, 0},
			{"ChangeNpcFightState", "gw", 0, 0},
			{"ChangeNpcFightState", "gw1", 0, 0},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
		},
	},

	[9] = {nTime = 2.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},
		},
	},
	---------------结束剧情------------------
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 12, 2, 10057, 7508, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"AddNpc", 4, 1, 0, "npc", "dugujian", false, 16, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc1", "zhanglinxin", false, 16, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "npc2", "linduier", false, 16, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "npc3", "fangmian", false, 48, 0, 0, 0},
			{"AddNpc", 8, 4, 0, "npc4", "jianghurenshi", false, 48, 0, 0, 0},

			{"SetNpcProtected", "npc2", 1},
			{"SetNpcProtected", "npc3", 1},
			{"SetNpcProtected", "npc4", 1},
			{"SetAiActive", "npc2", 0},

			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},

			{"ChangeNpcFightState", "npc", 0, 0},
			{"ChangeNpcFightState", "npc1", 0, 0},
			{"ChangeNpcFightState", "npc2", 0, 0},
			{"ChangeNpcFightState", "npc3", 0, 0},
			{"ChangeNpcFightState", "npc4", 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 13, 1070, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},

	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"SetAiActive", "boss", 1},
			{"NpcAddBuff", "boss", 2452, 1, 100},
			{"ChangeNpcAi", "boss", "Move", "path3", 14, 1, 1, 0, 0},
			{"NpcBubbleTalk", "boss", "出招吧！", 5, 0, 1},

			{"MoveCameraToPosition", 0, 1, 9169, 7548, 5},
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "boss", 2452},
		},
	},
	[15] = {nTime = 1, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},
			{"DelNpc", "npc2"},
			{"SetNpcProtected", "boss", 0},
			{"SetNpcProtected", "gw", 0},
			{"SetNpcProtected", "gw1", 0},
			{"SetNpcBloodVisable", "boss", true, 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcBloodVisable", "gw1", true, 0},
			{"SetAiActive", "boss", 1},
			{"SetAiActive", "gw", 1},
			{"SetAiActive", "gw1", 1},
			{"ChangeNpcFightState", "boss", 1, 0},
			{"ChangeNpcFightState", "gw", 1, 0},
			{"ChangeNpcFightState", "gw1", 1, 0},

			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},

			{"ChangeNpcAi", "gw", "Move", "path2", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "gw1", "Move", "path2", 0, 1, 1, 0, 0},

			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
			{"BlackMsg", "击败林海！"},
		},
	},
	[16] = {nTime = 0.5, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"DelNpc", "npc3"},
			{"DelNpc", "npc4"},
			{"DelNpc", "npc"},
			{"DelNpc", "npc1"},
			{"PlayCameraEffect", 9119},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},

			{"ChangeCameraSetting", 23, 35, 20},	--摄像机高度
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowPlayer", false},	--隐藏主角
			{"RaiseEvent", "ShowPartnerAndHelper", false},

			{"AddNpc", 3, 1, 0, "boss", "boss1", false, 48, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "npc", "dugujian", false, 48, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc1", "zhanglinxin", false, 48, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "npc2", "linduier", false, 48, 0, 0, 0},

			{"SetNpcProtected", "boss", 1},
			{"SetNpcBloodVisable", "boss", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetAiActive", "boss", 0},
			{"ChangeNpcFightState", "boss", 0, 0},
			{"ChangeNpcFightState", "npc", 0, 0},
			{"ChangeNpcFightState", "npc1", 0, 0},
			{"ChangeNpcFightState", "npc2", 0, 0},

			{"DoCommonAct", "boss", 36, 0, 1, 0},	--林海尸体
		},
	},

	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 17, 1, 9632, 7529, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[18] = {nTime = 7, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc2", "想不到林海为了贪图掌门之位，竟不惜投靠五色教……", 3, 0.5, 1},
			{"NpcBubbleTalk", "npc1", "这就叫利令智昏。独孤哥哥，搜搜他的身，也许会有其它线索。", 3, 3, 1},
			{"NpcBubbleTalk", "npc", "好！", 4, 6, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "path3", 19, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[20] = {nTime = 2, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"SetNpcDir", "npc", 32},
			{"DoCommonAct", "npc", 38, 0, 0, 0},	--独孤剑采集
		},
		tbUnLockEvent = 
		{
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 21, 1071, false},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},

	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap0", 22},
		},
		tbUnLockEvent = 
		{
			{"ChangeCameraSetting", 33, 35, 20},	--摄像机高度
		},
	},
}