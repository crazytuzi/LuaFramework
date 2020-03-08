
local tbFubenSetting = {};
Fuben:SetFubenSetting(21, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/1_2/NpcPos.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_2/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/1_2/NpcPath.tab"			-- 寻路点
tbFubenSetting.tbBeginPoint 			= {200, 1835}											-- 副本出生点
tbFubenSetting.nStartDir				= 20;


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 756,				nLevel = 3, 	nSeries = -1},  --杀人蜂
	[2] = {nTemplate = 757,				nLevel = 3, 	nSeries = -1},  --杀人蜂精英
	[4] = {nTemplate = 758,				nLevel = 4, 	nSeries = -1},  --杀人蜂王
	[5] = {nTemplate = 1117,			nLevel = -1, 	nSeries = 0},  --纳兰真
	[6] = {nTemplate = 746,				nLevel = -1, 	nSeries = 0},  --银丝草

	[7] = {nTemplate = 104,				nLevel = -1, 	nSeries = 0},  --动态障碍墙

	[14] = {nTemplate = 746,			nLevel = -1, 	nSeries = -1},
	[15] = {nTemplate = 74,				nLevel = -1, 	nSeries = 0},  --上升气流

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
			--{"OpenWindowAutoClose", "StoryBlackBg", "走过崎岖的山路，终于来到了离忧山，纳兰真似乎对此处颇为熟悉。", nil, 3, 2, 1},
			{"RaiseEvent", "ShowTaskDialog", 1, 1003, false},
			{"AddNpc", 5, 1, 0, "start_npc", "start_npc", false, 40, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"SetShowTime", 16},
			{"RaiseEvent", "FllowPlayer", "start_npc", true},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "trap1", 2},
			{"SetTargetPos", 1307, 1328},
			--{"AddNpc", 7, 1, 2, "wall", "wall_1_1",false, 50},
			--刷怪
			{"AddNpc", 1, 3, 3, "guaiwu", "stage_1_1", false, -1, 0, 0, 0},
			{"SetNpcProtected", "guaiwu", 1},
		},
		tbUnLockEvent = 
		{
			{"SetNpcProtected", "guaiwu", 0},

			{"ClearTargetPos"},
			{"NpcBubbleTalk", "start_npc", "天哪！离忧山的毒蜂是不是很大啊？！", 5, 0, 1},
			{"AddNpc", 1, 3, 3, "guaiwu", "stage_1_2", false, -1, 1.5, 9005, 0.5},
			{"AddNpc", 1, 4, 3, "guaiwu", "stage_1_3", false, -1, 3, 9005, 0.5},
		},
	},
	[3] = {nTime = 0, nNum = 10,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 0, "wall", "wall1", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"OpenDynamicObstacle", "obs1"},
			{"DoDeath", "wall"},
			--{"AddNpc", 7, 1, 2, "wall", "wall_1_2",false, 54},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"SetTargetPos", 2345, 977},
			{"TrapUnlock", "trappos1", 4},			
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4612, 995},		
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 5},
			{"AddNpc", 1, 1, 6, "guaiwu1", "stage_2_1", false, -1, 0, 0, 0},
			{"AddNpc", 1, 1, 6, "guaiwu2", "stage_2_2", false, -1, 0, 0, 0},
			{"SetNpcProtected", "guaiwu1", 1},
			{"SetNpcProtected", "guaiwu2", 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "start_npc", "啊呀...毒蜂要冲过来了！", 5, 0, 1},
		},
	},
	
	[6] = {nTime = 0, nNum = 9,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 3, 6, "guaiwu", "stage_2_3", false, -1, 2, 9005, 0.5},
			{"AddNpc", 1, 4, 6, "guaiwu", "stage_2_4", false, -1, 2.5, 9005, 0.5},
			{"AddNpc", 7, 1, 0, "wall", "wall2", false, 16, 0, 0, 0},		
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4893, 3864},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs2"},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 7},
			{"AddNpc", 1, 1, 8, "guaiwu1", "stage_3_1", false, -1, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu2", "stage_3_2", false, -1, 0, 0, 0},
			{"AddNpc", 1, 1, 8, "guaiwu3", "stage_3_3", false, -1, 0, 0, 0},
			{"SetNpcProtected", "guaiwu1", 1},
			{"SetNpcProtected", "guaiwu2", 1},
			{"SetNpcProtected", "guaiwu3", 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 8,		
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 1, 2, 8, "guaiwu", "stage_3_4", false, -1, 2, 9005, 0.5},
			{"AddNpc", 1, 3, 8, "guaiwu", "stage_3_5", false, -1, 2.5, 9005, 0.5},			
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0, nNum = 1,			--轻功点
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"SetTargetPos", 4734, 4264},
			
			--{"SetTargetPos", 4242, 4236},
			
			{"TrapUnlock", "trap4", 9},
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			
			{"AddNpc", 6, 1, 0, "cj", "yinsicao",false, 0},
			{"AddNpc", 4, 1, 10, "boss", "stage_4_boss", false, 16},
			{"AddNpc", 1, 1, 0, "guaiwu1", "stage_4_1", false, -1, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "guaiwu2", "stage_4_2", false, -1, 0, 0, 0},
			{"AddNpc", 1, 1, 0, "guaiwu3", "stage_4_3", false, -1, 0, 0, 0},
			{"SetNpcBloodVisable", "start_npc", false, 0},
		    {"SetNpcBloodVisable", "boss", false, 0},
		    {"SetNpcBloodVisable", "guaiwu1", false, 0},
		    {"SetNpcBloodVisable", "guaiwu2", false, 0},
		    {"SetNpcBloodVisable", "guaiwu3", false, 0},
			{"SetNpcProtected", "boss", 1},
			{"SetNpcProtected", "guaiwu1", 1},
			{"SetNpcProtected", "guaiwu2", 1},
			{"SetNpcProtected", "guaiwu3", 1},
			{"CastSkillCycle", "cycle", "boss", 2, 2457, 1, 2233, 4662},   --使用技能
		},
		tbUnLockEvent = 
		{
		    {"DoDeath", "guaiwu"},
		    {"DoDeath", "guaiwu1"},
		    {"DoDeath", "guaiwu2"},
		    {"DoDeath", "guaiwu3"},
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
			{"PauseLock", 16},
		    {"StopEndTime"},
		},
	},
	[11] = {nTime = 2.1, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
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
			{"MoveCameraToPosition", 0, 2, 1663, 4922, -5},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
		    {"ChangeNpcAi", "start_npc", "Move", "path2", 12, 0, 0, 0, 0},
		    {"NpcBubbleTalk", "start_npc", "呼呼...终于找到银丝草了，太好了！", 3, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 1.5, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"DoCommonAct", "start_npc", 36, 0, 0, 0},	--纳兰真采集银丝草动作
			--{"DelNpc", "cj"},
		},
		tbUnLockEvent = 
		{
			--{"GameWin"},		--闯关成功
		},
	},
	[18] = {nTime = 0.5, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"DelNpc", "cj"},
		},
		tbUnLockEvent = 
		{
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
			{"GameWin"},		--闯关成功
		},
	},

	-------------------------登山镜头--------------------
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
		    --{"MoveCamera", 14, 1, 161.13, 62.97, 93.93, 0, 0, 0},
			{"MoveCameraToPosition", 14, 1, 2003, 4753, -5},
		    --{"DelNpc", "start_npc"},
		    {"AddNpc", 5, 1, 0, "start_npc", "start_npc1", false, 56, 0, 0, 0},
		    {"PauseLock", 16},
		    {"StopEndTime"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
		    {"RaiseEvent", "ShowTaskDialog", 15, 1004, false},
		},
		tbUnLockEvent = 
		{
			--{"SetTargetPos", 2227, 4634},
			{"ResumeLock", 16},
			{"SetShowTime", 16},
			{"LeaveAnimationState", true},
			
			{"CloseCycle", "cycle"},
			{"SetNpcBloodVisable", "start_npc", true, 0},
		    {"SetNpcBloodVisable", "boss", true, 0},
		    {"SetNpcBloodVisable", "guaiwu1", true, 0},
		    {"SetNpcBloodVisable", "guaiwu2", true, 0},
		    {"SetNpcBloodVisable", "guaiwu3", true, 0},
			{"SetNpcProtected", "boss", 0},
			{"SetNpcProtected", "guaiwu1", 0},
			{"SetNpcProtected", "guaiwu2", 0},
			{"SetNpcProtected", "guaiwu3", 0},
			{"NpcBubbleTalk", "start_npc", "这个蜂王有毒，要小心哦！", 3, 0, 1},
			{"AddNpc", 1, 2, 0, "guaiwu", "stage_4_4", 1, -1, 1.5, 9005, 0.5},
			{"AddNpc", 1, 3, 0, "guaiwu", "stage_4_5", 1, -1, 2.5, 9005, 0.5},
		},
	},

	[16] = {nTime = 300, nNum = 0,
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

	[17] = {nTime = 1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "FllowPlayer", "start_npc", false},
			--{"AddNpc", 15, 1, 0, "qg", "qinggong"},
			{"ChangeNpcAi", "start_npc", "Move", "path1", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "start_npc", "你的轻功怎么样？从这边可以登上山崖。", 3, 0, 1},
			
		},
	},
	[19] = {nTime = 3, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
				
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 15, 1, 0, "qg", "qinggong"},
			{"ChangeTrap", "jump", nil, {3357, 4480, 2}},
			{"SetTargetPos", 4242, 4236},	
		},
	},
	


	[30] = {nTime = 2, nNum = 0,		--怪物释放技能
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"SetNpcProtected", "guaiwu1", 0},
			{"SetNpcProtected", "guaiwu2", 0},
			{"CastSkill", "guaiwu1", 2348, 1, 4560, 1187},
			{"CastSkill", "guaiwu2", 2348, 1, 4560, 787},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2357, 1, 4560, 1187},
			{"CastSkill", "guaiwu2", 2357, 1, 4560, 787},
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"SetNpcProtected", "guaiwu1", 0},
			{"SetNpcProtected", "guaiwu2", 0},
			{"SetNpcProtected", "guaiwu3", 0},
			{"CastSkill", "guaiwu1", 2348, 1, 4580, 3500},
			{"CastSkill", "guaiwu2", 2348, 1, 4870, 3500},
			{"CastSkill", "guaiwu3", 2348, 1, 5120, 3500},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2357, 1, 4580, 3500},
			{"CastSkill", "guaiwu2", 2357, 1, 4870, 3500},
			{"CastSkill", "guaiwu3", 2357, 1, 5120, 3500},
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"CastSkill", "guaiwu1", 2348, 1, 3200, 4760},
			{"CastSkill", "guaiwu2", 2348, 1, 3200, 4540},
			{"CastSkill", "guaiwu3", 2348, 1, 3200, 4320},
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "guaiwu1", 2357, 1, 3200, 4760},
			{"CastSkill", "guaiwu2", 2357, 1, 3200, 4540},
			{"CastSkill", "guaiwu3", 2357, 1, 3200, 4320},
		},
	},

	[33] = {nTime = 5, nNum = 1,   --指引技能使用
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.05},
			{"OpenGuide", 33, "PopT", "请点击使用轻功", "HomeScreenBattle", "SkillDodge", {0, -40}, false, true},--使用技能
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "点击箭头指引的[FFFE0D]轻功[-]可进行躲避！"},
			{"PlayHelpVoice", "Setting/NpcVoice/16-A.voice"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "Guide"},		--指引技能关闭
			{"CloseWindow", "RockerGuideNpcPanel"},
			{"SetGameWorldScale", 1},
		},
	},
	[34] = {nTime = 5, nNum = 1,   --指引技能使用
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.05},
			{"OpenGuide", 34, "PopT", "请点击使用轻功", "HomeScreenBattle", "SkillDodge", {0, -40}, false, true},--使用技能
			{"OpenWindowAutoClose", "RockerGuideNpcPanel", "点击箭头指引的[FFFE0D]轻功[-]可进行躲避！"},
		},
		tbUnLockEvent = 
		{
			{"CloseWindow", "Guide"},		--指引技能关闭
			{"CloseWindow", "RockerGuideNpcPanel"},
			{"SetGameWorldScale", 1},
		},
	},
}
