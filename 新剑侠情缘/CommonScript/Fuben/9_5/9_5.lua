
local tbFubenSetting = {};
Fuben:SetFubenSetting(69, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/9_5/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/9_5/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/9_5/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1188, 3755}											-- 副本出生点
tbFubenSetting.nStartDir				= 16;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}
 
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2635,	nLevel = -1,	nSeries = -1},	--耶律辟离
	[2] = {nTemplate = 2636,	nLevel = -1,	nSeries = -1},	--天忍精英
	[3] = {nTemplate = 2637,	nLevel = -1,	nSeries = -1},	--天忍弟子
	[4] = {nTemplate = 2641,	nLevel = -1,	nSeries = 0},	--机关
	[5] = {nTemplate = 2642,	nLevel = -1,	nSeries = 0},	--技能
	[6] = {nTemplate = 73,    nLevel = -1, nSeries = 0},   --传送门
	[7] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1133, false},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 2},
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
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 1762, 3715},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"OpenDynamicObstacle", "obs3"},
			{"AddNpc", 7, 1, 0, "wall", "wall_1",false, 32},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 3, 8, 4, "guaiwu", "gw1_1", false, 48, 0.5, 9010, 0.5},
			{"AddNpc", 2, 1, 4, "jingying", "gw1_2", false, 48, 0.5, 9010, 0.5},
			{"AddNpc", 5, 1, 0, "jiguan1", "jiguan1", false, 1, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "jiguan2", "jiguan2", false, 32, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "jiguan3", "jiguan3", false, 1, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "jiguan4", "jiguan4", false, 32, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "jiguan5", "jiguan5", false, 1, 0, 0, 0},

			{"NpcBubbleTalk", "guaiwu", "完颜教主中兴圣教！一统江湖！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，敢来我天忍教放肆！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 4, 1, 5, "jiguan", "jg", false, 0, 0, 0, 0},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 6, 1, 0, "chuansong", "chuansong", false, 0, 0, 0, 0},
			{"ChangeTrap", "trap2", {6123, 3599}, nil},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 6},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 1, 1, 0, "boss", "boss1", false, 0, 0, 0, 0},
			{"SetNpcProtected", "boss", 1},
			{"AddNpc", 7, 1, 0, "wall", "wall_3",false, 32},
			{"RaiseEvent", "CloseDynamicObstacle", "obs3"},
		},
	},
	[7] = {nTime = 2, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 8, 1134, false},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "boss"},
			{"DoDeath", "wall"}, 
			{"OpenDynamicObstacle", "obs1"},
			{"SetTargetPos", 8227, 6003},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 9},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 3, 8, 10, "guaiwu", "gw2_1", false, 48, 0.5, 9010, 0.5},
			{"AddNpc", 2, 1, 10, "jingying", "gw2_2", false, 48, 0.5, 9010, 0.5},
			{"AddNpc", 7, 1, 0, "wall", "wall_2",false, 24},
			{"ClearTargetPos"},

			{"NpcBubbleTalk", "guaiwu", "完颜教主中兴圣教！一统江湖！", 4, 2, 1},
			{"NpcBubbleTalk", "jingying", "何方狂徒，敢来我天忍教放肆！", 4, 2, 1},
		},
	},
	[10] = {nTime = 0, nNum = 9,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall"}, 
			{"OpenDynamicObstacle", "obs2"},
			{"SetTargetPos", 9200, 9191},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 11},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 1, 1, 15, "boss", "boss2", false, 40, 1, 9010, 0.5},
			{"ClearTargetPos"},
		},
	},
	[12] = {nTime = 2, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "何不加入我教，同教主一道共襄大金统一大业？", 3, 0, 1},
			{"NpcHpUnlock", "boss", 13, 50},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "有心招揽你入教，没想到你却敬酒不吃吃罚酒！", 3, 0, 1},
			{"NpcHpUnlock", "boss", 14, 20},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "他日我大金挥师南下，尔等皆做刀下之鬼！", 3, 0, 1},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 2.1, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
---------------------------机关陷阱-------------------------------
	[20] = {nTime = 0.5, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle1", "jiguan1", 3, 4865, 5, 3546, 3688},
		},
	},
	[21] = {nTime = 2, nNum = 0,
		tbPrelock = {20},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle2", "jiguan2", 3, 4865, 5, 3820, 3688},
		},
	},
	[22] = {nTime = 2, nNum = 0,
		tbPrelock = {21},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle3", "jiguan3", 3, 4865, 5, 4176, 3688},
		},
	},
	[23] = {nTime = 2, nNum = 0,
		tbPrelock = {22},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle4", "jiguan4", 3, 4865, 5, 4527, 3688},
		},
	},
	[24] = {nTime = 2, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkillCycle", "cycle5", "jiguan5", 3, 4865, 5, 4828, 3688},
		},
	},
-------------------------极限走位支线---------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "zhixian", 30},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "guaiwu"},
			{"DoDeath", "jingying"},
			{"DoDeath", "wall"}, 
			{"OpenDynamicObstacle", "obs1"},
			{"SetTargetPos", 8227, 6003},
			--{"CloseLock", 4, 8},
		},
	},
}