
local tbFubenSetting = {};
Fuben:SetFubenSetting(28, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/2_5/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/2_6/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/2_5/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {3208, 1104}											-- 副本出生点
tbFubenSetting.nStartDir				= 53;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 789,			nLevel = -1, nSeries = -1},		--飞龙堡弟子
	[2] = {nTemplate = 790,			nLevel = -1, nSeries = -1},		--飞龙堡护法
	[3] = {nTemplate = 523,			nLevel = -1, nSeries = -1},		--机关战车
	[4] = {nTemplate = 791,			nLevel = -1, nSeries = -1},		--飞龙堡头目-首领
	[5] = {nTemplate = 684,			nLevel = -1, nSeries = 0},		--杨影枫
	
	[6] = {nTemplate = 104,			nLevel = -1, nSeries = 0},		--动态障碍墙
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1027, false},	
			--{"AddNpc", 5, 1, 3, "Start_Npc1", "Start_Npc1", 1, 48, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 13},
			--{"RaiseEvent", "FllowPlayer", "Start_Npc1", true},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"SetTargetPos", 2515, 1668},
			{"AddNpc", 6, 1, 2, "wall", "wall_1_1",false, 15},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[3] = {nTime = 0, nNum = 8,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 3, "guaiwu", "Stage_1_1", 1, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 1, 3, "guaiwu1", "Stage_1_2", 1, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 3, 3, "guaiwu", "Stage_1_3", 1, 0, 2, 0, 0},
			{"NpcBubbleTalk", "guaiwu1", "杨影枫，跟我们走！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			--{"NpcBubbleTalk", "Start_Npc1", "飞龙堡的人...怎么二话不说就动手！", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "飞龙堡的人...怎么二话不说就动手！", 4, 1},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall"},
			{"AddNpc", 6, 1, 0, "wall", "wall_1_2", false, 35},
			{"OpenDynamicObstacle", "ops1"},			
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 4},
			{"SetTargetPos", 2838, 5097},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 2, 5, "guaiwu", "Stage_2_1", 1, 40, 0, 0, 0},
			{"AddNpc", 1, 2, 5, "guaiwu", "Stage_2_2", 1, 40, 0, 0, 0},

			{"SetNpcProtected", "guaiwu", 1},
			{"SetNpcBloodVisable", "guaiwu", false, 0},
			{"SetAiActive", "guaiwu", 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall"},
			{"AddNpc", 6, 1, 2, "wall", "wall_1_3", false, 19},
			{"OpenDynamicObstacle", "ops2"},
			--{"NpcBubbleTalk", "Start_Npc1", "没想到飞龙堡行事作风竟如此霸道....", 4, 0, 1},
			{"RaiseEvent", "PartnerSay", "没想到飞龙堡行事作风竟如此霸道....", 4, 1},
		},
	},

	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 6},
			{"SetTargetPos", 5163, 5049},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetAiActive", "BOSS", 1},

			{"ClearTargetPos"},
		},
	},
	[7] = {nTime = 0, nNum = 12,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 1, 2, 7, "guaiwu", "Stage_3_1", 1, 0, 0, 9005, 0.5},
			{"AddNpc", 1, 2, 7, "guaiwu", "Stage_3_2", 1, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "BOSS", "我已在沿途设下埋伏，阁下还是束手就擒吧！", 5, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops3"},
			{"DoDeath", "wall"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 8},
			{"SetTargetPos", 5030, 2460},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 9, 1101, false},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "CloseDynamicObstacle", "ops3"},	
			{"AddNpc", 6, 1, 0, "wall", "wall_1_3",false, 19},

			{"SetAiActive", "BOSS", 1},
			{"SetNpcProtected", "BOSS", 0},
			{"ChangeNpcFightState", "BOSS", 1, 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetNpcBloodVisable", "Start_Npc1", true, 0},
			{"ChangeNpcFightState", "Start_Npc1", 1, 0},

			{"NpcBubbleTalk", "BOSS", "看来你们真的还有两下子，别怪我下狠手了！", 3, 0, 1},
			{"NpcBubbleTalk", "Start_Npc1", "废话少说，打倒在下自然跟你走！", 4, 3, 1},
			{"AddNpc", 1, 4, 0, "guaiwu", "Stage_4_1", 1, 0, 2.5, 9005, 0.5},
			{"AddNpc", 2, 2, 0, "guaiwu", "Stage_4_2", 1, 0, 2.5, 9005, 0.5},
			{"AddNpc", 3, 3, 0, "guaiwu", "Stage_4_2", 1, 0, 3.5, 0, 0},
		},
	},

	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 10, "BOSS", "Stage_4_BOSS", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Start_Npc1", "Start_Npc1", false, 32, 0, 0, 0},
			{"SetAiActive", "BOSS", 0},
			{"SetNpcProtected", "BOSS", 1},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},

			{"ChangeNpcFightState", "Start_Npc1", 0, 0},
			{"SetNpcBloodVisable", "Start_Npc1", false, 0},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 13},
			{"StopEndTime"},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
		},
	},
	[11] = {nTime = 2.1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
		},
	},
	[12] = {nTime = 1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 13},
			{"SetShowTime", 13},
			{"GameWin"},
		},
	},
	[13] = {nTime = 300, nNum = 0,
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

	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"TrapUnlock", "GoPoint1", 30},
			{"SetTargetPos", 3979, 5434},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 5104, 4900},
		},
	},
