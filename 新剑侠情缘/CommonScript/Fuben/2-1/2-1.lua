
local tbFubenSetting = {};
Fuben:SetFubenSetting(24, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/2_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/2_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/2_1/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1546, 1951}											-- 副本出生点
tbFubenSetting.nStartDir				= 30;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 775,						nLevel = -1, nSeries = -1},  --武林人士
	[2] = {nTemplate = 776,						nLevel = -1, nSeries = -1},  --神秘刺客
	[3] = {nTemplate = 777,						nLevel = -1, nSeries = -1},  --沐天然
	[4] = {nTemplate = 765,						nLevel = -1, nSeries = 0},  --杨影枫
	[5] = {nTemplate = 683,						nLevel = -1, nSeries = 0},  --姑娘
	[6] = {nTemplate = 74,						nLevel = -1, nSeries = 0},  --上升气流
	[7] = {nTemplate = 104,						nLevel = -1, nSeries = 0},  --动态障碍墙

	[8] = {nTemplate = 1439,					nLevel = -1, nSeries = -1},  --刺客头目-技能
	[9] = {nTemplate = 1104,					nLevel = -1, nSeries = 0},  --隐藏陷阱
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1011, false},	
			--{"AddNpc", "NpcIndex6", "NpcNum1", 3, "Start_Npc1", "Start_Npc1", 1, 0, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
		},
	},
	[2] = {nTime = 300, nNum = 0,
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
			{"SetTargetPos", 3223, 1068},
		},
		tbUnLockEvent = 
		{
		},
	},
	[4] = {nTime = 0, nNum = 11,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 3, 4, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 4, "gw1", "guaiwu1_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 5, 4, "gw", "guaiwu2", false, 0, 1.5, 0, 0},
			{"AddNpc", 2, 1, 4, "gw2", "guaiwu2_1", false, 0, 1.5, 0, 0},
			{"AddNpc", 8, 1, 4, "gw3", "guaiwu2_2", false, 0, 3, 0, 0},
			{"NpcBubbleTalk", "gw1", "又有肥羊来了，兄弟们上啊！", 4, 1, 1},
			{"NpcBubbleTalk", "gw2", "嘿嘿，要从此路过留下买路财！", 4, 2.5, 1},
			{"NpcBubbleTalk", "gw3", "没想到这厮还有些本事！", 4, 3.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "jump", 5},
			{"SetTargetPos", 4602, 1570},
			{"AddNpc", 6, 1, 0, "qg", "qinggong", false, 0, 0, 0, 0},
			{"ChangeTrap", "jump", nil, {5200, 2280}},
			{"ChangeTrap", "jump1", nil, {5804, 2953, 5}},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "gopos", 6},
			{"ChangeTrap", "gopos", nil, nil, nil, nil, nil, true},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "好险的断崖！！！", 3, 1},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"SetTargetPos", 5608, 3501},
			{"TrapUnlock", "trap2", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 10,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 8, "gw", "guaiwu3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "gw1", "guaiwu3_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 3, 8, "gw", "guaiwu4", false, 0, 1.5, 0, 0},
			{"AddNpc", 2, 1, 8, "gw2", "guaiwu4_1", false, 0, 1.5, 0, 0},
			{"AddNpc", 8, 1, 8, "gw3", "guaiwu4_2", false, 0, 2, 0, 0},
			{"NpcBubbleTalk", "gw1", "兄弟们，有人来坏我们的好事了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw2", "嘿嘿，找死！", 4, 2.5, 1},
			{"NpcBubbleTalk", "gw2", "哪来的无名之辈！", 4, 3.5, 1},

			{"AddNpc", 7, 1, 0, "wall", "wall1", false, 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "npc", "这些家伙在干些什么勾当？", 4, 2, 1},
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "npc", "yangyingfeng", false, 36, 0, 0, 0},
			{"TrapUnlock", "trap3", 9},
			{"SetTargetPos", 5667, 5746},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap5", 10},
			{"SetTargetPos", 3893, 5990},
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
			{"AddNpc", 1, 4, 0, "gw", "guaiwu5", false, 16, 0, 0, 0},
			{"AddNpc", 1, 4, 0, "gw", "guaiwu6", false, 48, 0, 0, 0},
			{"AddNpc", 3, 1, 11, "sl", "shouling", false, 48, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc1", "yuemeier", false, 32, 0, 0, 0},

			{"SetNpcProtected", "gw", 1},
			{"SetNpcProtected", "sl", 1},
			{"SetAiActive", "gw", 0},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "npc1", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 2.1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"DoDeath", "gw"},
		},
	},
	[13] = {nTime = 2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			--{"RaiseEvent", "ShowTaskDialog", 13, 1013, false},
			{"NpcBubbleTalk", "npc1", "多谢两位大侠相救！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},		
		},
	},

---------------------------剧情镜头----------------
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"MoveCamera", 14, 2, 38, 8, 53.5, 10, 87, 0},
			--{"MoveCameraToPosition", 14, 2, 3745, 4448, -13},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {103},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1012, false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", true},
			{"RaiseEvent", "FllowPlayer", "npc", false},
			{"ChangeNpcAi", "npc", "Move", "path1", 16, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc", "哈哈哈，这么热闹，让在下也来插一脚怎么样？", 5, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"RaiseEvent", "PlayerRunTo", 3864, 4876},
			{"RaiseEvent", "ShowTaskDialog", 17, 1100, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},

			{"SetNpcProtected", "gw", 0},
			{"SetNpcProtected", "sl", 0},

			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcBloodVisable", "sl", true, 0},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},

			{"SetAiActive", "gw", 1},
			{"SetAiActive", "sl", 1},
			{"SetAiActive", "npc1", 1},

			{"RaiseEvent", "ShowPartnerAndHelper", true},
		},
	},
---------------------------持续陷阱-----------------
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 18, 80},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 9, 3, 0, "gw", "xianjing1", false, 0, 1, 0, 0},
			{"NpcBubbleTalk", "sl", "哼，不自量力，看招！", 4, 0, 1},
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl", 19, 60},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 9, 4, 0, "gw", "xianjing2", false, 0, 1, 0, 0},
			{"NpcBubbleTalk", "sl", "想不到还有几分实力，再试试！", 4, 0, 1},
		},
	},

	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 100, 1010, false},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "FllowPlayer", "npc", true},
			{"NpcBubbleTalk", "npc", "前方似乎有些情况！", 4, 1, 1},
			{"BlackMsg", "继续前行"},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 101},
			{"SetTargetPos", 4784, 6282},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
----------------boss特写-------------------
	[102] = {nTime = 3, nNum = 0,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"OpenWindowAutoClose", "BossReferral", "沫", "天然", "江湖成名高手"},
			{"DoCommonAct", "sl", 17, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "BossReferral"},
		},
	},
	[103] = {nTime = 0, nNum = 1,
		tbPrelock = {102},
		tbStartEvent = 
		{
			{"MoveCamera", 103, 1, 29, 21, 40, 35, 45, 0},
			{"SetNpcDir", "sl", 64},
		},
		tbUnLockEvent = 
		{
		},
	},

}
