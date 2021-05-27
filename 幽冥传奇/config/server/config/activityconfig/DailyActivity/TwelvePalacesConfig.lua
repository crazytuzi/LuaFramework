
TwelvePalacesCfg =
{
	timer =
	{
		activityTime 	= 3600,
		monsterFreshCd	= 30,
		bossFreshCd		= 3600,
	},
	freshTimers =
	{
		{
		  	timerIdx = 1,
		   	freshCd = 150,
		   	relatedFloors = {1,2,3,},
		},
		{
		  	timerIdx = 2,
		   	freshCd = 150,
		   	relatedFloors = {4,5,6,},
		},
		{
		  	timerIdx = 3,
		   	freshCd = 150,
		   	relatedFloors = {7,8,9,},
		},
		{
		  	timerIdx = 4,
		   	freshCd = 150,
		   	relatedFloors = {10,11,12,},
		},
		{
		  	timerIdx = 5,
		   	freshCd = 150,
		   	relatedFloors = {13,},
		},
    },
	itemsNeedClear 		= {},
	MonstersCfg   =
	{
	    monsters =
	    {
	    },
	    boss =
	    {
	        1553,1554,
	    },
	},
	palaceAwards =
	{
		[3] =
		{
			floorsAwards =
			{
                 {type = 17, id = 0, count = 30000000, quality = 0, strong = 0, bind = 0},
		         {type = 1, id = 0, count = 10000000, quality = 0, strong = 0, bind = 0},
			},
		},
		[6] =
		{
			floorsAwards =
			{
                 {type = 17, id = 0, count = 30000000, quality = 0, strong = 0, bind = 0},
		         {type = 1, id = 0, count = 20000000, quality = 0, strong = 0, bind = 0},
			},
		},
		[9] =
		{
			floorsAwards =
			{
                 {type = 17, id = 0, count = 40000000, quality = 0, strong = 0, bind = 0},
		         {type = 1, id = 0, count = 30000000, quality = 0, strong = 0, bind = 0},
			},
		},
		[12] =
		{
			floorsAwards =
			{
                 {type = 17, id = 0, count = 50000000, quality = 0, strong = 0, bind = 0},
		         {type = 1, id = 0, count = 40000000, quality = 0, strong = 0, bind = 0},
			},
		},
	},
	floors =
	{
		{
			floorIdx 		= 1,
			sceneId 		= 61,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,2},
			freshIdx        = 1,
			monsters =
			{
				{ monsterId=236, sceneId=61, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=511, sceneId=61, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 2,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 5,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 2,
			sceneId 		= 62,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,3},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=237, sceneId=62, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=512, sceneId=62, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 3,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 10,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 3,
			sceneId 		= 63,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,3},
			noCheckFromScene	= true,
			monsters =
			{
				{ monsterId=238, sceneId=63, num=12,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 3,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 10,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 4,
			sceneId 		= 64,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,4},
			noCheckFromScene	= true,
			monsters =
			{
				{ monsterId=239, sceneId=64, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=514, sceneId=64, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 4,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 15,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 5,
			sceneId 		= 65,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,4},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=240, sceneId=65, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=515, sceneId=65, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 4,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 20,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 6,
			sceneId 		= 66,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,5},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=241, sceneId=66, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=516, sceneId=66, num=2,range={21,26,38,47}, livetime=3600,},
			},
			boss =
			{
				{ monsterId=248, sceneId=78, num=1,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 5,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 25,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 7,
			sceneId 		= 67,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,6},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=242, sceneId=67, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=517, sceneId=67, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 6,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 30,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 8,
			sceneId 		= 68,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,7},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=243, sceneId=68, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=518, sceneId=68, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 7,},
					},
				},
				{
					consume =
					{
						{ type = 5, id = 0, count = 35,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 9,
			sceneId 		= 69,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,8},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=244, sceneId=69, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=519, sceneId=69, num=2,range={21,26,38,47}, livetime=3600,},
			},
			boss =
			{
				{ monsterId=249, sceneId=69, num=1,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 8,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 10,
			sceneId 		= 70,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,9},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=245, sceneId=70, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=520, sceneId=70, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 9,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 11,
			sceneId 		= 71,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {4291,10},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=246, sceneId=71, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=521, sceneId=71, num=2,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
						{ type = 0, id = 4291, count = 10,},
					},
				},
			},
			sendTipmsg = true,
		},
		{
			floorIdx 		= 12,
			sceneId 		= 72,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=247, sceneId=72, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=522, sceneId=72, num=2,range={21,26,38,47}, livetime=3600,},
			},
			boss =
			{
				{ monsterId=250, sceneId=72, num=1,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
				{
					consume =
					{
					},
				},
			},
			sendTipmsg = true,
		},
	    {
			floorIdx 		= 13,
			sceneId 		= 204,
			enterLevelLimit = {0,70},
			enterPos 		= {23,18},
			checkItem 		= {},
			noCheckFromScene= true,
			monsters =
			{
				{ monsterId=247, sceneId=72, num=18,range={21,26,38,47}, livetime=3600,},
				{ monsterId=522, sceneId=72, num=2,range={21,26,38,47}, livetime=3600,},
			},
			boss =
			{
				{ monsterId=250, sceneId=72, num=1,range={21,26,38,47}, livetime=3600,},
			},
			nextFloor =
			{
			},
			sendTipmsg = true,
		},
	},
}
