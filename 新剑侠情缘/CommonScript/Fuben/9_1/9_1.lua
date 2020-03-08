
local tbFubenSetting = {};
Fuben:SetFubenSetting(65, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/9_1/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/9_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/9_1/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {3285, 4223}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}
tbFubenSetting.bForbidPartner = true;
--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2555,	nLevel = -1,	nSeries = -1},	--毒水陷阱
	[2] = {nTemplate = 2554,	nLevel = -1,	nSeries = -1},	--锈蚀机关人
	[3] = {nTemplate = 2553,	nLevel = -1,	nSeries = -1},	--技能
	

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
			{"RaiseEvent", "ShowTaskDialog", 1, 1126, false},
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
			{"SetTargetPos", 2442, 4464},
			{"AddNpc", 1, 10, 0, "xj", "xianjing",false, 18},
			{"NpcAddBuff", "xj", 4867, 1, 300},
			{"OpenDynamicObstacle", "obs2"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PlayerBubbleTalk", "此地陷阱布置以我现在功力施展轻功堪堪越过。"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 4},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 1813, 1740},
			{"AddNpc", 7, 1, 0, "wall", "wall_1",false, 31},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 5},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"RaiseEvent", "ShowTaskDialog", 6, 1127, false, 0},
			{"AddNpc", 7, 1, 0, "wall", "wall_2",false, 20},
			{"RaiseEvent", "CloseDynamicObstacle", "obs2"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "快[FFFE0D]使用轻功[-]躲避致命技能！！"},
			{"AddNpc", 3, 25, 0, "fire", "fire", false, 0, 0, 0, 0},
		},
	},
	[7] = {nTime = 1.5, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			--熔岩喷火（放技能）
			{"CastSkill", "fire", 2771, 1, -1, -1},
		},
	},
	[8] = {nTime = 5, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "仍然并无异动，莫非考验还在继续？"},
		},
	},
	[9] = {nTime = 10, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "快[FFFE0D]使用轻功[-]躲避致命技能！！"},
		},
	},
	[10] = {nTime = 1.5, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			--熔岩喷火（放技能）
			{"CastSkill", "fire", 2771, 1, -1, -1},
		},
	},
	[11] = {nTime = 5, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "前面道路何时才能打通？"},
		},
	},
	[12] = {nTime = 10, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "快[FFFE0D]使用轻功[-]躲避致命技能！！"},
		},
	},
	[13] = {nTime = 1.5, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			--熔岩喷火（放技能）
			{"CastSkill", "fire", 2771, 1, -1, -1},
		},
	},
	[14] = {nTime = 0.1, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
			{"BlackMsg", "继续探索"},
			{"SetTargetPos", 4723, 2130},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 15},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 2, 1, 18, "boss", "boss",false, 0, 0.5, 9010, 0.5},
		},
	},
	[16] = {nTime = 1, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"SetNpcProtected", "boss", 1},
			{"SetAiActive", "boss", 0},
			{"SetNpcBloodVisable", "boss", false, 1},
			{"RaiseEvent", "ShowTaskDialog", 17, 1128, false, 0},
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"SetNpcProtected", "boss", 0},
			{"SetAiActive", "boss", 1},
			{"SetNpcBloodVisable", "boss", true, 0},
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
		},
	},
	[19] = {nTime = 2.1, nNum = 0,
		tbPrelock = {18},
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
}