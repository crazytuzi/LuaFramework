--#include "..\..\..\language\LangCode.txt"
--#include "data\functions\Common\RankDef.lua" once 		--排行榜

OpenServerCfg = {

	OpenServerDay = 7,--活动天数 从开服第一天开始算
	openLevel = 20,   --开放等级

	OpenServerCircleRate = 1000, --程序用字段，策划不要改
	OpenServerVIPRate = 100000000, --程序用字段，策划不要改

	GuildSiege = --攻城战
	{
		activityDesc = Lang.ScriptTips.OpenServer026,
		day = 4, 		--开服第N天的攻城战处理
		leaderAwards = --给首领的额外奖励
		{			
			{ type = 0, id = 4081, count = 50, quality = 0, strong = 0, bind = 0, importantLevel=1 },
			{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, importantLevel=1 },
			{ type = 0, id = 4081, count = 50, quality = 0, strong = 0, bind = 0, importantLevel=1 },
			{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, importantLevel=1 },
			{ type = 0, id = 4081, count = 50, quality = 0, strong = 0, bind = 0, importantLevel=1 },
		},
		memberAwards = --给成员的额外奖励  没有就注销掉
		{--成员			
			--{type = 0,id = 938,count = 25,quality = 0,strong = 0,bind =1},  
			--{type = 0,id = 762,count = 25,quality = 0,strong = 0,bind =1},
			--{type = 0,id = 1029,count = 25,quality = 0,strong = 0,bind =1},
			--{type = 0,id = 1031,count = 10,quality = 0,strong = 0,bind =1},
			--{type = 0,id = 786,count = 5,quality = 0,strong = 0,bind =1},
		},
	},


	Boss = --全民boss
	{
		activityDesc = Lang.ScriptTips.OpenServer025,
		
		--玛雅神殿1			
		{	
			bossIds = { 592, 593, 594, 595 }, 			
			fun = {"Boss",10},
			awards = 
			{
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4082, count = 3, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4448, count = 3, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4264, count = 10, quality = 0, strong = 0, bind = 1, },
			},
		},
						
		--玛雅神殿2		
		{	
			bossIds = { 591, 596, 597, 599 }, 			
			fun = {"Boss",10},
			awards = 
			{
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4083, count = 3, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4091, count = 30, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4264, count = 10, quality = 0, strong = 0, bind = 1, },
			},
		},
						
		--玛雅神殿3			
		{	
			bossIds = { 1628, 1629, 1624, 1623 }, 			
			fun = {"Boss",10},
			awards = 
			{
				{ type = 0, id = 4271, count = 3, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4278, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4084, count = 5, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4483, count = 4, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4265, count = 2, quality = 0, strong = 0, bind = 1, },
			},
		},
						
		--BOSS之家				
		{	
			bossIds = { 263, 261, 262, 264 }, 			
			fun = {"Boss",70},
			awards = 
			{
				{ type = 0, id = 4271, count = 5, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4279, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4085, count = 5, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4048, count = 2, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4265, count = 3, quality = 0, strong = 0, bind = 1, },
			},
		},
	},				

	
								
							
			Recharge = --累积充值				
			{	
				startDay = 1,--第几天开始
				endDay = 7,--第几天结束
				desc = Lang.ScriptTips.OpenServerTotalRecharge006,
				Gold = {15000,49000,164000,324000,750000,1500000,3000000,5000000,10000000,17500000,25000000},     --充值元宝			
		        Rewards = 
				{			
					{     	--30			
						{type = 0, id = 410, count = 1, job = 1,  bind = 1,},
						{type = 0, id = 420, count = 1, job = 2,  bind = 1,},
						{type = 0, id = 430, count = 1, job = 3,  bind = 1,},
						{type = 0, id = 4535, count = 1, bind = 1,},
						{type = 0, id = 4213, count = 2, bind = 1,},
						{type = 0, id = 4484, count = 1, bind = 1,},
					},
					{     	--98			
						{type = 0, id = 470, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 480, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 490, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4536, count = 2, bind = 1,},
						{type = 0, id = 4218, count = 2, bind = 1,},
						{type = 0, id = 4484, count = 2, bind = 1,},
					},
					{     	--328			
						{type = 0, id = 530, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 540, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 550, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4537, count = 3, bind = 1,},
						{type = 0, id = 4092, count = 10, bind = 1,},
						{type = 0, id = 4484, count = 4, bind = 1,},
					},
					{     	--1			
						
						{type = 0, id = 381, count = 1, bind = 1,},
						{type = 0, id = 4538, count = 5, bind = 1,},
						{type = 0, id = 4092, count = 20, bind = 1,},--称号
						{type = 0, id = 4484, count = 7, bind = 1,},
					},
					{   	--2			
						{type = 0, id = 590, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 600, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 610, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4539, count = 5, bind = 1,},
						{type = 0, id = 4092, count = 30, bind = 1,},
						{type = 0, id = 4484, count = 10, bind = 1,},
					},
					{       --3			
						{type = 0, id = 650, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 660, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 670, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4540, count = 5, bind = 1,},
						{type = 0, id = 4092, count = 50, bind = 1,},
						{type = 0, id = 4485, count = 1, bind = 1,},
					},
					{  		--4			
						{type = 0, id = 710, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 720, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 730, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4541, count = 5, bind = 1,},
						{type = 0, id = 4092, count = 100, bind = 1,},
						{type = 0, id = 4485, count = 2, bind = 1,},
					},
					{  		--5			
						{type = 0, id = 770, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 780, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 790, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4500, count = 3, bind = 1,},--
						{type = 0, id = 4092, count = 300, bind = 1,},--
						{type = 0, id = 4485, count = 4, bind = 1,},
						
					},
					{  		--6			
						{type = 0, id = 830, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 840, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 850, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4542, count = 5, bind = 1,},
						{type = 0, id = 4092, count = 500, bind = 1,},
						{type = 0, id = 4485, count = 7, bind = 1,},
					},
					{  		--7								            					
						{type = 0, id = 890, count = 1,job = 1,  bind = 1,},
						{type = 0, id = 900, count = 1,job = 2,  bind = 1,},
						{type = 0, id = 910, count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4543, count = 5, bind = 1,},
						{type = 0, id = 4025, count = 50, bind = 1,},
						{type = 0, id = 4485, count = 10, bind = 1,},
					},
					{  		--8			
					            					
						{type = 0, id = 950,  count = 1,job = 1,  bind = 1,},
						{type = 0, id = 960,  count = 1,job = 2,  bind = 1,},
						{type = 0, id = 970,  count = 1,job = 3,  bind = 1,},
						{type = 0, id = 4544, count = 5, bind = 1,},--宝箱
						{type = 0, id = 4025, count = 100, bind = 1,},--称号
						{type = 0, id = 4485, count = 15, bind = 1,},--转生丹
						

					},
				},
			},	


	RechargeRank = --充值排行
	{
		startDay = 1,--第几天开始
		endDay = 7,--第几天结束
		activityDesc = Lang.ScriptTips.OpenServer015,
		
		needMinValue = 5000, --上榜最低要求
		Awards =
		{
			{
				desc = Lang.ScriptTips.OpenServerRank001,
				icon = 1,
				cond = {1, 1},
				awards = 
				{
				    { type = 0, id = 1070, count = 1,job = 1,  bind = 1,},
					{ type = 0, id = 1080, count = 1,job = 2,  bind = 1,},
					{ type = 0, id = 1090, count = 1,job = 3,  bind = 1,},
					{ type = 0, id = 4681, count = 1, bind = 1,},
					{ type = 0, id = 4549, count = 5,  bind = 1, },
					{ type = 0, id = 4500, count = 3,  bind = 1, },
					{ type = 0, id = 4091, count = 5000,  bind = 1, },

				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank002,
				icon = 1,
				cond = {2, 4},
				awards = 
				{
				    { type = 0, id = 1010, count = 1,job = 1,  bind = 1,},
					{ type = 0, id = 1020, count = 1,job = 2,  bind = 1,},
					{ type = 0, id = 1030, count = 1,job = 3,  bind = 1,},
					{ type = 0, id = 4676, count = 1, bind = 1, },
					{ type = 0, id = 4548, count = 5, bind = 1, },
					{ type = 0, id = 4500, count = 1, bind = 1, },
					{ type = 0, id = 4091, count = 3000,  bind = 1, },
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank003,
				icon = 1,
				cond = {5, 10},
				awards = 
				{
				    { type = 0, id = 950,  count = 1, job = 1,  bind = 1,},
					{ type = 0, id = 960,  count = 1, job = 2,  bind = 1,},
					{ type = 0, id = 970,  count = 1, job = 3,  bind = 1,},
					{ type = 0, id = 4039, count = 200, bind = 1, },
					{ type = 0, id = 4546, count = 3, bind = 1, },
					
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank004,
				icon = 1,
				cond = {11, 20},
				awards = 
				{
				    { type = 0, id = 890,  count = 1, job = 1,  bind = 1,},
					{ type = 0, id = 900,  count = 1, job = 2,  bind = 1,},
					{ type = 0, id = 910,  count = 1, job = 3,  bind = 1,},
					{ type = 0, id = 4039, count = 100, bind = 1, },
					{ type = 0, id = 4543, count = 2, bind = 1, },
					
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank005,
				icon = 1,
				cond = {21, 100},
				awards = 
				{
				    { type = 0, id = 590, count = 1, job = 1,  bind = 1,},
					{ type = 0, id = 600, count = 1, job = 2,  bind = 1,},
					{ type = 0, id = 610, count = 1, job = 3,  bind = 1,},
					{ type = 0, id = 4539, count = 1, bind = 1, },
					

				},
			},
		},
	},

	ConsumeRank =  --消费排行
	{
		startDay = 1,--第几天开始
		endDay = 7,--第几天结束
		activityDesc = Lang.ScriptTips.OpenServer016,
		
		needMinValue = 150000, --上榜最低要求
		Awards =
		{
			{
				desc = Lang.ScriptTips.OpenServerRank011,
				icon = 1,
				cond = {1, 1},
				awards = 
				{
					{ type = 0, id = 4682, count = 1, sex = 0, bind = 1,},
					{ type = 0, id = 4683, count = 1, sex = 1, bind = 1,},
					{ type = 0, id = 4658, count = 5,  bind = 1, },
					{ type = 0, id = 4547, count = 5,  bind = 1, },					
					{ type = 0, id = 4449, count = 200,  bind = 1, },					
					{ type = 0, id = 4500, count = 3,  bind = 1, },
						
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank012,
				icon = 1,
				cond = {2, 4},
				awards = 
				{
									
					{ type = 0, id = 4677, count = 1, sex = 0, bind = 1,},
					{ type = 0, id = 4678, count = 1, sex = 1, bind = 1,},
					{ type = 0, id = 4657, count = 5, bind = 1, },
					{ type = 0, id = 4546, count = 5, bind = 1, },
					{ type = 0, id = 4449, count = 100,  bind = 1, },					
					{ type = 0, id = 4500, count = 1,  bind = 1, },
					
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank013,
				icon = 1,
				cond = {5, 10},
				awards = 
				{
					{ type = 0, id = 4485, count = 3,   bind = 1, },
					{ type = 0, id = 4655, count = 3,   bind = 1, },
					{ type = 0, id = 4545, count = 3,   bind = 1, },					
					{ type = 0, id = 4449, count = 50,  bind = 1, },				
					

					
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank014,
				icon = 1,
				cond = {11, 20},
				awards = 
				{
					{ type = 0, id = 4654, count = 3,   bind = 1, },
					{ type = 0, id = 4543, count = 3,   bind = 1, },
					{ type = 0, id = 4449, count = 10,  bind = 1, },
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank015,
				icon = 1,
				cond = {21, 100},
				awards = 
				{
					{ type = 0, id =4539 , count = 1,   bind = 1, },
				    { type = 0, id =4092 , count = 30,  bind = 1, },
				},
			},
			{
				desc = Lang.ScriptTips.OpenServerRank016,
				icon = 1,
				cond = {101, 9999},
				awards = 
				{
					{ type = 0, id =4536 , count = 1,  bind = 1, },
				},
			},
		},
	},

	Leveling = --疯狂冲级					
	{		
		--wndId = 362, --界面id
		itemWayId = 40,
		activityName = Lang.ScriptTips.OpenServerSportName001,
		activityDesc = Lang.ScriptTips.OpenServerSport001,
		openDay = 1, --第几日开放				
		endDay = 7,--第几日结束			
		BroadInfo = Lang.ScriptTips.OpenServerSportDesc001,
		big_show = {20,20},
		Awards = 
		{	
			--[[{
				desc = Lang.Activity.openDesc109,
				icon = 1,
				level = 80,
				circle = 11,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 501, count = 1, quality = 0, strong = 0, bind = 0, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc108,
				icon = 1,
				level = 80,
				circle = 9,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 502, count = 1, quality = 0, strong = 0, bind = 0,   },
					{ type = 0, id = 503, count = 1, quality = 0, strong = 0, bind = 0, sex = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},]]
			{
				desc = Lang.Activity.openDesc107,
				icon = 1,
				level = 80,
				circle = 7,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 381, count = 1, quality = 0, strong = 0, bind = 0, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc106,
				icon = 1,
				level = 80,
				circle = 5,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 352, count = 1, quality = 0, strong = 0, bind = 0, job = 1,  },
					{ type = 0, id = 362, count = 1, quality = 0, strong = 0, bind = 0, job = 2,  },
					{ type = 0, id = 372, count = 1, quality = 0, strong = 0, bind = 0, job = 3,  },
					{ type = 0, id = 353, count = 1, quality = 0, strong = 0, bind = 0, job = 1, sex = 1,},
					{ type = 0, id = 363, count = 1, quality = 0, strong = 0, bind = 0, job = 2, sex = 1,},
					{ type = 0, id = 373, count = 1, quality = 0, strong = 0, bind = 0, job = 3, sex = 1,},
					{ type = 0, id = 4092, count = 15, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc105,
				icon = 1,
				level = 80,
				circle = 4,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4483, count = 5, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4184, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc104,
				icon = 1,
				level = 80,
				circle = 3,
				maxCount = -1,--配置为-1不限制数量		
				awards = 
				{
					{ type = 0, id = 4483, count = 3, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 5, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc103,
				icon = 1,
				level =80,
				circle = 2,
				maxCount = -1,--配置为-1不限制数量		
				awards = 
				{
					{ type = 0, id = 4483, count = 2, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc102,
				icon = 1,
				level = 80,
				circle = 1,
				maxCount = -1,--配置为-1不限制数量		
				awards = 
				{
					{ type = 0, id = 4483, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc101,
				icon = 1,
				level = 80,
				circle = 0,
				maxCount = -1,--配置为-1不限制数量		
				awards = 
				{
					{ type = 0, id = 4215, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},
			},
		},
	},
	Swing = --华丽羽翼					
	{		
		--wndId = 371, --界面id	
		itemWayId = 41,
		activityName = Lang.ScriptTips.OpenServerSportName002,
		activityDesc = Lang.ScriptTips.OpenServerSport002,
		openDay = 2,
		endDay = 7,--第几日结束			
		BroadInfo = Lang.ScriptTips.OpenServerSportDesc002,
		big_show = {6,14},
		Awards = 
		{	
			{
				desc = Lang.Activity.openDesc207,
				icon = 80,
				param = 8,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 800, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc206,
				icon = 74,
				param = 7,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 500, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 15, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc205,
				icon = 25,
				param = 6,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 300, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4185, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc204,
				icon = 26,
				param = 5,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 150, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 5, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc203,
				icon = 27,
				param = 4,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 100, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc202,
				icon = 28,
				param = 3,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4091, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc201,
				icon = 29,
				param = 2,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id =4091, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id =4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},
			},
		},
	},
	HeroRune = --英雄符文					
	{		
		--wndId = 371, --界面id
		itemWayId = 42,
		activityName = Lang.ScriptTips.OpenServerSportName003,
		activityDesc = Lang.ScriptTips.OpenServerSport003,
		openDay = 3,
		endDay = 7,--第几日结束			
		BroadInfo = Lang.ScriptTips.OpenServerSportDesc003,
		big_show = {6,14},
		Awards = 
		{	
			{
				desc = Lang.Activity.openDesc307,
				icon = 30,
				param = 71,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 80, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc306,
				icon = 30,
				param = 61,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 15, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc305,
				icon = 30,
				param = 51,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 30, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4186, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc304,
				icon = 30,
				param = 41,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 18, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 5, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc303,
				icon = 30,
				param = 31,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 12, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc302,
				icon = 30,
				param = 21,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 8, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc301,
				icon = 30,
				param = 11,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4448, count = 3, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},
			},
		},
	},
	Wuhun = --武魂				
	{		
		--wndId = 371, --界面id	
		itemWayId = 43,
		activityName = Lang.ScriptTips.OpenServerSportName004,
		activityDesc = Lang.ScriptTips.OpenServerSport004,
		openDay = 4,
		endDay = 7,--第几日结束			
		BroadInfo = Lang.ScriptTips.OpenServerSportDesc004,
		big_show = {6,14},
		Awards = 
		{	
			{
				desc = Lang.Activity.openDesc407,
				icon = 81,
				param = 71,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 80, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc406,
				icon = 49,
				param = 61,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 15, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc405,
				icon = 50,
				param = 51,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 30, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4187, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
						
				desc = Lang.Activity.openDesc404,
				icon = 51,
				param = 41,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 18, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 5, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc403,
				icon = 52,
				param = 31,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 12, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc402,
				icon = 53,
				param = 21,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 8, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc401,
				icon = 54,
				param = 11,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4084, count = 3, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},
			},
		},
	},
	SoulBall = --灵珠					
	{		
		--wndId = 371, --界面id	
		itemWayId = 44,
		activityName = Lang.ScriptTips.OpenServerSportName005,
		activityDesc = Lang.ScriptTips.OpenServerSport005,
		openDay = 5,
		endDay = 7,--第几日结束			
		BroadInfo = Lang.ScriptTips.OpenServerSportDesc005,
		big_show = {6,14},
		Awards = 
		{	
			{
				desc = Lang.Activity.openDesc507,
				icon = 82,
				param = 71,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 80, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc506,
				icon = 37,
				param = 61,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 15, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc505,
				icon = 38,
				param = 51,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 30, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4188, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc504,
				icon = 39,
				param = 41,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 18, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 5, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc503,
				icon = 40,
				param = 31,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 12, quality = 0, strong = 0, bind = 1, },
					--{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc502,
				icon = 41,
				param = 21,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 8, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 3, quality = 0, strong = 0, bind = 1, },
				},
			},
			{
				desc = Lang.Activity.openDesc501,
				icon = 42,
				param = 11,
				maxCount = -1,
				awards = 
				{
					{ type = 0, id = 4085, count = 3, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},
			},
		},
	},
----#include "OpenServerTenDayConfig.lua"   ----十天比拼
--#include "OpenServerGiftBagConfig.lua"  ----特惠礼包
--#include "OpenServerSuperPurchaseConfig.lua"  ----超级团购
--#include "OpenServerDailyTitleRechargeConfig.lua"  ----每日主题充值
--#include "OpenServerGuildConfig.lua"  ----开服行会
--#include "OpenServerContinuousRechargeConfig.lua"  ----连续充值
--#include "OpenServerHeroSwingConfig.lua"  ----开服英雄光翼
--#include "OpenServerEquipGoldRecoverConfig.lua"  ----开服装备元宝回收
--#include "OpenServerFashionDisConfig.lua"  ----时装打折
}