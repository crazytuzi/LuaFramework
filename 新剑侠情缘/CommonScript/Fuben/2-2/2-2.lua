
local tbFubenSetting = {};
Fuben:SetFubenSetting(25, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/2_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/2_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 			    = "Setting/Fuben/PersonalFuben/2_2/NpcPath.tab"					-- 寻路点
tbFubenSetting.tbBeginPoint 			= {2661, 1206}											-- 副本出生点
tbFubenSetting.nStartDir				= 0;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量


tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/Camera_chusheng.controller",
}


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 779,			nLevel = -1, nSeries = -1},  --庄丁
	[2] = {nTemplate = 792,			nLevel = -1, nSeries = -1},  --藏剑弟子
	[3] = {nTemplate = 524,			nLevel = -1, nSeries = -1},  --神射手
	[4] = {nTemplate = 780,			nLevel = -1, nSeries = -1},  --藏剑亲卫
	[5] = {nTemplate = 681,			nLevel = -1, nSeries = 0},  --杨影枫
	[6] = {nTemplate = 1134,		nLevel = -1, nSeries = 0},  --卓非凡
	[7] = {nTemplate = 1286,		nLevel = -1, nSeries = 0},  --紫轩

	[8] = {nTemplate = 104,			nLevel = -1, nSeries = 0},  --动态障碍墙

	[16] = {nTemplate = 781,		nLevel = -1, nSeries = -1},	--庄丁头目
}

