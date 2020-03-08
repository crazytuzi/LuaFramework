
local tbFubenSetting = {};
Fuben:SetFubenSetting(151, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "忠义之魂"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/WLDS/NpcPos500-2.tab"			-- NPC点
--tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/1_1/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/PersonalFuben/WLDS/NpcPath500-2.tab"		    -- 寻路点
tbFubenSetting.tbBeginPoint 			= {2376, 6158}											-- 副本出生点
tbFubenSetting.nStartDir				= 24;



-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/camera/fb_canghai02/canghai02_cam1.controller",
	--场景对象：baishuisi_cam1；动画名：baishuisi_cam1；特效：9221
}

--NPC模版ID，NPC等级，NPC五行；


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2734,			nLevel = -1,	nSeries = 0},  --金兵
	[2] = {nTemplate = 2735,			nLevel = -1,	nSeries = 0},  --十夫长
	[3] = {nTemplate = 2736,			nLevel = -1,	nSeries = 0},  --刺客
	[4] = {nTemplate = 2737,			nLevel = -1,	nSeries = 0},  --刺客头目
	[5] = {nTemplate = 2738,			nLevel = -1,	nSeries = 0},  --宋朝降卒
	[6] = {nTemplate = 2739,			nLevel = -1,	nSeries = 0},  --boss

	[7] = {nTemplate = 2740,			nLevel = -1,	nSeries = 0},  --虞允文棺椁
	[8] = {nTemplate = 2741,			nLevel = -1,	nSeries = 0},  --霜儿
	[9] = {nTemplate = 2742,			nLevel = -1,	nSeries = 0},  --武林人士1
	[10] = {nTemplate = 2743,			nLevel = -1,	nSeries = 0},  --武林人士2
	[11] = {nTemplate = 2744,			nLevel = -1,	nSeries = 0},  --宋兵

	[20] = {nTemplate = 2731,			nLevel = -1,	nSeries = 0},  --传送门
	[21] = {nTemplate = 104,			nLevel = -1,	nSeries = 0},  --动态障碍墙
}


