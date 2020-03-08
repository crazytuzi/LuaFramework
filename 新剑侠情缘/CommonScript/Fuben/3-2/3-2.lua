
local tbFubenSetting = {};
Fuben:SetFubenSetting(31, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/3_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/3_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/3_2/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1585, 3340}											-- 副本出生点
tbFubenSetting.nStartDir				= 24;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；

--[[
]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 829,		nLevel = 21, nSeries = -1},	--蒙面人
	[2] = {nTemplate = 830,		nLevel = 22, nSeries = -1},	--蒙面人精英
	[3] = {nTemplate = 831,		nLevel = 23, nSeries = -1},	--蒙面人头目
	[4] = {nTemplate = 1347,	nLevel = 21, nSeries = 0},	--装人的箱子
	[5] = {nTemplate = 1348,	nLevel = 23, nSeries = 0},	--蔷薇
	[6] = {nTemplate = 684,		nLevel = 23, nSeries = 0},	--杨影枫

	[7] = {nTemplate = 104,		nLevel = 21, nSeries = 0},	--障碍门

	[8] = {nTemplate = 1490,		nLevel = 21, nSeries = 0},	--男村民
	[9] = {nTemplate = 1491,		nLevel = 21, nSeries = 0},	--女村民
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
			{"RaiseEvent", "ShowTaskDialog", 1, 1091, false},
			--{"AddNpc", 6, 1, 0, "npc", "yangyingfeng", false, 48, 0, 0, 0},
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
			{"SetTargetPos", 2151, 2855},
			{"AddNpc", 7, 1, 0, "wall", "men1",false, 32},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[100] = {nTime = 4, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"ChangeFightState", 0},
			{"MoveCameraToPosition", 0, 1, 2120, 2273, 0},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			-- {"SetNpcProtected", "gw", 0},
			-- {"SetNpcProtected", "cm", 0},
			-- {"SetNpcProtected", "cm1", 0},
			{"NpcBubbleTalk", "cm", "大侠救命！", 4, 0.5, 1},
			{"NpcBubbleTalk", "cm1", "救命啊！绑架啦！", 4, 0.5, 1},
		},
		tbUnLockEvent = 
		{
			{"ChangeFightState", 1},

			{"SetNpcProtected", "cm", 1},
			{"SetNpcProtected", "cm1", 1},
			{"AddNpc", 1, 3, 4, "gw", "guaiwu2", false, 0, 1.5, 9005, 0.5},
			{"AddNpc", 2, 1, 4, "gw1", "guaiwu2", false, 0, 1.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw1", "敢坏我们的好事，活得不耐烦了！", 4, 2, 1},
			{"BlackMsg", "击败在此处绑架村民的蒙面人！"},

			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 4, "gw", "guaiwu1", false, 0, 0, 0, 0},
			{"AddNpc", 8, 2, 0, "cm", "nancm1", false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "cm1", "nvcm1", false, 0, 0, 0, 0},
			-- {"SetNpcProtected", "gw", 1},
			-- {"SetNpcProtected", "cm", 1},
			-- {"SetNpcProtected", "cm1", 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "真是胆大包天，光天化日之下也敢绑架？！！", 3, 1},
			{"NpcBubbleTalk", "cm", "谢谢大侠救了我们！", 4, 0, 2},
			{"NpcBubbleTalk", "cm1", "奴家...多谢大侠！", 4, 0, 1},
			{"BlackMsg", "继续前进查探情况！"},
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 4567, 2491},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "men2",false, 8},	
		},
	},
	[101] = {nTime = 4, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"ChangeFightState", 0},
			{"MoveCameraToPosition", 0, 1, 5522, 2660, 0},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			-- {"SetNpcProtected", "gw", 0},
			-- {"SetNpcProtected", "cm", 0},
			-- {"SetNpcProtected", "cm1", 0},
			{"NpcBubbleTalk", "cm", "大侠救命！", 4, 0.5, 1},
			{"NpcBubbleTalk", "cm1", "救命啊！绑架啦！", 4, 0.5, 1},
		},
		tbUnLockEvent = 
		{
			{"ChangeFightState", 1},
			
			{"SetNpcProtected", "cm", 1},
			{"SetNpcProtected", "cm1", 1},
			{"AddNpc", 1, 4, 6, "gw", "guaiwu4", false, 32, 1.5, 9005, 0.5},
			{"AddNpc", 2, 1, 6, "gw1", "guaiwu4", false, 32, 1.5, 9005, 0.5},
			{"BlackMsg", "击败在此处绑架村民的蒙面人！"},
			{"NpcBubbleTalk", "gw1", "来者何人？你最好别管闲事！", 4, 2, 1},

			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
		},
	},
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"DelNpc", "cm"},
			{"DelNpc", "cm1"},
			{"AddNpc", 1, 5, 6, "gw", "guaiwu3", false, 32, 0, 0, 0},
			{"AddNpc", 8, 3, 0, "cm", "nancm2", false, 0, 0, 0, 0},
			{"AddNpc", 9, 2, 0, "cm1", "nvcm2", false, 0, 0, 0, 0},
			-- {"SetNpcProtected", "gw", 1},
			-- {"SetNpcProtected", "cm", 1},
			-- {"SetNpcProtected", "cm1", 1},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "cm", "谢谢大侠救了我们！", 4, 0, 3},
			{"NpcBubbleTalk", "cm1", "奴家...多谢大侠！", 4, 0, 2},
			{"NpcBubbleTalk", "npc", "继续前进查探情况！", 3, 1, 1},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 3411, 4884},
			{"AddNpc", 4, 1, 0, "npc1", "xiangzi", false, 32, 0, 0, 0},
			{"AddNpc", 1, 4, 0, "gw", "guaiwu5", false, 24, 0, 0, 0},
			{"AddNpc", 2, 1, 0, "gw1", "guaiwu5_1", false, 24, 0, 0, 0},
			{"AddNpc", 3, 1, 10, "sl", "shouling", false, 24, 0, 0, 0}, --解锁的首领
			{"SetNpcBloodVisable", "sl", false, 0},
			{"SetNpcBloodVisable", "gw", false, 0},
			{"SetNpcBloodVisable", "gw1", false, 0},
			{"SetNpcProtected", "sl", 1},
			{"SetNpcProtected", "gw", 1},
			{"SetNpcProtected", "gw1", 1},
			{"SetAiActive", "sl", 0},
			{"SetAiActive", "gw", 0},
			{"SetAiActive", "gw1", 0},
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
			{"MoveCameraToPosition", 8, 1.5, 2536, 5083, 5},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 4, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "sl", "就这么带这个小妞儿回去交差是不是太可惜了？我们兄弟冒了多大的危险才把她抓来，不如......", 3, 0.5, 1},
			{"NpcBubbleTalk", "gw1", "嘿嘿……大哥说的对，我也想尝一尝这武林盟主的女儿到底是什么滋味。", 3, 3.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[102] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 6, 1, 0, "npc", "yangyingfeng", false, 48, 0, 0, 0},
			{"SetNpcBloodVisable", "npc", false, 0},
			{"ChangeNpcAi", "npc", "Move", "path1", 102, 1, 1, 0, 0},
			{"NpcBubbleTalk", "npc", "住手！", 4, 0.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[103] = {nTime = 6, nNum = 0,
		tbPrelock = {102},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "sl", "你是谁？竟敢管我们的闲事，活的不耐烦了？", 3, 0, 1},
			{"NpcBubbleTalk", "npc", "无耻之徒，竟胡乱绑架无辜之人...", 3, 2, 1},
			{"NpcBubbleTalk", "gw1", "大哥，别跟这小子废话，宰了他！", 3, 4, 1},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "救下木箱中的人！"},
			{"LeaveAnimationState", true},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {103},
		tbStartEvent = 
		{
			{"SetNpcBloodVisable", "npc", true, 0},
			{"SetNpcBloodVisable", "sl", true, 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"SetNpcBloodVisable", "gw1", true, 0},
			{"SetNpcProtected", "sl", 0},
			{"SetNpcProtected", "gw", 0},
			{"SetNpcProtected", "gw1", 0},
			{"SetAiActive", "sl", 1},
			{"SetAiActive", "gw", 1},
			{"SetAiActive", "gw1", 1},
			{"NpcBubbleTalk", "sl", "坏老子的好事，找死！", 3, 1, 1},
			{"NpcBubbleTalk", "npc", "多行不义必自毙！", 3, 2, 1},
			{"AddNpc", 1, 5, 0, "gw", "guaiwu6", false, 0, 4, 9005, 0.5},
			{"AddNpc", 2, 2, 0, "gw1", "guaiwu6_1", false, 0, 4, 9005, 0.5},
			{"NpcBubbleTalk", "gw1", "大家一齐上，别让这小子跑了。", 4, 4, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 2.1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"SetNpcBloodVisable", "npc", false, 0},
			{"ChangeNpcAi", "npc", "Move", "path2", 12, 1, 1, 0, 0},
			{"MoveCameraToPosition", 0, 2.5, 2210, 5146, 5},		--最后的镜头
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"NpcBubbleTalk", "npc", "让我看看这箱子里装的是谁！", 3, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1.2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"DoCommonAct", "npc", 16, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"CastSkill", "npc1", 3, 1, -1, -1},
			{"AddNpc", 5, 1, 0, "npc1", "xiangzi", false, 24, 0, 0, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetAiActive", "npc", 0},
			{"SetAiActive", "npc1", 0},
			{"RaiseEvent", "ShowTaskDialog", 14, 1092, false, 1},
		},
		tbUnLockEvent = 
		{
			--{"LeaveAnimationState", true},
			{"SetForbiddenOperation", false},
			--{"SetAllUiVisiable", true},
			{"GameWin"},
		},
	},
}