--是否允许同伴出战
tbFubenSetting.bForbidPartner = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ChangeAutoFight", false},
			{"PlayCameraEffect", 9119},		
			{"MoveCamera", 1, 4, 26.4, 28.37, 34.7, 35, 45, 0},
			{"SetAllUiVisiable", false}, 		
			{"SetForbiddenOperation", true},		

			--巡逻庄丁			
			{"AddNpc", 1, 1, 34, "Patrol_1", "Stage_1_1", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 34, "Patrol_2", "Stage_1_2", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 34, "Patrol_3", "Stage_1_3", 1, 0, 0, 0, 0},
			{"AddNpc", 1, 1, 34, "Patrol_4", "Stage_1_4", 1, 0, 0, 0, 0},

			{"ChangeNpcAi", "Patrol_1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_2", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Patrol_4", "Move", "Path4", 0, 1, 1, 0, 1},

			{"NpcFindEnemyUnlock", "Patrol_1", 30, 0},
			{"NpcFindEnemyUnlock", "Patrol_2", 31, 0},
			{"NpcFindEnemyUnlock", "Patrol_3", 32, 0},
			{"NpcFindEnemyUnlock", "Patrol_4", 33, 0},

			{"NpcAddBuff", "Patrol_1", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_2", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_3", 2402, 1, 300},
			{"NpcAddBuff", "Patrol_4", 2402, 1, 300},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},		
			{"SetForbiddenOperation", false},
			{"LeaveAnimationState", false},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 2, 1014, false},
		},
		tbUnLockEvent = 
		{
			{"SetShowTime", 13},
			{"SetAllUiVisiable", true}, 
			{"BlackMsg", "前方有庄丁巡逻，注意别被发现！"},
			
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 8, 1, 0, "wall2", "wall_1_2",false, 32},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"ChangeFightState", 1},
			{"SetTargetPos", 3035, 6144},
			{"TrapUnlock", "TrapLock1", 3},
			{"AddNpc", 2, 3, 4, "guaiwu", "Stage_2_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 4, "guaiwu", "Stage_2_2", 1, 0, 0, 0, 0},
			{"SetNpcProtected", "guaiwu", 1},		
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Patrol_1"},
			{"DelNpc", "Patrol_2"},
			{"DelNpc", "Patrol_3"},
			{"DelNpc", "Patrol_4"},
			{"ChangeCameraSetting", 23, 35, 20},
			{"DelNpc", "Patrol_Leader"},
			{"DelNpc", "Patrol_1_1"},

			{"SetNpcProtected", "guaiwu", 0},
			{"ClearTargetPos"},
			{"AddNpc", 3, 3, 4, "guaiwu", "Stage_2_3", 1, 0, 2, 0, 0},
			{"AddNpc", 2, 4, 4, "guaiwu", "Stage_2_4", 1, 0, 4, 9008, 0.5},
			{"SetNpcRange", "guaiwu", 3000, 3000, 5},
		},
	},
	[4] = {nTime = 0, nNum = 12,
		tbPrelock = {2},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall2"},
			{"AddNpc", 8, 1, 0, "wall3", "wall_1_3",false, 16},
			{"SetTargetPos", 5570, 7220},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 5},
			{"AddNpc", 2, 2, 6, "guaiwu", "Stage_3_1", 1, 0, 0, 0, 0},
			{"AddNpc", 2, 2, 6, "guaiwu", "Stage_3_2", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "guaiwu", "Stage_3_2", 1, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 6, "guaiwu", "Stage_3_3", 1, 0, 0, 0, 0},
			{"SetNpcProtected", "guaiwu", 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "guaiwu", 0},
			{"ClearTargetPos"},
			{"AddNpc", 3, 3, 6, "guaiwu", "Stage_3_4", 1, 0, 4, 0, 0},
			{"AddNpc", 2, 6, 6, "guaiwu", "Stage_3_5", 1, 0, 7, 9008, 0.5},	
			{"SetNpcRange", "guaiwu", 3000, 3000, 8},
		},
	},
	[6] = {nTime = 0, nNum = 15,
		tbPrelock = {5},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "ops3"},
			{"SetTargetPos", 7083, 4655},
			{"AddNpc", 5, 1, 0, "yangyingfeng", "Stage_4_1", 1, 30, 0, 0, 0},
			{"AddNpc", 7, 1, 0, "zixuan", "Stage_4_2", 1, 15, 0, 0, 0},
			{"AddNpc", 6, 1, 0, "zhuofeifan", "Stage_4_3", 1, 47, 0, 0, 0},
			{"ChangeNpcCamp", "zhuofeifan", 0},
			{"SetNpcBloodVisable", "yangyingfeng", false, 0},
			{"SetNpcBloodVisable", "zhuofeifan", false, 0},
			{"SetNpcBloodVisable", "zixuan", false, 0},
			{"ChangeNpcFightState", "zhuofeifan", 0, 0},
			{"ChangeNpcFightState", "zixuan", 0, 0},
			{"SetAiActive", "zhuofeifan", 0},
			{"SetAiActive", "zixuan", 0},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock3", 7},
		},
		tbUnLockEvent = 
		{
			{"PauseLock", 13},
			{"StopEndTime"},
			{"RaiseEvent", "ShowTaskDialog", 8, 1015, false},
			{"RaiseEvent", "ShowPartnerAndHelper", false},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"MoveCamera", 9, 2, 64.6, 17.8, 39.8, 0, 0, 0},
			{"SetAllUiVisiable", false}, 
			{"SetForbiddenOperation", true},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"RaiseEvent", "ShowTaskDialog", 10, 1016, false},	
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", true},
			{"MoveCamera", 11, 1.5, 79.30138, 15.8442, 53.82127, 0, 0, 0},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetForbiddenOperation", false},
			{"RaiseEvent", "ShowTaskDialog", 12, 1017, false},	
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "yangyingfeng", 2452, 1, 100},
			{"ChangeNpcAi", "yangyingfeng", "Move", "npath1", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "yangyingfeng", "这一切都是骗局！骗局！", 3, 0, 1},
			{"SetAllUiVisiable", true}, 
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
	[14] = {nTime = 2, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{					
		},
		tbUnLockEvent = 
		{
			{"ResumeLock", 13},
			{"SetShowTime", 13},
			{"SetForbiddenOperation", false},
			{"GameWin"},
		},
	},

	-- 庄丁巡逻设置
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_1", "你是什么人，竟敢擅闯藏剑山庄！", 4, 0, 1},
			{"CastSkill", "Patrol_1", 28, 10, -1, -1},		--释放控制技能
			
			{"CloseLock", 31, 33},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_2", "你是什么人，竟敢擅闯藏剑山庄！", 4, 0, 1},
			{"CastSkill", "Patrol_2", 28, 10, -1, -1},		--释放控制技能

			{"CloseLock", 32, 33},
			{"CloseLock", 30},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_3", "你是什么人，竟敢擅闯藏剑山庄！", 4, 0, 1},
			{"CastSkill", "Patrol_3", 28, 10, -1, -1},		--释放控制技能

			{"CloseLock", 30, 31},
			{"CloseLock", 33},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Patrol_4", "你是什么人，竟敢擅闯藏剑山庄！", 4, 0, 1},
			{"CastSkill", "Patrol_4", 28, 10, -1, -1},		--释放控制技能

			{"CloseLock", 30, 32},
		},
	},
	[34] = {nTime = 0, nNum = 19,
		tbPrelock = {{30, 31, 32, 33}},
		tbStartEvent = 
		{
			{"CloseLock", 36},

			{"SetNpcAi", "Patrol_1", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_2", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_3", "Setting/Npc/Ai/CommonActive4.ini"},
			{"SetNpcAi", "Patrol_4", "Setting/Npc/Ai/CommonActive4.ini"},

			{"AddNpc", 8, 4, 0, "wall1", "wall_1_1",false, 16},
			{"RaiseEvent", "CloseDynamicObstacle", "ops1"},
			{"NpcRemoveBuff", "Patrol_1", 2402},
			{"NpcRemoveBuff", "Patrol_2", 2402},
			{"NpcRemoveBuff", "Patrol_3", 2402},
			{"NpcRemoveBuff", "Patrol_4", 2402},
			{"SetNpcRange", "Patrol_1", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_2", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_3", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_4", 5000, 5000, 2},

			{"BlackMsg", "你被发现了，惊动了周围埋伏的藏剑弟子！"},
			{"AddNpc", 16, 1, 34, "Patrol_Leader", "Patrol_Leader", 1, 0, 1.5, 9011, 1},
			{"AddNpc", 3, 14, 34, "Patrol_1_1", "Patrol_1_1", 1, 0, 2, 0, 0},
			{"NpcBubbleTalk", "Patrol_Leader", "哪里来的家伙，竟敢擅闯藏剑山庄！真是不知死活！！", 5, 2, 1},
			{"SetNpcRange", "Patrol_Leader", 5000, 5000, 2},
			{"SetNpcRange", "Patrol_1_1", 5000, 5000, 2},
		},
		tbUnLockEvent = 
		{
			{"PlayCameraEffect", 9119},	
			{"ChangeCameraSetting", 23, 35, 20},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 3035, 6144},
			{"DoDeath", "wall1"},
			{"BlackMsg", "居然埋伏了这么多人，真是凶险！"},
		},
	},
	[35] = {nTime = 2, nNum = 0,
		tbPrelock = {{30, 31, 32, 33}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "CallPartner"},
			{"ChangeCameraSetting", 40, 35, 20},
		},
	},
	[36] = {nTime = 1, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "CallPartner"},
		},
	},

	[37] = {nTime = 0, nNum = 1,		-------取消警戒触发
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock4", 37},	
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Patrol_1"},
			{"DelNpc", "Patrol_2"},
			{"DelNpc", "Patrol_3"},
			{"DelNpc", "Patrol_4"},
			{"ChangeCameraSetting", 23, 35, 20},
			{"DelNpc", "Patrol_Leader"},
			{"DelNpc", "Patrol_1_1"},
		},
	},

}
