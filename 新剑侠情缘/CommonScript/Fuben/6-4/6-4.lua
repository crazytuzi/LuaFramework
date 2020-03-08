
local tbFubenSetting = {};
Fuben:SetFubenSetting(50, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/6_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/6_5/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/6_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {3471, 1377}											-- 副本出生点
tbFubenSetting.nStartDir				= 8;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1407,		nLevel = -1, nSeries = -1},  --金兵
	[2] = {nTemplate = 1408,		nLevel = -1, nSeries = -1},  --百夫长
	[3] = {nTemplate = 1406,		nLevel = -1, nSeries = -1},  --先锋校尉
	[4] = {nTemplate = 747,			nLevel = -1, nSeries = 0},  --独孤剑
	[5] = {nTemplate = 853,			nLevel = -1, nSeries = 0},  --张琳心
	[6] = {nTemplate = 1422,		nLevel = -1, nSeries = 0},  --苦人儿
	[7] = {nTemplate = 1411,		nLevel = -1, nSeries = 0},  --陆文龙
	[8] = {nTemplate = 1413,		nLevel = -1, nSeries = 0},  --乳娘

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
			{"RaiseEvent", "ShowTaskDialog", 1, 1074, false},
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
			{"SetTargetPos", 3492, 2445},
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 9, 1, 0, "wall", "men1",false, 20},
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 8,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 4, 4, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 1, 4, 4, "gw", "guaiwu2", false, 0, 2, 9005, 0.5},
			--{"AddNpc", 1, 6, 0, "gw", "guaiwu2_1", false, 0, 4, 0, 0},
			--{"BlackMsg", "没想到这林对儿带了这么多手下！"},
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
			{"SetTargetPos", 3626, 4852},
			--{"BlackMsg", "看来五色教早来一步，武夷派怕是凶多吉少了！"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 9, 1, 0, "wall", "men2",false, 38},
		},
	},
	[6] = {nTime = 0, nNum = 8,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 6, 6, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 2, 6, "gw", "guaiwu4", false, 0, 2, 9005, 0.5},
			--{"AddNpc", 1, 8, 0, "gw", "guaiwu4_1", false, 0, 4, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
			--{"BlackMsg", "居然还有高手，林对儿在此处干嘛？"},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 5590, 4298},
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
			{"AddNpc", 3, 1, 8, "boss", "boss", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 1, 4, 0, "gw", "guaiwu5", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 0, "gw", "guaiwu6", false, 0, 4, 9005, 0.5},
			{"NpcBubbleTalk", "boss", "敢闯我大军营地，找死！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
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
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 10},
			{"SetTargetPos", 5442, 3063},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},


	---------------结束剧情------------------
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"MoveCameraToPosition", 12, 2, 5426, 1903, 0},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},

			{"AddNpc", 6, 1, 0, "npc", "kurener", false, 8, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "npc1", "luwenlong", false, 32, 0, 0, 0},

			{"ChangeNpcFightState", "npc", 0, 0},
			{"ChangeNpcFightState", "npc1", 0, 0},

			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 13, 1076, false},
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
			{"AddNpc", 8, 1, 0, "npc2", "runiang", false, 8, 0, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "path1", 14, 0, 0, 0, 0},
			{"NpcBubbleTalk", "npc2", "少爷，听我一言！", 4, 0.5, 1},
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcFightState", "npc2", 0, 0},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 15, 1077, false},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
		},
	},
	[16] = {nTime = 0, nNum = 2,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"AddNpc", 4, 1, 0, "npc3", "dugujian", false, 8, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "npc4", "zhanglinxin", false, 8, 0, 0, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetNpcBloodVisable", "npc4", false, 0},
			{"ChangeNpcAi", "npc3", "Move", "path2", 16, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "path3", 16, 0, 0, 0, 0},
			{"NpcBubbleTalk", "npc3", "丹心剑就在此！", 4, 0.5, 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcDir", "npc1", 0},
			{"ChangeNpcFightState", "npc3", 0, 0},
			{"ChangeNpcFightState", "npc4", 0, 0},
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 17, 1078, false},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},

}