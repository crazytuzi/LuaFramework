
local tbFubenSetting = {};
Fuben:SetFubenSetting(9001, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/yewaixiulian/NpcPos.tab"	-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/yewaixiulian/NpcPath.tab"-- 寻路点
tbFubenSetting.tbBeginPoint 			= {953, 785}											-- 副本出生点
tbFubenSetting.nStartDir				= 30;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

--NPC模版ID，NPC等级，NPC五行；


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 3202,			nLevel = -1,  nSeries = -1},  --金国高手
	[2] = {nTemplate = 3203,			nLevel = -1,  nSeries = 0},  --杨影枫
	[3] = {nTemplate = 3218,			nLevel = -1,  nSeries = -1},  --金国探子
	[4] = {nTemplate = 3219,			nLevel = -1,  nSeries = 0},  --纳兰真
	[5] = {nTemplate = 3220,			nLevel = -1,  nSeries = 0},  --独孤剑
	[6] = {nTemplate = 1073,			nLevel = -1,  nSeries = 0},  --篝火
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
			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"RaiseEvent", "ShowTaskDialog", 1, 60001, false},
			{"AddNpc", 2, 1, 0, "npc1", "stage1_2", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "npc2", "stage1_3", 1, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc3", "stage1_4", 1, 0, 0, 0, 0},
			{"RaiseEvent", "AddNpc2FakeTeam", "npc1", "npc2", "npc3"},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 19},
			--{"IfCase", "self.nStarLevel <= 0 and self.nFubenLevel = 1", {"UnLock", 26}},--指引开启判断
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnLock", "TrapLock2", 2},
			{"SetTargetPos", 2089, 930},
			{"ChangeNpcAi", "npc1", "Move", "path1", 2, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "path3", 2, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "path4", 2, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetpos"},
			{"RaiseEvent","ShowTaskDialog", 1, 60002, false},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc1", "Move", "path2", 3, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "path5", 3, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "path6", 3, 1, 1, 0, 0},
			{"SetTargetPos", 2300, 2400},
			{"TrapUnLock", "TrapLock1", 3},	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetpos"},	
		},
	},
	[4] = {nTime = 0, nNum = 10,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 4,  "guaiwu1", "stage1_7", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu2", "stage1_8", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu3", "stage1_9", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu4", "stage1_10", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu5", "stage1_11", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu6", "stage1_12", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu7", "stage1_13", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu8", "stage1_14", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu9", "stage1_15", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 4,  "guaiwu10", "stage1_16", 1, 0, 0, 0, 0},	
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 60003, false},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 5,  "guaiwu11", "stage1_10", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{  
			{"RaiseEvent", "ShowTaskDialog", 1, 60006, false}, 
			{"AddNpc", 6, 1, 0,  "gouhuo", "stage1_6", 1, 0, 0, 0, 0},
			{"RaiseEvent", "AddFakeGouhuoSkillState", 198, 1, 1800},
		},
	},	
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 6,  "guaiwu1", "stage1_7", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu2", "stage1_8", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu3", "stage1_9", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu4", "stage1_10", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu5", "stage1_11", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu6", "stage1_12", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu7", "stage1_13", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu8", "stage1_14", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu9", "stage1_15", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 6,  "guaiwu10", "stage1_16", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{   
		},
	},
	--[6] = {nTime = 0, nNum = 1,
	--	tbPrelock = {5},
	--	tbStartEvent = 
	--	{
	--		{"OpenGuide", 6, "PopB", "使用修炼丹", "BattleTopButton", "BtnBag", {0, 30}, true, false, true},
	--	},
	--	tbUnLockEvent = 
	--	{
	--		{"CloseWindow", "Guide"}, 	
	--	},
	--},
	--[7] = {nTime = 0, nNum = 1,
	--	tbPrelock = {6},
	--	tbStartEvent = 
	--	{
	--		{"OpenGuide", 7, "PopB", "点击使用", "ItemContainer", "item1", {-60, 30}, true, false, true},	
	--	},
	--	tbUnLockEvent = 
	--	{
	--		{"CloseWindow", "Guide"},
	--	},
	--},
	[8] = {nTime = 0, nNum = 10,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 8,  "guaiwu1", "stage1_7", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu2", "stage1_8", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu3", "stage1_9", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu4", "stage1_10", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu5", "stage1_11", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu6", "stage1_12", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu7", "stage1_13", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu8", "stage1_14", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu9", "stage1_15", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 8,  "guaiwu10", "stage1_16", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{   
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{	
			{"OpenGuide", 9, "PopT", "请长按此键", "HomeScreenBattle", "BtnChangeFightState", {0, -40}, false, true, true},
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "设置自动饮酒，野外修炼可获得更高收益！"},	
		},
		tbUnLockEvent = 
		{	
			{"CloseWindow", "Guide"},
			{"CloseWindow", "RockerGuideNpcPanel"},
		},
	},
	[10] = {nTime = 0, nNum = 9,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 10,  "guaiwu1", "stage1_7", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu2", "stage1_8", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu3", "stage1_9", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu5", "stage1_11", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu6", "stage1_12", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu7", "stage1_13", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu8", "stage1_14", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu9", "stage1_15", 1, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 10,  "guaiwu10", "stage1_16", 1, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{ 
		},
	},
	[11] = {nTime = 0, nNum = 3,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc1", "Move", "path7", 11, 1, 1, 0, 0}, 
			{"ChangeNpcAi", "npc2", "Move", "path7", 11, 1, 1, 0, 0}, 
			{"ChangeNpcAi", "npc3", "Move", "path7", 11, 1, 1, 0, 0},
		},
		tbUnLockEvent = 
		{	
			{"RaiseEvent", "ShowTaskDialog", 1, 60005, false},	
		},
	},
	[12] = {nTime = 1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"DelNpc", "npc"},
			{"GameWin"},		--闯关成功
		},
	},
	[19] = {nTime = 300, nNum = 0,
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

}
