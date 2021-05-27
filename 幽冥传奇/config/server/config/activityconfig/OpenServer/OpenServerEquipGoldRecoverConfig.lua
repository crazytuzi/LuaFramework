return {				
{							
	activityName = Lang.ScriptTips.OpenServerGoldRecoverName,		--名字			
	activityDesc = Lang.ScriptTips.OpenServerGoldRecoverDesc,		--描述
	logNormalCount = 10, --普通日志最多10条
	logHighCount = 3,	--高级日志最多3条
	openDay = 1,				
	endDay = 7,	--第几日结束
	levelLimit = {0, 80}, --提交限制
	OpenLevel = 60,				
	Awards =				
	{				
		{		
			openDay = 1,				
			endDay = 1,	--第几日结束	
			desc = Lang.ScriptTips.OpenServerGoldRecover001,			--显示信息
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,	 --广播
			logType = 2, 		--普通日志
			icon = 75,				
			nNeedCount = 1, 
			idList = {173,183,193,172,182,192,171,181,191},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 173, count = 1,},		--其他确定，id随意
			maxCount = 100,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 10000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4189, count = 2, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 1, },		
				{ type = 10, id = 0, count = 20,},
				--{ type = 0, id = 0, count = 1, },		
			},	
		},			
		{			
			openDay = 1,				
			endDay = 2,	--第几日结束
			desc = Lang.ScriptTips.OpenServerGoldRecover002,			--显示信息
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,	 --广播
			logType = 2,		--普通日志
			icon = 75,				
			nNeedCount = 1, 
			idList = {234,244,254,235,245,255,236,246,256,237,247,257,238,248,258,239,249,259},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 234, count = 1,},		--其他确定，id随意
			maxCount = 100,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 13500000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4189, count = 3, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 1.35, },		
				{ type = 10, id = 0, count = 30,},
				--{ type = 0, id = 0, count = 1, },		
			},	
		},			
		{	
		    openDay = 1,				
			endDay = 3,	--第几日结束		
			desc = Lang.ScriptTips.OpenServerGoldRecover003,	
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,	
			logType = 2, 		--普通日志
			icon = 76,	
			nNeedCount = 1,	
			idList = {233,243,253,232,242,252,231,241,251},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 233, count = 1,},		--其他确定，id随意
			maxCount = 50,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 67500000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 3, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 6.75, },		
				{ type = 10, id = 0, count = 150,},
				--{ type = 0, id = 0, count = 1, },		
			},			
		},			
		{	
		    openDay = 1,				
			endDay = 3,	--第几日结束		
			desc = Lang.ScriptTips.OpenServerGoldRecover004,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,
			logType = 2, 		--普通日志	
			icon = 77,		
			nNeedCount = 1,	
			idList = {294,304,314,295,305,315,296,306,316,297,307,317,298,308,318,299,309,319},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 294, count = 1,},		--其他确定，id随意
			maxCount = 80,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 20000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 1, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 2, },		
				{ type = 10, id = 0, count = 50,},
				--{ type = 0, id = 0, count = 1, },		
			},		
		},			
		{	
		    openDay = 1,				
			endDay = 4,	--第几日结束		
			desc = Lang.ScriptTips.OpenServerGoldRecover005,	
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,		
			logType = 2, 		--普通日志
			icon = 78,		
			nNeedCount = 1,	
			idList = {293,303,313,292,302,312,291,301,311},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 293, count = 1,},		--其他确定，id随意
			maxCount = 30,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 100000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 5, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 10, },		
				{ type = 10, id = 0, count = 250,},
				--{ type = 0, id = 0, count = 1, },		
			},	
		},			
		{	
		    openDay = 1,				
			endDay = 4,	--第几日结束		
			desc = Lang.ScriptTips.OpenServerGoldRecover006,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,	
			logType = 2, 		--普通日志
			icon = 79,		
			nNeedCount = 1,	
			idList = {354,364,374,355,365,375,356,366,376,357,367,377,358,368,378,359,369,379},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 354, count = 1,},		--其他确定，id随意
			maxCount = 60,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 35000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 2, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 3.5, },		
				{ type = 10, id = 0, count = 100,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{	
		    openDay = 1,				
			endDay = 5,	--第几日结束	
			desc = Lang.ScriptTips.OpenServerGoldRecover007,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,	
			logType = 3, 		--高级日志
			icon = 79,		
			nNeedCount = 1,	
			idList = {353,363,373,352,362,372,351,361,371},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 353, count = 1,},		--其他确定，id随意
			maxCount = 20,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 175000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 10, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 17.5, },		
				{ type = 10, id = 0, count = 500,},
				--{ type = 0, id = 0, count = 1, },		
			},			
		},	
		{	
		    openDay = 1,				
			endDay = 6,	--第几日结束		
			desc = Lang.ScriptTips.OpenServerGoldRecover008,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,
			logType = 2, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {414,424,434,415,425,435,416,426,436,417,427,437,418,428,438,419,429,439},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 414, count = 1,},		--其他确定，id随意
			maxCount = 40,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 60000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 4, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 6, },		
				{ type = 10, id = 0, count = 200,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},	
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover009,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {413,423,433,412,422,432,411,421,431},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 413, count = 1,},		--其他确定，id随意
			maxCount = 15,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 300000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 20, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 30, },		
				{ type = 10, id = 0, count = 1000,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},	
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover010,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast002,
			logType = 2, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {474,484,494,475,485,495,476,486,496,477,487,497,478,488,498,479,489,499},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 474, count = 1,},		--其他确定，id随意
			maxCount = 30,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 75000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 6, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 7.5, },		
				{ type = 10, id = 0, count = 300,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover011,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {473,483,493,472,482,492,471,481,491},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 473, count = 1,},		--其他确定，id随意
			maxCount = 10,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 375000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 30, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 37.5, },		
				{ type = 10, id = 0, count = 1500,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover012,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {534,544,554,535,545,555,536,546,556,537,547,557,538,548,558,539,549,559},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 534, count = 1,},		--其他确定，id随意
			maxCount = 20,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 100000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 10, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 10, },		
				{ type = 10, id = 0, count = 500,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover013,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {533,543,553,532,542,552,531,541,551},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 533, count = 1,},		--其他确定，id随意
			maxCount = 6,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 600000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4081, count = 3, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 60, },		
				{ type = 10, id = 0, count = 3000,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover014,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {594,604,614,595,605,615,596,606,616,597,607,617,598,608,618,599,609,619},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 594, count = 1,},		--其他确定，id随意
			maxCount = 10,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 120000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4275, count = 12, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 12, },		
				{ type = 10, id = 0, count = 600,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
		{		
			desc = Lang.ScriptTips.OpenServerGoldRecover015,		
			BroadInfo = Lang.ScriptTips.OpenServerGoldRecoverBroadCast001,
			logType = 3, 		--高级日志	
			icon = 79,		
			nNeedCount = 1,	
			idList = {593,603,613,592,602,612,591,601,611},  --该转装备列表，前面的先判断，如果有先扣除，所以把重要的放最后面
			consume = { type = 0, id = 593, count = 1,},		--其他确定，id随意
			maxCount = 3,	--全服最大兑换数
			awards = 		--奖励
			{		
				{ type = 1, id = 4058, count = 1000000000, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4081, count = 5, quality = 0, strong = 0, bind = 1, },
				--{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},	
			showAwards =   --前端展示
			{		
				{ type = 1, id = 0, count = 100, },		
				{ type = 10, id = 0, count = 5000,},
				--{ type = 0, id = 0, count = 1, },		
			},				
		},
	},				
},		
}