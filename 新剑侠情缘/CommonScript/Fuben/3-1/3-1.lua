
local tbFubenSetting = {};
Fuben:SetFubenSetting(30, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_1/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {3301, 1532}											-- 副本出生点
tbFubenSetting.nStartDir				= 64;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
--NPC模版ID，NPC等级，NPC五行；

--[[

]]


tbFubenSetting.NPC = 
{
	[1] = {nTemplate  = 823,		nLevel = 20, nSeries = -1},  --苍鹰
	[2] = {nTemplate  = 8,			nLevel = 20, nSeries = -1},  --猛虎
	[3] = {nTemplate  = 825,		nLevel = 22, nSeries = -1},  --大型苍鹰
	[4] = {nTemplate  = 828,		nLevel = 20, nSeries = 0},  --蔷薇
	[5] = {nTemplate  = 681,		nLevel = 20, nSeries = 0},  --杨影枫

	[6] = {nTemplate  = 104,		nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1031, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
			--{"RaiseEvent", "FllowPlayer", "npc", true},
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
			{"SetTargetPos", 2251, 2222},
			{"AddNpc", 5, 1, 0, "npc", "yangyingfeng", false, 56, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "npc1", "qiangwei1", false, 24, 0, 0, 0},

			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcProtected", "npc1", 1},
			{"SetAiActive", "npc1", 0},
			{"AddNpc", 6, 2, 0, "wall", "men1",false, 16},	
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
			{"RaiseEvent", "ShowTaskDialog", 4, 1032, false},
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "npc1", 1},
			{"NpcAddBuff", "npc1", 2452, 1, 100},
			{"ChangeNpcAi", "npc1", "Move", "path1", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "npc1", "有本事就到后面来找我！", 4, 0, 1},
		},
	},
	[100] = {nTime = 1, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "npc", 2452, 1, 100},
			{"ChangeNpcAi", "npc", "Move", "path1", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "npc", "你等等，周围好像有古怪！", 4, 0, 1},
		},
	},
	[101] = {nTime = 1, nNum = 0,
		tbPrelock = {100},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[102] = {nTime = 0, nNum = 1,
		tbPrelock = {101},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1_1", 102},
			{"SetTargetPos", 1696, 2829},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[5] = {nTime = 0, nNum = 8,
		tbPrelock = {102},
		tbStartEvent = 
		{
			{"AddNpc", 2, 4, 5, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 5, "gw", "guaiwu2", false, 0, 1.5, 9005, 0.5},
			{"BlackMsg", "击败忽然扑上来的猛虎！"},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"RaiseEvent", "PartnerSay", "此处怪物横行，这姑娘还乱跑...", 4, 1},
			{"TrapUnlock", "trap2", 6},
			{"SetTargetPos", 1507, 5170},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 6, 2, 0, "wall", "men2",false, 32},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 7, 2, 1505, 6097, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"AddNpc", 5, 1, 0, "npc", "yangyingfeng1", false, 64, 0, 0, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcProtected", "npc", 1},
			{"AddNpc", 4, 1, 0, "npc1", "qiangwei2", false, 32, 0, 0, 0},
			{"AddNpc", 1, 6, 9, "gw", "guaiwu3", false, 32, 0, 0, 0},
			{"AddNpc", 3, 2, 9, "gw", "guaiwu3_1", false, 32, 0, 0, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetNpcProtected", "npc1", 1},
			{"SetNpcProtected", "gw", 1},
			{"SetAiActive", "npc1", 0},
			{"SetAiActive", "gw", 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 8, 1088, false},
		},
		tbUnLockEvent = 
		{	
		},
	},
	[103] = {nTime = 1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"SetAiActive", "npc1", 1},
			{"NpcAddBuff", "npc1", 2452, 1, 100},
			{"ChangeNpcAi", "npc1", "Move", "path2", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "npc1", "我家的鹰儿可是特殊训练过的，慢慢玩！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[104] = {nTime = 1, nNum = 0,
		tbPrelock = {103},
		tbStartEvent = 
		{
			{"NpcAddBuff", "npc", 2452, 1, 100},
			{"NpcBubbleTalk", "npc", "太调皮了！！", 3, 0, 1},
			{"ChangeNpcAi", "npc", "Move", "path2", 0, 0, 0, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcProtected", "gw", 0},
			{"SetAiActive", "gw", 1},

			{"LeaveAnimationState", true},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
		},
	},
	[9] = {nTime = 0, nNum = 8,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "好凶悍的鹰...", 4, 1},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 10},
			{"SetTargetPos", 4070, 4405},
			{"AddNpc", 5, 1, 0, "npc", "yangyingfeng2", false, 24, 0, 0, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"AddNpc", 4, 1, 0, "npc1", "qiangwei3", false, 56, 0, 0, 0},
			{"AddNpc", 1, 5, 0, "gw", "guaiwu4", false, 56, 0, 0, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetNpcProtected", "npc1", 1},
			{"SetNpcProtected", "gw", 1},
			{"SetAiActive", "npc1", 0},
			{"SetAiActive", "gw", 0},
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
			{"RaiseEvent", "ShowTaskDialog", 11, 1089, false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "npc1", 12, 30},
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "npc1", true, 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcProtected", "npc1", 0},
			{"SetNpcProtected", "gw", 0},
			{"SetAiActive", "npc1", 1},
			{"SetAiActive", "gw", 1},
			{"NpcBubbleTalk", "npc1", "看来本姑娘得亲自出手了！", 4, 1, 1},
			{"NpcBubbleTalk", "npc", "那杨某就领教蔷薇姑娘的高招了！", 4, 2, 1},
			{"AddNpc", 1, 5, 0, "gw", "guaiwu5", false, 0, 3, 9005, 0.5},
			{"AddNpc", 3, 2, 0, "gw", "guaiwu5", false, 0, 3, 9005, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"DoDeath", "gw"},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcProtected", "npc1", 1},
			{"SetAiActive", "npc1", 0},
			{"RaiseEvent", "ShowTaskDialog", 13, 1090, false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0.5, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},
	
}
