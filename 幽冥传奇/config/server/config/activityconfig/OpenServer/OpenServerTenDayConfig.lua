return {					
{					
	{	--等级达标比拼			
		wndId = 1, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_1,			
		activityName = Lang.ScriptTips.OpenServerPKRankName001,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName002,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank001,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc001,			
		openDay = 1, --第几日开放			
		endDay = 1,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad001,			
		big_show =	{20,20},		
		icon = 1,			
		param =  1,	--等级		
		exparam = 3,	--转数		
		tip = Lang.Activity.opentips01,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id = 324, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id = 334, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id = 344, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc001,	
				icon = 1,	
				param =  1,	--等级
				exparam = 3, 	--转数
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4478, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc002,	
				icon = 1,	
				param =  1,	--等级
				exparam = 2, 	--转数
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4478, count = 6, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc003,	
				icon = 1,	
				param =  1,	--等级
				exparam = 1, 	--转数
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4478, count = 3, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc004,	
				icon = 1,	
				param =  80,	--等级
				exparam = 0, 	--转数
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4478, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc005,	
				icon = 1,	
				param =  75,	--等级
				exparam = 0, 	--转数
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4215, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--翅膀达标比拼			
		wndId = 40, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_2,			
		activityName = Lang.ScriptTips.OpenServerPKRankName003,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName004,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank002,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc002,			
		openDay = 2, --第几日开放			
		endDay = 2,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad002,			
		big_show =	{20,20},		
		icon = 25,			
		param =  6,	--翅膀等级		
		--exparam = 3, --翅膀不需要该字段，所以注释掉			
		tip = Lang.Activity.opentips02,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =326, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =336, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =346, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc011,	
				icon = 26,	
				param =  6,	--翅膀等级
				--exparam = 3, --翅膀不需要该字段，所以注释掉	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4091, count = 150, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc012,	
				icon = 27,	
				param =  5,	--翅膀等级
				--exparam = 3, --翅膀不需要该字段，所以注释掉	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4091, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc013,	
				icon = 28,	
				param =  4,	--翅膀等级
				--exparam = 3, --翅膀不需要该字段，所以注释掉	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4091, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc014,	
				icon = 28,	
				param =  3,	--翅膀等级
				--exparam = 3, --翅膀不需要该字段，所以注释掉	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4091, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc015,	
				icon = 29,	
				param =  2,	--翅膀等级
				--exparam = 3, --翅膀不需要该字段，所以注释掉	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4091, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--符文达标比拼			
		wndId = 372, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_3,			
		activityName = Lang.ScriptTips.OpenServerPKRankName005,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName006,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank003,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc003,			
		openDay = 3, --第几日开放			
		endDay = 3,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad003,			
		big_show =	{20,20},		
		icon = 30,			
		param =  41,	--符文值		
		--exparam = 3,			
		tip = Lang.Activity.opentips03,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =322, count = 1, quality = 0, job = 1, sex = 0, strong = 0, bind = 0, },		
			{ type = 0, id =332, count = 1, quality = 0 ,job = 2, sex = 0, strong = 0, bind = 0, },		
			{ type = 0, id =342, count = 1, quality = 0 ,job = 3, sex = 0, strong = 0, bind = 0, },		
			{ type = 0, id =323, count = 1, quality = 0 ,job = 1, sex = 1, strong = 0, bind = 0, },		
			{ type = 0, id =333, count = 1, quality = 0 ,job = 2, sex = 1, strong = 0, bind = 0, },		
			{ type = 0, id =343, count = 1, quality = 0 ,job = 3, sex = 1, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc021,	
				icon = 30,	
				param =  41,	--符文阶数
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4448, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc022,	
				icon = 30,	
				param =  35,	--符文阶数
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4448, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc023,	
				icon = 30,	
				param =  28,	--符文阶数
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4448, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc024,	
				icon = 30,	
				param =  20,	--符文阶数
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4448, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc025,	
				icon = 30,	
				param =  11,	--符文阶数
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4448, count = 5, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{ 	--灵珠达标比拼			
		wndId = 367, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_4,			
		activityName = Lang.ScriptTips.OpenServerPKRankName007,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName008,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank004,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc004,			
		openDay = 4, --第几日开放			
		endDay = 4,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad004,			
		big_show =	{20,20},		
		icon = 37,			
		param =  41,	--灵珠等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips04,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =329, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =339, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =349, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc031,	
				icon = 38,	
				param =  41,	--灵珠等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4085, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc032,	
				icon = 39,	
				param =  35,	--灵珠等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4085, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc033,	
				icon = 40,	
				param =  28,	--灵珠等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4085, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc034,	
				icon = 40,	
				param =  20,	--灵珠等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4085, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc035,	
				icon = 41,	
				param =  11,	--灵珠等级
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4085, count = 5, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{ 	--特戒达标比拼			
		wndId = 347, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_5,			
		activityName = Lang.ScriptTips.OpenServerPKRankName009,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName010,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank005,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc005,			
		openDay = 5, --第几日开放			
		endDay = 5,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad005,			
		big_show =	{20,20},		
		icon = 43,			
		param =  40,	--任意特戒等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips05,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =327, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =337, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =347, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc041,	
				icon = 43,	
				param =  40,	--任意特戒等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4052, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc042,	
				icon = 43,	
				param =  30,	--任意特戒等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4052, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc043,	
				icon = 43,	
				param =  20,	--任意特戒等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4052, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc044,	
				icon = 43,	
				param =  10,	--任意特戒等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4052, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc045,	
				icon = 43,	
				param =  1,	--任意特戒等级
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4052, count = 5, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--武魂达标比拼			
		wndId = 366, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_6,			
		activityName = Lang.ScriptTips.OpenServerPKRankName011,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName012,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank006,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc006,			
		openDay = 6, --第几日开放			
		endDay = 6,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad006,			
		big_show =	{20,20},		
		icon = 49,			
		param =  41,	--武魂等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips06,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =328, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =338, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =348, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc051,	
				icon = 50,	
				param =  41,	--武魂等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4084, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc052,	
				icon = 51,	
				param =  35,	--武魂等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4084, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc053,	
				icon = 52,	
				param =  28,	--武魂等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4084, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc054,	
				icon = 52,	
				param =  20,	--武魂等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4084, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc055,	
				icon = 53,	
				param =  11,	--武魂等级
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4084, count = 5, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--经脉达标比拼			
		wndId = 370, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_7,			
		activityName = Lang.ScriptTips.OpenServerPKRankName013,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName014,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank007,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc007,			
		openDay = 7, --第几日开放			
		endDay = 7,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad007,			
		big_show =	{20,20},		
		icon = 55,			
		param =  39,	--经脉等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips07,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =326, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =336, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =346, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc061,	
				icon = 55,	
				param =  39,	--经脉等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4008, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc062,	
				icon = 55,	
				param =  34,	--经脉等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4008, count = 25, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc063,	
				icon = 55,	
				param =  27,	--经脉等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4008, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc064,	
				icon = 55,	
				param =  19,	--经脉等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4008, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc065,	
				icon = 55,	
				param =  10,	--经脉等级
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4008, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{ 	--注灵值达标比拼			
		wndId = 21, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_8,			
		activityName = Lang.ScriptTips.OpenServerPKRankName015,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName016,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank008,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc008,			
		openDay = 8, --第几日开放			
		endDay = 8,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad008,			
		big_show =	{20,20},		
		icon = 61,			
		param =  20000,	--注灵值		
		--exparam = 3,			
		tip = Lang.Activity.opentips08,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =325, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =335, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =345, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc071,	
				icon = 61,	
				param =  20000,	--注灵值
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4047, count = 150, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc072,	
				icon = 61,	
				param =  10000,	--注灵值
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4047, count = 125, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc073,	
				icon = 61,	
				param =  5000,	--注灵值
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4047, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc074,	
				icon = 61,	
				param =  1500,	--注灵值
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4047, count = 75, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc075,	
				icon = 61,	
				param =  500,	--注灵值
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4047, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--宝石达标比拼			
		wndId = 364, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_9,			
		activityName = Lang.ScriptTips.OpenServerPKRankName017,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName018,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank009,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc009,			
		openDay = 9, --第几日开放			
		endDay = 9,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad009,			
		big_show =	{20,20},		
		icon = 67,			
		param =  120,	--宝石总等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips09,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =327, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =337, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =347, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc081,	
				icon = 68,	
				param =  150,	--宝石总等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4087, count = 50, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc082,	
				icon = 69,	
				param =  120,	--宝石总等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4087, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc083,	
				icon = 70,	
				param =  90,	--宝石总等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4087, count = 20, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc084,	
				icon = 70,	
				param =  50,	--宝石总等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4087, count = 15, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 10, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc085,	
				icon = 71,	
				param =  10,	--宝石总等级
				--exparam = 3,	
				limitNum = -1,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4087, count = 10, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4014, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},				
	{	--会员达标比拼			
		wndId = 255, --界面id			
		RankId = RANK_OPENSEVER_ACTIVITY_10,			
		activityName = Lang.ScriptTips.OpenServerPKRankName019,			
		activityRankName = Lang.ScriptTips.OpenServerPKRankName020,			
		activityDesc = Lang.ScriptTips.OpenServerPKRank010,			
		activityRank = Lang.ScriptTips.OpenServerPKRankDesc010,			
		openDay = 10, --第几日开放			
		endDay = 10,	--第几日结束		
		BroadInfo = Lang.ScriptTips.OpenServerPKRankBroad010,			
		big_show =	{20,20},		
		icon = 73,			
		param =  6,	--vip等级		
		--exparam = 3,			
		tip = Lang.Activity.opentips10,			
		maxRankNum = 10, 	--最高排名		
		exAwards = 			
		{			
			{ type = 0, id =321, count = 1, quality = 0, job = 1, strong = 0, bind = 0, },		
			{ type = 0, id =331, count = 1, quality = 0 ,job = 2, strong = 0, bind = 0, },		
			{ type = 0, id =341, count = 1, quality = 0 ,job = 3, strong = 0, bind = 0, },		
		},			
		Rewards = 			
		{			
			{		
				desc = Lang.ScriptTips.OpenServerDesc091,	
				icon = 73,	
				param =  6,	--vip等级
				--exparam = 3,	
				limitNum = 3,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4081, count = 5, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 200, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 3, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc092,	
				icon = 73,	
				param =  5,	--vip等级
				--exparam = 3,	
				limitNum = 50,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4081, count = 4, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 150, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc093,	
				icon = 73,	
				param =  4,	--vip等级
				--exparam = 3,	
				limitNum = 100,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4081, count = 3, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 100, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc094,	
				icon = 73,	
				param =  3,	--vip等级
				--exparam = 3,	
				limitNum = 200,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4081, count = 2, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 60, quality = 0, strong = 0, bind = 1, },
				},	
			},		
			{		
				desc = Lang.ScriptTips.OpenServerDesc095,	
				icon = 73,	
				param =  2,	--vip等级
				--exparam = 3,	
				limitNum = 300,	-- -1表示不限制
				awards = 	
				{	
					{ type = 0, id = 4081, count = 1, quality = 0, strong = 0, bind = 1, },
					{ type = 0, id = 4092, count = 30, quality = 0, strong = 0, bind = 1, },
				},	
			},		
		},			
	},																							
},
}