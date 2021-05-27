return {				
{					
	--wndId = 371, --界面id				
	activityName = Lang.ScriptTips.OpenServerGuild001,				
	activityDesc = Lang.ScriptTips.OpenServerGuild002,				
	openDay = 1,				
	endDay = 7,	--第几日结束			
	--BroadInfo = Lang.ScriptTips.OpenServerGuild003,				
	big_show =	{6,14},			
	Awards =				
	{				
		{			
			desc = Lang.ScriptTips.OpenServerGuild004,		
			icon = 75,		
			nGuild = 1,		--创建行会 	enScriptGuildType_Create
			nNeedCount = 1,  --一次
			maxCount = 3,	--奖励个数  -1表示无穷
			awards = 		
			{		
				{ type = 0, id = 4058, count = 1, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4277, count = 1, quality = 0, strong = 0, bind = 1, },		
			},		
		},			
		{			
			desc = Lang.ScriptTips.OpenServerGuild005,		
			icon = 76,		
			nGuild = 2,			--设置副会长或者长老 enScriptGuildType_Settle
			nNeedCount = 3,		--3次
			maxCount = 3,		
			awards = 		
			{		
				{ type = 0, id = 4058, count = 3, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4064, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4277, count = 2, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4014, count = 2, quality = 0, strong = 0, bind = 1, },			
			},		
		},			
		{			
					
			desc = Lang.ScriptTips.OpenServerGuild006,		
			icon = 77,		
			nGuild = 4,			--行会成员 	enScriptGuildType_MemberNum
			nNeedCount = 50,		--50
			maxCount = 3,		
			awards = 		
			{		
				{ type = 0, id = 4058, count = 6, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4277, count = 3, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4019, count = 1, quality = 0, strong = 0, bind = 1, },		
			},		
		},			
		{			
			desc = Lang.ScriptTips.OpenServerGuild007,		
			icon = 78,		
			nGuild = 3,			--行会等级 enScriptGuildType_Level
			nNeedCount = 4,		--4级
			maxCount = 3,		
			awards = 		
			{		
				{ type = 0, id = 4059, count = 1, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4278, count = 2, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4483, count = 5, quality = 0, strong = 0, bind = 1, },		
			},		
		},			
		{			
			desc = Lang.ScriptTips.OpenServerGuild008,		
			icon = 79,		
			nGuild = 3,			--行会等级 enScriptGuildType_Level
			nNeedCount = 5,		--5级
			maxCount = 3,		
			awards = 		
			{		
				{ type = 0, id = 4059, count = 2, quality = 0, strong = 0, bind = 1, },		
				{ type = 0, id = 4271, count = 1, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4279, count = 2, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4064, count = 2, quality = 0, strong = 0, bind = 1, },
				{ type = 0, id = 4484, count = 1, quality = 0, strong = 0, bind = 1, },			
			},		
		},					
	},				
},		
}