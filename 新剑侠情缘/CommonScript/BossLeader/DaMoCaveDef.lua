BossLeader.DaMoCave = BossLeader.DaMoCave or {}
local DaMoCave = BossLeader.DaMoCave

DaMoCave.Def = {
	bOpen = true;
	nKinRank = 5;			--每个服务器前几名获得资格
	nSecretPassageCount = 3;			--密道刷新的数量（一、二层加起来）
	nSyncDmgCount = 5;		--同步前几名的伤害
	--地图相关信息
	tbMapSetting = {
		[1] = {							--第一层，十个房间，每个房间是单独的地图
			nMapTemplateId = 8020,
			nMapCount = 10,				--一共有多少个房间

			tbRevivePos = {{3214, 6497}, {5671, 2718}},	--复活点（传入点）位置（可以多填，会依次放入家族）

			tbTransferNpcInfo = {
				[1] = {		--一层第一次刷传送使者的相关配置
					[1] = {
						nNpcTemplateId = 3816,			--传送使者模板ID
						nRoomCount = 10,				--随机在几个房间刷
						nNpcCount = 1,				--每个房间随机刷几个
					},
					tbPos = {{7081, 8565}},	--如果比nNpcCount多，就在这些坐标里随机nNpcCount个
				};
				[2] = {		--一层第二次刷传送使者的相关配置
					[1] = {
						nNpcTemplateId = 3816,
						nRoomCount = 5,
						nNpcCount = 1,
					},
					tbPos = {{7081, 8565}},
				};
			};

			tbBossInfo = {
				[1] = {		--一层第一次刷新BOSS的相关配置
					[1] = {
						nNpcTemplateId = 3814,			--一层第一个BOSS模板ID
						nRoomCount = 5,
						nNpcCount = 1,
					},
					tbPos = {{7075, 7227}},
				};
				[2] = {		--一层第二次刷新BOSS的相关配置
					[1] = {
						nNpcTemplateId = 3814,			--一层第二个BOSS模板ID
						nRoomCount = 3,
						nNpcCount = 1,
					},
					[2] = {
						nNpcTemplateId = 3813,			--一层第二个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 1,
					},
					tbPos = {{7075, 7227}},
				};
			};

			tbSecretPassagePos = {{6857, 9096}};	--一层密道刷新的坐标（先随机房间，随机到的房间再从这些坐标中随机1个）

			tbSameFloorTransferPos = {			--同层传送时传入的坐标点
				{10619, 3441};			--往前一个房间传送，传入的坐标（比如2号传送到1号）对应Trap点:PreRoom
				{3095, 11167};			--往后一个房间传送，传入的坐标（比如2号传送到3号）对应Trap点:NextRoom
			};

			tbSameFloorTransferNpcPos = {		--同层传送光圈NPC坐标点
				{2901, 11318},
				{11032, 3074}
			};

			tbTransferBackPos = {{9045,9096}};			--从二层传送回一层的坐标		对应Trap点:二层Downstairs1,Downstairs2...
		};
		[2] = {							--二层，和三层共用一张地图
			nMapTemplateId = 8021,
			nMapCount = 1,

			tbTransferNpcInfo = {
				[1] = {		--二层第一次刷传送使者的相关配置（和一层第二次同时）
					[1] = {
						nNpcTemplateId = 3817,			--传送使者模板ID
						nRoomCount = 1,				--二层只有一个地图，保证这里是1
						nNpcCount = 5,				--随机刷几个
					},
					tbPos = {{7286, 2543}, {14887, 5612}, {14698, 13041}, {7162, 15638}, {2658, 9327}},	--如果比nNpcCount多，就在这些坐标里随机nNpcCount个
				};
			};

			tbBossInfo = {
				[1] = {		--二层第一次刷新BOSS的相关配置
					[1] = {
						nNpcTemplateId = 3818,			--二层第一个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 5,
					},
					tbPos = {{7286, 2543}, {14887, 5612}, {14698, 13041}, {7162, 15638}, {2658, 9327}},
				};
				[2] = {		--二层第二次刷新BOSS的相关配置
					[1] = {
						nNpcTemplateId = 3818,			--二层第二个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 3,
					},
					[2] = {
						nNpcTemplateId = 3813,			--二层第二个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 1,
					},
					[3] = {
						nNpcTemplateId = 3815,			--二层第二个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 1,
					},
					tbPos = {{7286, 2543}, {14887, 5612}, {14698, 13041}, {7162, 15638}, {2658, 9327}},
				};
			};

			tbReviveFlagInfo = {		--复活旗子的相关配置
				[1] = {
					[1] = {
						nNpcTemplateId = 3828,			--复活旗子模板ID
						nRoomCount = 1,
						nNpcCount = 5,
					},
					tbPos = {{3623, 6954}, {9944, 3139}, {15566, 8068}, {12690, 14259}, {5448, 14353}},
				};
			};

			tbSecretPassagePos = {{1399, 8785}, {7756, 1767}, {16367, 5500}, {15436, 14257}, {6186, 16780}};	--二层密道刷新的坐标（因为只有一个房间，直接随机坐标）

			tbTransferInPos = {			--一层传送到二层的坐标（传送使者）	对应Trap点：一层Upstairs1,Upstairs2...
				{860, 9356},		--1、2号房间传送过来的坐标
				{6936, 1211},		--3、4号房间传送过来的坐标
				{16509, 4583},		--5、6号房间传送过来的坐标
				{16278, 14057},		--7、8号房间传送过来的坐标
				{6619, 17389},		--9、10号房间传送过来的坐标
			};

			tbTransferBackPos = {{4587, 9321}, {7983, 4803}, {13417, 6648}, {13251, 12001}, {7818, 13839}},		--从三层传送回二层的坐标
		};
		[3] = {							--三层和二层是同一个地图
			nMapCount = 1,	--同一个地图，二层已经创建过了，不要填MapTemplateId

			tbBossInfo = {
				[1] = {		--三层第一次刷新BOSS的相关配置（和一二层第二次刷新同时）
					[1] = {
						nNpcTemplateId = 3815,			--三层第一个BOSS模板ID
						nRoomCount = 1,
						nNpcCount = 1,
					},
					tbPos = {{9231, 9288}},
				};
			};
			tbTransferInPos = {{5270, 9341}, {8202, 5487}, {12926, 7013}, {12879, 11703}, {8112, 13225}};	--二层传送使者传过来的坐标		对应Trap点：二层Upstairs1,Upstairs2...

			tbSecretPassagePos = {{12425, 13514}, {14739, 8992}};	--密道传入到第三层的坐标
		};
	};

	--时间流程
	tbProcessSetting = {	--用到达当前阶段的累积时间
		[1]--[[00:45]] = {50,	{{"CountdownTips"}}	},
		[2]--[[01:00]] = {60,	{{"StartBattle"}}	},
		[3]--[[01:05]] = {65,	{{"RefreshNpc", 1, 1, "TransferNpc"}, {"SendSysMsg", "达摩洞一层的传送使者刷新了，快去抢夺吧！"}}	},
		[4]--[[05:00]] = {300,	{{"RefreshNpc", 1, 1, "Boss"}, {"RefreshNpc", 2, 1, "Boss"}, 
									{"SendSysMsg", "达摩洞一层和二层分别刷新了护洞卫士，快去抢夺吧"}}	},
		[5]--[[10:00]] = {600,	{{"RefreshNpc", 1, 2, "TransferNpc"}, {"RefreshNpc", 2, 1, "TransferNpc"}, {"RefreshNpc", 2, 1, "ReviveFlag"}, 
									{"SendSysMsg", "达摩洞一层和二层的传送使者和二层外围的复活旗帜刷新了，快去抢夺吧！"}}	},
		[6]--[[15:00]] = {900,	{{"RefreshNpc", 1, 2, "Boss"}, {"RefreshNpc", 2, 2, "Boss"}, {"RefreshNpc", 3, 1, "Boss"}, {"RefreshSecretPassage"}, 
									{"SendSysMsg", "达摩和护卫均已苏醒，快去抢夺吧！通往三层的密道已在一层和二层各房间随机位置刷新！"}, {"AllBossRefreshed"}}	},
		[7]--[[30:00]] = {1800,	{{"EndActivity"}} 	},
	};
	--血量触发事件
	tbBossHpEvent = {
		--[3815] = {{0.7, "CallAttachNpc"}, {0.3, "CallAttachNpc"}},
	},
	--召唤出来的NPC
	tbAttachNpc = {
		--｛模板ID, X , Y｝
		{3829, 8085, 11206}, --NPC类型用DaMoCaveNpc, param用 AttachNpc
		{3829, 11094, 10551},
		{3829, 11046, 7906},
		{3829, 7976, 7700},
	},
	--无敌buffId
	nInvincibleBuffId = 930,
	--阶段倒计时提醒
	tbStateTips = {
		--跟时间流程对应
		[3] = {
			--[1]外层地图的提醒, [2]内层地图提醒
			[1] = "传送使者即将刷新",
		},
		[4] = {
			[1] = "护洞卫士即将刷新",
			[2] = "达摩护卫即将刷新",
		},
		[5] = {
			[1] = "传送使者即将刷新",
			[2] = "传送使者和复活旗帜即将刷新",
		},
		[6] = {
			[1] = "护洞卫士即将刷新",
			[2] = "达摩和护卫即将刷新",
		},
		[7] = {
			[1] = "活动结束倒计时",
			[2] = "活动结束倒计时",
		}

	},

	nMinHpPercent = 0.01;			--最小伤害百分比，低于1%的按1%计算
	nFirstDmgHpPercent = 0.1;		--第一击额外的血量
	nLastDmgHpPercent = 0.1;		--最后一击额外的血量

	nPerPlayerJoinValue = 40000;	--每个玩家参与的价值量，决定本场活动保底
	--NPC被击杀家族增加的价值量
	tbNpcDeathValue = {
		["OpenLevel159"] = {
			--[NpcTemplateId] = nValue,总价值量会按每个家族的输出百分比加到家族身上
			[3813] = 20000000,
			[3814] = 15000000,
			[3815] = 35000000,
			[3816] = 5000000,
			[3817] = 5000000,
			[3818] = 15000000,
		},
		["OpenLevel169"] = {
			[3813] = 20000000,
			[3814] = 15000000,
			[3815] = 35000000,
			[3816] = 5000000,
			[3817] = 5000000,
			[3818] = 15000000,
		},
		["OpenLevel179"] = {
			[3813] = 20000000,
			[3814] = 15000000,
			[3815] = 35000000,
			[3816] = 5000000,
			[3817] = 5000000,
			[3818] = 15000000,
		},
	};
	--单个家族NPC价值量的上限，两个不同的NPC对应相同的类型，则两个NPC价值量相加共用一个上限
	tbNpcValueLimitType = {
		[3814] = "LIMIT_1",
		[3818] = "LIMIT_1",
		[3816] = "LIMIT_2",
		[3817] = "LIMIT_2",
		[3813] = "LIMIT_3",
		[3815] = "LIMIT_4",
	},
	tbLimitType2Value = {	--{Boss价值量上限， 每个参与玩家对应的价值量上限}
		LIMIT_1 = { 36000000,	360000},
		LIMIT_2 = { 4500000,	45000},
		LIMIT_3 = { 16000000,	160000},
		LIMIT_4 = { 28000000,	280000},
	},
	tbTrueOrFalse = {
		[3815] = true,
		[3813] = false,
	},

	tbNpcAuctionAwards = {
		["OpenLevel159"] = {
			[3813] = {
				{nRate = 2/8, nItemId = 1397, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11121, bSilver = true},
				{nRate = 1/8, nItemId = 3543, bSilver = false},
				{nRate = 1.5/8, nItemId = 10140, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
			};
			[3814] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1.5/8, nItemId = 11748, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 1/8, nItemId = 2804, bSilver = false},
			};
			[3815] = {
				{nRate = 2/8, nItemId = 1397, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11121, bSilver = true},
				{nRate = 1/8, nItemId = 3543, bSilver = false},
				{nRate = 1.5/8, nItemId = 10140, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
			};
			[3816] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1.5/4, nItemId = 4595, bSilver = false},
				{nRate = 1.5/4, nItemId = 6112, bSilver = false},
			};
			[3817] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1.5/4, nItemId = 4595, bSilver = false},
				{nRate = 1.5/4, nItemId = 6112, bSilver = false},
			};
			[3818] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1.5/8, nItemId = 11748, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 1/8, nItemId = 2804, bSilver = false},
			};
		};
		["OpenLevel169"] = {
			[3813] = {
				{nRate = 1.5/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11974, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11976, bSilver = true},
				{nRate = 1/8, nItemId = 10140, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
			};
			[3814] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 1/8, nItemId = 11974, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1/8, nItemId = 11977, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 0.5/8, nItemId = 2804, bSilver = false},
			};
			[3815] = {
				{nRate = 1.5/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11974, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11976, bSilver = true},
				{nRate = 1/8, nItemId = 10140, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
			};
			[3816] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1/4, nItemId = 4595, bSilver = false},
				{nRate = 1/4, nItemId = 6112, bSilver = false},
				{nRate = 0.5/4, nItemId = 11121, bSilver = true},
				{nRate = 0.5/4, nItemId = 11748, bSilver = true},
			};
			[3817] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1/4, nItemId = 4595, bSilver = false},
				{nRate = 1/4, nItemId = 6112, bSilver = false},
				{nRate = 0.5/4, nItemId = 11121, bSilver = true},
				{nRate = 0.5/4, nItemId = 11748, bSilver = true},
			};
			[3818] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 1/8, nItemId = 11974, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1/8, nItemId = 11977, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 0.5/8, nItemId = 2804, bSilver = false},
			};
		};
		["OpenLevel179"] = {
			[3813] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11974, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11976, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
				{nRate = 1.5/8, nItemId = 3549, bSilver = true},
			};
			[3814] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 1/8, nItemId = 11974, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1/8, nItemId = 11977, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 0.5/8, nItemId = 2804, bSilver = false},
			};
			[3815] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 2/8, nItemId = 11974, bSilver = true},
				{nRate = 1.5/8, nItemId = 11978, bSilver = false},
				{nRate = 1/8, nItemId = 11976, bSilver = true},
				{nRate = 1/8, nItemId = 10014, bSilver = true},
				{nRate = 1.5/8, nItemId = 3549, bSilver = true},
			};
			[3816] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1/4, nItemId = 4595, bSilver = false},
				{nRate = 1/4, nItemId = 6112, bSilver = false},
				{nRate = 0.5/4, nItemId = 11121, bSilver = true},
				{nRate = 0.5/4, nItemId = 11748, bSilver = true},
			};
			[3817] = {
				{nRate = 0.5/4, nItemId = 2804, bSilver = false},
				{nRate = 0.5/4, nItemId = 10014, bSilver = true},
				{nRate = 1/4, nItemId = 4595, bSilver = false},
				{nRate = 1/4, nItemId = 6112, bSilver = false},
				{nRate = 0.5/4, nItemId = 11121, bSilver = true},
				{nRate = 0.5/4, nItemId = 11748, bSilver = true},
			};
			[3818] = {
				{nRate = 1/8, nItemId = 1397, bSilver = true},
				{nRate = 1/8, nItemId = 11974, bSilver = true},
				{nRate = 2/8, nItemId = 11979, bSilver = false},
				{nRate = 2/8, nItemId = 11980, bSilver = false},
				{nRate = 1/8, nItemId = 11977, bSilver = true},
				{nRate = 0.5/8, nItemId = 10014, bSilver = true},
				{nRate = 0.5/8, nItemId = 2804, bSilver = false},
			};
		};
	};
	tbBaodiAuctionAwards = {
		["OpenLevel159"] = {
			{nRate = 1/4, nItemId = 5564, bSilver = false},
			{nRate = 0.5/4, nItemId = 2804, bSilver = false},
			{nRate = 0.5/4, nItemId = 4319, bSilver = false},
			{nRate = 1/4, nItemId = 4320, bSilver = false},
			{nRate = 1/4, nItemId = 10983, bSilver = false},
		},
		["OpenLevel169"] = {
			{nRate = 1/4, nItemId = 5565, bSilver = false},
			{nRate = 0.5/4, nItemId = 2804, bSilver = false},
			{nRate = 0.5/4, nItemId = 4319, bSilver = false},
			{nRate = 1/4, nItemId = 4320, bSilver = false},
			{nRate = 1/4, nItemId = 10983, bSilver = false},
		},
		["OpenLevel179"] = {
			{nRate = 1/4, nItemId = 5566, bSilver = false},
			{nRate = 0.5/4, nItemId = 2804, bSilver = false},
			{nRate = 0.5/4, nItemId = 4319, bSilver = false},
			{nRate = 1/4, nItemId = 4320, bSilver = false},
			{nRate = 1/4, nItemId = 10983, bSilver = false},
		},
	},

	szDmgPanelTips = [[奖励规则：
			·输出排名进入前5的家族，可获得奖励
			·奖励获得的多少，与输出的占比相关
			·传送使者、护洞卫士、达摩护卫每只独立计算输出
			·首次攻击以及最后一击有额外的奖励加成
	]],
	tbDesc = {
		[-1] = [[
			[11ADF6]参战须知[-]：
			达摩洞共分三层
			各家族点击“参加”，会[FFFE0D]随机传送[-]到一层的某个房间内
			在洞内死亡，默认在该房间复活
			[FFFE0D]抢占二层的复活旗帜，可以在二层快速复活[-]
			点击左侧对应房间按钮，可以查看房间详情
		]],
		[1] = [[
			[11ADF6]房间名[-]：达摩洞一层%s

			[11ADF6]出没怪物[-]：
			[11ADF6]传送使者[-]
			对其输出最高的家族成员获得进入二层的权利
			共刷新两轮
			第一轮每个房间刷新1个
			第二轮随机[FFFE0D]5[-]个房间刷新
			[AA62FC]护洞卫士[-]
			共刷新两轮
			第一轮随机[FFFE0D]5[-]个房间刷新
			最后阶段随机[FFFE0D]3[-]个房间刷新
			[ff8f06]达摩[-]
			最后阶段随机[FFFE0D]1[-]个房间刷新
		]],
		[2] = [[
			[11ADF6]房间名[-]：达摩洞二层%s

			[11ADF6]出没怪物[-]：
			[11ADF6]传送使者[-]
			对其输出最高的家族成员获得进入三层的权利
			[AA62FC]达摩护卫[-]
			共刷新两轮
			第一轮每个房间刷新1个
			最后阶段随机[FFFE0D]3[-]个房间刷新
			[ff8f06]达摩[-]
			最后阶段随机刷新2个
		]],
		[3] = [[
			[11ADF6]房间名[-]：达摩洞三层

			[11ADF6]出没怪物[-]：
			[ff8f06]达摩[-]
			最后阶段必定刷新[FFFE0D]1[-]个，且必为真身
		]],
	}
}

function DaMoCave:GetPrevNextRoomIndex(nCurRoomIndex)
	local nPrevRoomIndex = (nCurRoomIndex - 1) % self.Def.tbMapSetting[1].nMapCount
	local nNextRoomIndex = (nCurRoomIndex + 1) % self.Def.tbMapSetting[1].nMapCount
	if nPrevRoomIndex == 0 then
		nPrevRoomIndex = self.Def.tbMapSetting[1].nMapCount
	end
	if nNextRoomIndex == 0 then
		nNextRoomIndex = self.Def.tbMapSetting[1].nMapCount
	end
	return nPrevRoomIndex, nNextRoomIndex
end