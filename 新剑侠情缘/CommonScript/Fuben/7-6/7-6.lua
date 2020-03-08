
	local tbFubenSetting = {};
	Fuben:SetFubenSetting(58, tbFubenSetting)		-- 绑定副本内容和地图
	
	tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
	tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
	tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/7_6/NpcPos.tab"			-- NPC点
	--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/7_6/ExtNpcAwardInfo.tab"	-- 掉落表
	--tbFubenSetting.szPathFile = "Setting/Fuben/TestFuben/NpcPos.tab"								-- 寻路点
	tbFubenSetting.tbBeginPoint 			= {3299, 1108}											-- 副本出生点
	tbFubenSetting.nStartDir				= 56;
	
	
	tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1700,		nLevel = -1, nSeries = -1},	--江湖恶徒
	[2] = {nTemplate = 1701,		nLevel = -1, nSeries = -1},	--无良剑客
	[3] = {nTemplate = 1702,		nLevel = -1, nSeries = -1},	--邪恶高手-精英
	[4] = {nTemplate = 1703,		nLevel = -1, nSeries = -1},	--南宫彩虹-首领
	[5] = {nTemplate = 1704,		nLevel = -1, nSeries = -1},	--张如梦-首领

	[7] = {nTemplate = 104,			nLevel = -1, nSeries = 0},	--障碍墙
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1113, false},	
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
		},
	},
	[2] = {nTime = 600, nNum = 0,
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
			{"SetTargetPos", 2449, 1684},
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
			{"AddNpc", 1, 7, 4, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 1, 4, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "此路是我开，留下买路财!", 3, 1, 1},

			{"RaiseEvent", "PartnerSay", "鼠辈！", 3, 1},
			{"BlackMsg", "击败此处的江湖宵小！"},

			{"AddNpc", 7, 1, 0, "wall", "wall1", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},

	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 2649, 5227},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 12,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 2, 7, 7, "gw", "guaiwu2_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 1, 7, "gw", "guaiwu2_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", 2, 4, 7, "gw", "guaiwu2_2", false, 0, 3, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "站住，要钱还是要命！", 3, 1, 2},
			{"RaiseEvent", "PartnerSay", "没完没了！", 3, 1},

			{"AddNpc", 7, 1, 0, "wall", "wall2", false, 36, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},

	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 8},
			{"SetTargetPos", 5131, 5007},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[9] = {nTime = 0, nNum = 8,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"AddNpc", 1, 3, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"AddNpc", 2, 3, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"AddNpc", 3, 2, 9, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "兄弟们一起上！", 3, 1, 2},
			{"RaiseEvent", "PartnerSay", "小心！", 3, 1},

			{"AddNpc", 7, 1, 0, "wall", "wall3", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs3"},
			{"DoDeath", "wall"},
		},
	},

	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 10},
			{"SetTargetPos", 5190, 2757},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "sl", "nangongcaihong", false, 64, 0, 0, 0},
			{"SetNpcProtected", "sl", 1},

			{"NpcHpUnlock", "sl", 11, 30},

			{"AddNpc", 5, 1, 0, "npc", "zhangrumeng", false, 32, 0, 0, 0},

			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"ChangeNpcFightState", "sl", 0, 0.5},
			{"ChangeNpcFightState", "npc", 0, 0.5},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "npc", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 12, 1115, false},
			{"SetNpcProtected", "sl", 1},
			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"ChangeNpcFightState", "sl", 0, 0.5},
			{"ChangeNpcFightState", "npc", 0, 0.5},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "npc", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
	-------------------------剧情展现-------------------
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 14, 1, 5285, 2050, 10},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1114, false},	
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},

			{"SetNpcProtected", "sl", 0},
			{"SetNpcProtected", "npc", 0},
			{"SetNpcBloodVisable", "sl", true, 0},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetAiActive", "sl", 1},
			{"BlackMsg", "保护张如梦不被南宫彩虹击杀！"},

			{"NpcBubbleTalk", "npc", "彩虹，动手吧！", 3, 0, 1},
			{"NpcBubbleTalk", "sl", "你...小心了！", 3, 1, 1},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 16, 90},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "sl", "你怎么不还手？想死么？", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "你别管我！", 3, 1, 1},
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 17, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "sl", "我动真格的了，你当真不还手？", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "彩虹...我...", 3, 1, 1},
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 18, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "sl", "气死我了，你到底要怎样？", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "彩虹，我们停手吧！", 3, 1.5, 1},
			{"NpcBubbleTalk", "sl", "我...我不！", 3, 3, 1},
			{"NpcBubbleTalk", "npc", "唉...", 3, 4.5, 1},
		},
	},

}