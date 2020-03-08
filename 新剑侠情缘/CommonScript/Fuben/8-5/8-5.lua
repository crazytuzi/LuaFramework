
local tbFubenSetting = {};
Fuben:SetFubenSetting(64, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/8_5/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/8_5/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/8_5/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {1605, 1644}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;




-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1930,	nLevel = -1,	nSeries = -1},	--唐门弟子
	[2] = {nTemplate = 1931,	nLevel = -1,	nSeries = -1},	--唐门精英
	[3] = {nTemplate = 1932,	nLevel = -1,	nSeries = -1},	--唐潇-头目
	[4] = {nTemplate = 2536,	nLevel = -1,	nSeries = 0},	--技能

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
			{"RaiseEvent", "ShowTaskDialog", 1, 1124, false},
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
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 1896, 3212},
			{"AddNpc", 7, 1, 0, "wall", "men1",false, 24},
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
			{"AddNpc", 1, 8, 4, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"RaiseEvent", "PartnerSay", "果然有人！", 3, 1},
		},
		tbUnLockEvent = 
		{
			--{"RaiseEvent", "PartnerSay", "这里是埋伏的好地方。", 3, 1},
			{"BlackMsg", "继续前进"},
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 3854, 4854},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "men2",false, 38},
			{"AddNpc", 1, 8, 6, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 2, 6, "gw1", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 1, 9, "sl", "shouling", false, 32, 0, 9009, 0},
			{"NpcBubbleTalk", "gw1", "唐门禁地，闲杂人等退下！", 4, 1, 1},
			{"NpcBubbleTalk", "sl", "居然有人敢闯我蜀中唐门！", 4, 1, 1},
		},
	},
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "小心前方遍布的陷阱"},
		},
	},
	[7] = {nTime = 0.2, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "sl", 11, 50},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
			{"MoveCameraToPosition", 12, 5, 4987, 2510, 2},
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"ChangeFightState", 0},
			{"AddNpc", 4, 1, 0, "jg1", "jiguan1", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "jg2", "jiguan2", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "jg3", "jiguan3", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "jg4", "jiguan4", false, 0, 0, 0, 0},
			{"NpcFindEnemyUnlock", "jg1", 13, 0},
			{"NpcFindEnemyUnlock", "jg2", 14, 0},
			{"NpcFindEnemyUnlock", "jg3", 15, 0},
			{"NpcFindEnemyUnlock", "jg4", 16, 0},
			{"NpcBubbleTalk", "sl", "好小子有两下子，够胆就跟我来！", 3, 0, 1},
			{"NpcAddBuff", "sl", 2452, 2, 10},
			{"ChangeNpcAi", "sl", "Move", "path1", 12, 0, 0, 0, 0},
		},
	},
	[12] = {nTime = 0, nNum = 2,
		tbPrelock = {11},
		tbStartEvent = 
		{	

		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", true},
			{"LeaveAnimationState", true},
			{"SetForbiddenOperation", false},
			{"ChangeFightState", 1},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddBuff", 1058, 1, 3, 0, 0},
			{"CastSkill", "jg1", 4864, 1, -1, -1},
			{"DoDeath", "jg1"},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddBuff", 1058, 1, 3, 0, 0},
			{"CastSkill", "jg2", 4864, 1, -1, -1},
			{"DoDeath", "jg2"},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddBuff", 1058, 1, 3, 0, 0},
			{"CastSkill", "jg3", 4864, 1, -1, -1},
			{"DoDeath", "jg3"},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddBuff", 1058, 1, 3, 0, 0},
			{"CastSkill", "jg4", 4864, 1, -1, -1},
			{"DoDeath", "jg4"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 8},
			{"SetTargetPos", 4705, 2211},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 1, 8, 0, "gw", "guaiwu3", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 2, 1, 0, "gw1", "guaiwu3", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 1, 8, 0, "gw", "guaiwu3", false, 32, 4, 9009, 0.5},
			{"AddNpc", 2, 2, 0, "gw1", "guaiwu3", false, 32, 4, 9009, 0.5},
			{"NpcBubbleTalk", "gw1", "快快退下，否则不客气了！", 4, 1, 1},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {5}, 
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 2.1, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
}