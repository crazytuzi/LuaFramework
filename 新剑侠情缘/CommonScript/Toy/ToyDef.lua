Require("CommonScript/Player/PlayerDef.lua")
Toy.Def = {
	nInterval = 30,	--使用间隔（秒）

	szOpenTimeframe = "OpenLevel39",	--开放时间轴
	nGuideId = 51,	--引导id
	tbValidMaps = {	--生效的地图
		10, 15, 999, 1000, 1004,
		4000, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008,
	},

	nHideBuffId = 2321,	--隐身buff

	nWindmillResId = 1249,	--风车ResId
	nChildResId = 1248,	--迎客小童ResId
	nMechaResId = 3219,	--机甲ResId
	nSnowmanResId = 567,	--雪人ResId
	nSnowmanDir = 65,	--雪人朝向
	nDragonHeadResId = 3401,	--龙头ResId
	nDragonBodyResId = 3402,	--龙身ResId
	nDragonTailResId = 3403,	--龙尾ResId
	nFireResId = 1256,	--火娃ResId
	nWaterResId = 1257,	--水娃ResId

	tbDragonRewards = {	--接龙奖励
		[1] = {nMinMember = 5, nContrib = 2000,
			nLeaderRedbag = 0, nLeaderTitle = 0, nMasterRedbag = 0, nMasterTitle = 0,
			szWorldNotice = ""},
		[2] = {nMinMember = 10, nContrib = 4000,
			nLeaderRedbag = 0, nLeaderTitle = 0, nMasterRedbag = 0, nMasterTitle = 0,
			szWorldNotice = ""},
		[3] = {nMinMember = 20, nContrib = 6000,
			nLeaderRedbag = 215, nLeaderTitle = 10304, nMasterRedbag = 216, nMasterTitle = 10304,
			szWorldNotice = "恭喜%s家族组成20人长龙，流光溢彩，仿佛真龙现世。"},
		[4] = {nMinMember = 30, nContrib = 8000,
			nLeaderRedbag = 217, nLeaderTitle = 0, nMasterRedbag = 218, nMasterTitle = 0,
			szWorldNotice = "恭喜%s家族组成30人长龙，流光溢彩，仿佛真龙现世。"},
		[5] = {nMinMember = 50, nContrib = 10000,
			nLeaderRedbag = 219, nLeaderTitle = 10305, nMasterRedbag = 220, nMasterTitle = 10305,
			szWorldNotice = "恭喜%s家族组成50人长龙，流光溢彩，仿佛真龙现世。"},
		[6] = {nMinMember = 70, nContrib = 20000,
			nLeaderRedbag = 221, nLeaderTitle = 0, nMasterRedbag = 222, nMasterTitle = 0,
			szWorldNotice = "恭喜%s家族组成70人长龙，流光溢彩，仿佛真龙现世。"},
		[7] = {nMinMember = 100, nContrib = 30000,
			nLeaderRedbag = 223, nLeaderTitle = 10306, nMasterRedbag = 224, nMasterTitle = 10306,
			szWorldNotice = "恭喜%s家族组成100人长龙，流光溢彩，仿佛真龙现世。"},
	},

	nPigResId = 20304,	--猪ResId
	szPigBubbleTalk = "哼哼~",	--变成猪后冒泡内容
	nPigLastTime = 10,	--变猪效果持续时间（秒）

	nDragonDisRange = {80, 130},	--龙连接距离范围
	nDragonMaxDir = 10,	--龙连接最大朝向差

	tbDragonConnectBuffIds = {	--连接成功 玩家Buff id
		head = 4752,	--头
		body = 4753,	--身
		tail = 4754,	--尾
	},

	nForbiddenMoveBuffId = 1064,	--禁止移动buff id

	tbStatueId = { --各门派对应的雕像npcid 分别为男女
		[1]	 = {3290, 3291};--天王
		[2]	 = {3292, 3292};--峨嵋
		[3]	 = {3293, 3293};--桃花
		[4]	 = {3294, 3789};--逍遥
		[5]	 = {3295, 3296};--武当
		[6]	 = {3838, 3297};--天忍
		[7]	 = {3298, 3298};--少林
		[8]	 = {3299, 3299};--翠烟
		[9]	 = {3300, 3300};--唐门
		[10] = {3302, 3301};--昆仑
		[11] = {3303, 3792};--丐帮
		[12] = {3305, 3305};--五毒
		[13] = {3304, 3304};--藏剑山庄
		[14] = {3306, 3306};--长歌门
		[15] = {3307, 3308};--天山
		[16] = {3309, 3310};--霸刀
		[17] = {3311, 3312};--华山
		[18] = {3313, 3314};--明教
		[19] = {3787, 3788};--段氏
		[20] = {3790, 3791};--万花
		[21] = {3836, 3837};--杨门
	},

	nDanceRange = 1000,	--天魔笛作用范围

	nStickRange = 1000,	--糖葫芦作用范围
	tbStickBuff = {4751, 1, 300},	--糖葫芦buff {id, 等级, 持续时间（秒）}

	nGreenHatId = 9542,	--绿帽子道具id
	nGreenHatGivenId = 9564,	--可穿戴绿帽子道具id

	nLightNpcId = 3252,	--琉璃灯NPC id
	nLightDuration = 10,	--琉璃灯存活时间（秒）

	nKongmingNpcId = 3703,	--孔明灯NPC id
	nKongmingDuration = 8.5,	--孔明灯存活时间（秒）

	nWineJarNpcId = 3286,	--酒坛NPC id
	nWineJarDuration = 20,	--酒坛存活时间（秒）
	szWineJarBubble = "来来来~干杯！",	--使用酒坛后玩家头顶冒泡文字
	nWineJarDanceBQ = 5,	--使用酒坛后跳舞表情id

	nEnsignNpcId = 3752,	--军旗NPC id
	nEnsignDuration = 20,	--军旗存活时间（秒）

	nFireworkId = 11738,	--烟花道具id
	nFireworkNpcId = 3821,	--烟花NPC id
	nFireworkDuration = 300,	--烟花特效持续时间（秒）
	nFireworkNpcDir = 40,	--烟花npc的朝向
	nFireworkNpcDirKin = 57,	--烟花npc的朝向（家族属地）
	szFireworkNotice = "「%s」在「%s」对「%s」使用了传说中的【鸾凤和鸣】：相遇是缘，相思渐缠，恐山高路远，相见甚难，故托鸿雁，快捎传。从此鸾凤相随，风霜不断其情，流年不改其意，一生一世，相许相从！正是款款东南望，一曲凤求凰！",	--世界公告

	nMaskId = 9566,	--面具道具id
	nMaskRange = 1000,	--面具对话距离
	tbMasks = {	--面具配置
		[Player.SEX_MALE] = {	--男性玩家变身
			{
				nResId = 5032,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"吾辈当以家国天下为己任！",
					"习武如逆水行舟，不进则退。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5200] = {	--其他玩家变身ResId
						"守这天下却没了你，琳儿，你可曾怪我。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"晚辈拜见盟主！",
				},
			},
			{
				nResId = 5027,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"独战天下只为她！",
					"我本塞外客，天下任我行。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[6129] = {	--其他玩家变身ResId
						"若雪，可还记得当初的相遇。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"人间风光阅尽，大侠羡煞旁人。",
				},
			},
			{
				nResId = 6101,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"有人见到眉儿了吗？",
					"不知道轩儿最近过得如何。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5177] = {	--其他玩家变身ResId
						"你是古灵精怪的小女孩真儿吗？",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"大侠与几位姑娘的姻缘皆由我见证。",
				},
			},
			{
				nResId = 5119,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"看我漫天花雨，哈哈，骗你的。",
					"少侠可愿往唐家堡一游？",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5158] = {	--其他玩家变身ResId
						"我寻了半生的春天，你一笑便是了。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"见过唐门大公子！",
					"公子可是在找去翠烟门的路？",
				},
			},
			{
				nResId = 5193,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"情不敢至深，恐大梦一场。",
					"此生如梦如幻，终是逃不开宿命。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5126] = {	--其他玩家变身ResId
						"此生纷繁如梦，还好有你，彩虹。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"谁的人生不是大梦一场。",
					"执子之手，与子偕老，大侠终成眷侣。",
				},
			},
		},
		[Player.SEX_FEMALE] = {	--女性玩家变身
			{
				nResId = 5200,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"人间不过机缘巧合，都是缘分。",
					"一往情深是你，血海深仇也是你。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[34] = {	--其他玩家变身ResId
						"独孤大哥，相遇已是不易，还愿你不忘当年之志。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"姑娘历尽风波，心胸令人敬佩。",
				},
			},
			{
				nResId = 6129,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"世界上最远的距离，就是不能爱你。",
					"对错是非都已经看不清了。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5027] = {	--其他玩家变身ResId
						"经年浮华，终不过你的眼眸。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"此生得一人，愿倾盖如故。",
				},
			},
			{
				nResId = 5177,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"你可见过枫哥？",
					"也不知道爹爹最近如何了。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[6101] = {	--其他玩家变身ResId
						"杨大哥是不是又招惹了哪家姑娘？",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"纳兰姑娘何时从忘忧岛出来的？",
				},
			},
			{
				nResId = 5158,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"少侠可敢往翠烟门一游？",
					"我翠烟门人自是天生丽质。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5119] = {	--其他玩家变身ResId
						"影哥为我独闯翠烟，这一生便是你了。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"在下见过翠烟门主。",
				},
			},
			{
				nResId = 5126,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"此生斑驳复杂，谁又说的清。",
					"心有所托，方能安身。",
				},
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5193] = {	--其他玩家变身ResId
						"如梦，往事已去，只愿伴君朝朝暮暮。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"请教姑娘塞外风光如何。",
				},
			},
		},
	},

	--
	-- 以下由程序配置
	--
	nUnlockSaveGrp = 178,
	nUseCountSaveGrp = 179,
	nDragonRewardGrp = 187,
}

Toy.Def.tbMustHaveItem = {
	ToyHat = Toy.Def.nGreenHatId,
	ToyMask = Toy.Def.nMaskId,
	ToyFirework = Toy.Def.nFireworkId,
}

Toy.Def.tbNeedTarget = {
	ToyHat = true,
	ToyLaugh = true,
	ToyStick = true,
	ToyPig = true,
	ToyFirework = true,
}