-------------------------------------------------------
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "BOSS", "Stage_2_BOSS", false, 0, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetAiActive", "BOSS", 0},

			{"NpcHpUnlock", "BOSS", 31, 60},
		},
		tbUnLockEvent = 
		{
			
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"NpcBubbleTalk", "BOSS", "兄弟们来呀！", 4, 0, 1},
			{"AddNpc", 2, 1, 5, "guaiwu1", "Stage_2_3", 1, 0, 1.5, 9005, 0.5},
			{"AddNpc", 1, 4, 5, "guaiwu", "Stage_2_4", 1, 0, 1.5, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "你不要敬酒不吃吃罚酒！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "BOSS", 2452, 1, 100},
			{"ChangeNpcAi", "BOSS", "Move", "path1", 0, 0, 0, 1, 0},
		},
	},

	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 33, 1028, false},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetAiActive", "BOSS", 1},
			{"SetNpcProtected", "guaiwu", 0},
			{"SetNpcBloodVisable", "guaiwu", true, 0},
			{"SetAiActive", "guaiwu", 1},

			{"NpcBubbleTalk", "BOSS", "你就乖乖跟兄弟们走一趟吧！", 4, 1, 1},
			--{"NpcBubbleTalk", "Start_Npc1", "哼，想让杨某跟你们走，就先问问我手中之剑答不答应！", 4, 3, 1},
			{"RaiseEvent", "PartnerSay", "哼，想让我们跟你走，先问问我手中的武器答不答应！", 4, 1},
		},
	},

	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "BOSS", "Stage_3_BOSS", false, 0, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetAiActive", "BOSS", 0},

			{"NpcHpUnlock", "BOSS", 34, 60},
		},
		tbUnLockEvent = 
		{
		},
	},
	[35] = {nTime = 2, nNum = 0,
		tbPrelock = {34},
		tbStartEvent = 
		{
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"NpcBubbleTalk", "BOSS", "让我的兄弟来收拾你们！", 4, 0, 1},
			{"AddNpc", 3, 3, 7, "guaiwu", "Stage_3_4", 1, 0, 1.5, 9005, 0.5},
			{"AddNpc", 1, 4, 7, "guaiwu", "Stage_3_5", 1, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 1, 7, "guaiwu1", "Stage_3_3", 1, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "guaiwu1", "兄弟们，给我将他们绑回飞龙堡！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "BOSS", 2452, 1, 100},
			{"ChangeNpcAi", "BOSS", "Move", "path2", 0, 0, 0, 1, 0},
		},
	},
}