--是否允许同伴出战
tbFubenSetting.bForbidPartner = true;
tbFubenSetting.bForbidHelper = true;

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 0, nNum = 1,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 1, 1144, false},	--剧情1

			{"AddNpc", 7, 1, 100, "npc", "npc", false, 32, 0, 0, 0},
			{"AddNpc", 8, 1, 101, "npc1", "npc1", false, 32, 0, 0, 0},
			{"AddNpc", 9, 1, 0, "npc2", "npc2", false, 32, 0, 0, 0},
			{"AddNpc", 10, 1, 0, "npc3", "npc3", false, 32, 0, 0, 0},
			{"AddNpc", 11, 1, 0, "npc4", "npc4", false, 32, 0, 0, 0},
			{"AddNpc", 11, 1, 0, "npc5", "npc5", false, 32, 0, 0, 0},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			{"ChangeFightState", 1},
			{"RaiseEvent", "ChangeAutoFight", false},
		},
	},
	[2] = {nTime = 1800, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetShowTime", 2},
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	-----------------npc死亡失败------------------
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "虞允文棺椁被毁坏，护送失败！"},
			{"PlayerBubbleTalk", "糟糕，金人摧毁了宰相的棺椁，我们还是撤退吧！"},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "霜儿身受重伤，护送失败！"},
			{"PlayerBubbleTalk", "霜儿，你怎么了？看来霜儿受伤了，我们还是撤退吧！"},
		},
	},
	[102] = {nTime = 3, nNum = 0,
		tbPrelock = {{100, 101}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	---------------------npc死亡失败--------------------
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"BlackMsg", "前去与霜儿碰头"},
			{"TrapUnlock", "trap1", 3},	
			{"SetTargetPos", 2584, 5333},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"PlayerBubbleTalk", "霜儿，我来了！"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 4, 1145, false},	--剧情2
		},
		tbUnLockEvent = 
		{
		},
	},
	[5] = {nTime = 0, nNum = 2,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "xunlu-1", 5, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-1", 5, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "xunlu2-1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "xunlu3-1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "xunlu4-1", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc5", "Move", "xunlu5-1", 0, 1, 1, 0, 0},

			{"BlackMsg", "和霜儿一起护送宰相棺椁"},
			{"NpcBubbleTalk", "npc1", "出发吧！", 2, 0, 2},
		},
		tbUnLockEvent = 
		{
		},
	},
	[6] = {nTime = 0, nNum = 13,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 1, 12, 6, "gw", "guaiwu1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 1, 6, "sl", "shouling1", false, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "兄弟们上啊！", 4, 1.1, 2},
			{"NpcBubbleTalk", "sl", "嘿嘿，把老家伙的棺材留下吧！", 4, 1.1, 1},
			{"BlackMsg", "击败拦路的金兵！"},

			{"NpcBubbleTalk", "npc3", "冷静！", 3, 1, 1},
			{"NpcBubbleTalk", "npc4", "金兵围上来了！", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[7] = {nTime = 4, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"PlayerBubbleTalk", "看来行踪已被金人发现了！"},
			{"NpcBubbleTalk", "npc1", "下面的路不好走，大家小心点！", 3, 0.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[8] = {nTime = 0, nNum = 2,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "xunlu-2", 8, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-2", 8, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "xunlu2-2", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "xunlu3-2", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "xunlu4-2", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc5", "Move", "xunlu5-2", 0, 1, 1, 0, 0},

			{"BlackMsg", "继续护送"},
			{"NpcBubbleTalk", "npc1", "我们继续赶路吧！", 3, 0, 1},
			{"NpcBubbleTalk", "npc2", "好的！", 3, 1.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0, nNum = 11,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "有埋伏！", 3, 0, 1},

			{"AddNpc", 3, 10, 9, "gw", "guaiwu2", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 9, "sl", "shouling2", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "gw", "自投罗网！", 4, 2, 2},
			{"NpcBubbleTalk", "sl", "与大金国作对是没有好下场的！", 4, 2, 1},
			{"BlackMsg", "击败埋伏的刺客！"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[10] = {nTime = 3, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "大言不惭！我们继续前进吧！", 3, 0.5, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[11] = {nTime = 0, nNum = 2,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "xunlu-3", 11, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-3", 11, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "xunlu2-3", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "xunlu3-3", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "xunlu4-3", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc5", "Move", "xunlu5-3", 0, 1, 1, 0, 0},

			{"BlackMsg", "继续护送"},
			{"NpcBubbleTalk", "npc5", "临安还有多远啊？", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[12] = {nTime = 0, nNum = 13,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"AddNpc", 1, 12, 12, "gw", "guaiwu3", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 1, 12, "sl", "shouling3", false, 0, 0.5, 9005, 0.5},
			{"NpcBubbleTalk", "gw", "老子正想活动下筋骨呢！", 4, 1.1, 3},
			{"NpcBubbleTalk", "sl", "你们也想尝尝我大金铁蹄的滋味吗？", 4, 1.1, 1},
			{"BlackMsg", "击败忽然出现的金兵！"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[13] = {nTime = 3, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"PlayerBubbleTalk", "金人似乎越来越多了！"},
			{"NpcBubbleTalk", "npc1", "哼，你们先听着我的琴曲安息吧！", 3, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[14] = {nTime = 0, nNum = 2,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "xunlu-4", 14, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-4", 14, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "xunlu2-4", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "xunlu3-4", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "xunlu4-4", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc5", "Move", "xunlu5-4", 0, 1, 1, 0, 0},

			{"BlackMsg", "继续护送宰相棺椁"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[15] = {nTime = 0, nNum = 11,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "又是埋伏？", 3, 0, 1},
			{"PlayerBubbleTalk", "用过的套路还有效吗？"},

			{"AddNpc", 3, 10, 15, "gw", "guaiwu4", false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 15, "sl", "shouling4", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "gw", "找死！", 4, 2, 2},
			{"NpcBubbleTalk", "sl", "本座这关可不好过！", 4, 2, 1},
			{"BlackMsg", "击败埋伏的刺客！"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[16] = {nTime = 3, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			--{"PlayerBubbleTalk", "金人似乎越来越多了！"},
			{"NpcBubbleTalk", "npc1", "前面就快到临安了！", 3, 0.5, 1},
			{"NpcBubbleTalk", "npc4", "终于......", 2, 1, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[17] = {nTime = 0, nNum = 2,
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"ChangeNpcAi", "npc", "Move", "xunlu-5", 17, 0, 0, 0, 0},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-5", 17, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc2", "Move", "xunlu2-5", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc3", "Move", "xunlu3-5", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc4", "Move", "xunlu4-5", 0, 1, 1, 0, 0},
			{"ChangeNpcAi", "npc5", "Move", "xunlu5-5", 0, 1, 1, 0, 0},

			{"BlackMsg", "往临安进发"},	
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 4, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"PlayerBubbleTalk", "我感到了高手的气息！"},
			{"NpcBubbleTalk", "npc1", "我也感觉到了，此人非同寻常，大家小心！", 3, 2, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"AddNpc", 1, 12, 0, "gw", "guaiwu5", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 6, 1, 19, "sl", "shouling5", false, 0, 0.5, 9005, 0.5},
			--{"NpcBubbleTalk", "gw", "老子正想活动下筋骨呢！", 4, 1.5, 2},
			{"NpcBubbleTalk", "sl", "我已经恭候多时了，哈哈哈！", 4, 1.5, 1},
			{"BlackMsg", "击败拦路的高手！"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"CloseLock", 20},
		},
	},
	[20] = {nTime = 10, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 5, 12, 0, "gw1", "guaiwu5", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "sl", "兄弟们都出来吧！", 4, 0, 1},

			{"PlayerBubbleTalk", "这些是宋军？"},
			{"NpcBubbleTalk", "npc1", "都是投降金国的废物！", 3, 2, 1},
			{"NpcBubbleTalk", "gw1", "不识时务！", 3, 5, 2},
		},
	},
	[21] = {nTime = 1, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "吁，终于把这个大家伙打败了！", 3, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {21},
		tbStartEvent = 
		{
			{"RaiseEvent", "ShowTaskDialog", 22, 1146, false},	--剧情1
			{"SetNpcBloodVisable", "npc", false, 0},
			{"SetNpcBloodVisable", "npc1", false, 0},
			{"SetNpcBloodVisable", "npc2", false, 0},
			{"SetNpcBloodVisable", "npc3", false, 0},
			{"SetNpcBloodVisable", "npc4", false, 0},
			{"SetNpcBloodVisable", "npc5", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"NpcBubbleTalk", "npc1", "过来看吧，前面就是临安了！", 5, 0, 1},
			{"ChangeNpcAi", "npc1", "Move", "xunlu1-6", 23, 1, 1, 0, 0},

			--{"PlayCameraEffect", 9119},
			--{"SetPos", 5493, 4209},
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "npc1", 0},
			--{"ClearTargetPos"},
		},
	},
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent = 
		{
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true, false},	
			--{"PlaySceneCameraAnimation", "baishuisi_cam1", "baishuisi_cam1", 23},
			{"PlayCameraAnimation", 1, 24},
			{"PlayEffect", 9220, 0, 0, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[25] = {nTime = 5, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
			{"OpenWindow", "StoryBlackBg", "你和霜儿终于护送丞相的棺椁冲过了这片艰险之地，临安就在眼前...", nil, 5, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"GameWin"},
		},
	},


}
