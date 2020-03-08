
local tbFubenSetting = {};
Fuben:SetFubenSetting(63, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/8_4/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/8_4/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/8_4/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2692, 1285}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1925,	nLevel = -1,	nSeries = -1},	--家丁
	[2] = {nTemplate = 1926,	nLevel = -1,	nSeries = -1},	--护院
	[3] = {nTemplate = 1933,	nLevel = -1,	nSeries = -1},	--护院精英
	[4] = {nTemplate = 1927,	nLevel = -1,	nSeries = -1},	--护院头目
	[5] = {nTemplate = 1928,	nLevel = -1,	nSeries = 0},	--南宫飞云
	[6] = {nTemplate = 1929,	nLevel = -1,	nSeries = 0},	--赵升权

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
			{"RaiseEvent", "ShowTaskDialog", 1, 1123, false},
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
			{"SetTargetPos", 2666, 2412},
			{"AddNpc", 7, 1, 0, "wall", "men1",false, 16},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 16,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 4, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 7, 4, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 1, 4, "gw", "guaiwu2", false, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "来者何人？居然到风雪山庄撒野！", 4, 2, 1},
			{"RaiseEvent", "PartnerSay", "风雪山庄人多势众啊！", 3, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "不过如此嘛。", 3, 1},
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
			{"SetTargetPos", 2723, 6540},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"AddNpc", 7, 1, 0, "wall", "men2",false, 32},
		},
	},
	[6] = {nTime = 0, nNum = 18,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 8, 6, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 8, 6, "gw", "guaiwu4", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 2, 6, "gw1", "guaiwu4", false, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw1", "来者何人？居然到风雪山庄撒野！", 4, 2, 1},
			{"NpcBubbleTalk", "gw", "兄弟们一起上，拿下他！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "PartnerSay", "前面怕是有强敌。", 3, 1},
			{"BlackMsg", "继续前进"},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall"},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 6043, 6957},
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
			{"AddNpc", 1, 10, 0, "gw", "guaiwu5", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 3, 1, 0, "gw1", "guaiwu5", false, 32, 0.5, 9009, 0.5},
			{"AddNpc", 2, 10, 0, "gw", "guaiwu5", false, 32, 4, 9009, 0.5},
			{"AddNpc", 3, 2, 0, "gw1", "guaiwu5", false, 32, 4, 9009, 0.5},
			{"AddNpc", 4, 1, 8, "sl", "shouling", false, 32, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "gw1", "兄弟们一起上。", 4, 2, 1},
			{"NpcBubbleTalk", "sl", "有两下子，居然闯到此处！", 4, 2, 1},
			{"NpcBubbleTalk", "gw", "来者何人？居然到风雪山庄撒野！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 2.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			--{"GameWin"},
		},
	},
----------------------------完结剧情----------------
	
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},
			{"ChangeFightState", 0},

			{"PlayCameraEffect", 9119},
			{"RaiseEvent", "ShowPlayer", false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
			{"MoveCameraToPosition", 0, 2, 7685, 6935, 2},

			{"AddNpc", 5, 1, 0, "npc", "nangongfeiyun", false, 32, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "npc1", "zhaoshengquan", false, 64, 0, 0, 0},
			
			{"RaiseEvent", "ShowTaskDialog", 10, 1125, false, 2},
		},
		tbUnLockEvent = 
		{
			--{"LeaveAnimationState", true},
		},
	},
	[11] = {nTime = 5, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"ChangeNpcCamp", "npc1", 1},
			{"NpcAddBuff", "npc1", 100, 1, 100},
			{"NpcAddBuff", "npc", 100, 1, 100},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 1, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"DoCommonAct", "npc1", 6, 0, 0, 0},
			{"CastSkill", "npc1", 2384, 1, -1, -1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetNpcProtected", "npc1", 1},
			{"DoCommonAct", "npc", 3, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 4, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc", "哎呀，我动不了了！！", 4, 0, 1},
			{"NpcBubbleTalk", "npc1", "来人！拿下了！", 4, 2, 1},
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			{"GameWin"},
		},
	},

}