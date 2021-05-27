
--#include "..\..\language\LangCode.txt" once
MagicCityCfg =
{
	weekRank =
	{
		rankName  	= Lang.Rank.MagicCityWeekRank,
		rankNameHis = Lang.Rank.MagicCityWeekLastRank,
		rankLimit 	= 50,
		displayCount = 50,
		mailTitle  	= Lang.ScriptTips.MagicCityMailTitle01,
		mailContent	= Lang.ScriptTips.MagicCityMailContent01,
		mailLogId 	= 1282,
		mailLogStr 	= Lang.ScriptTips.MagicCityLog03,
		rankAwards =
		{
			{
				cond={1, 1},
				awards =
				{
					{
						openServerDay = {3, 14},
						award =
						{
						   { type = 0, id = 4044, count = 3, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						   { type = 0, id = 4044, count = 4, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						   { type = 0, id = 4044, count = 5, bind = 1, },
						},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						   { type = 0, id = 4044, count = 6, bind = 1, },
						},
					},
				},
			},
			{
				cond={2, 3},
				awards =
				{
					{
						openServerDay = {3, 14},
						award =
						{
						{ type = 0, id = 4043, count = 25, bind = 1, },
						},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4043, count = 30, bind = 1, },
						},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4043, count = 40, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4043, count = 50, bind = 1, },
					},
					},
				},
			},
			{
				cond={4, 10},
				awards =
				{
					{
						openServerDay = {3, 14},
						award =
						{
						{ type = 0, id = 4043, count = 20, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4043, count = 25, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4043, count = 30, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4043, count = 40, bind = 1, },
					},
					},
				},
			},
			{
				cond={11, 20},
				awards =
				{
					{
						openServerDay = {3, 14},
						award =
						{
						{ type = 0, id = 4043, count = 15, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4043, count = 20, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4043, count = 25, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4043, count = 30, bind = 1, },
					},
					},
				},
			},
			{
				cond={21, 50},
				awards =
				{
					{
						openServerDay = {3, 14},
						award =
						{
						{ type = 0, id = 4043, count = 10, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4043, count = 15, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4043, count = 20, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4043, count = 25, bind = 1, },
					},
					},
				},
			},
		},
	},
	cities =
	{
		{
			cityIdx 		= 1,
			cityName		= Lang.ScriptTips.MagicCityName01,
			cityType		= 1,
			sceneId 		= 84,
			fubenId			= 8,
			fubenTime		= 600,
			enterLevelLimit = {1,0},
			enterPos 		= {12,66},
			dailyEnterTimes = 5,
			dailyBuyTimes 	= 20,
			openServerDay   = 3,
			monsters =
			{
				{ monsterId=762, sceneId=84, num=15,range={23,39,34,46}, livetime=600,},
				{ monsterId=763,sceneId=84, num=15,range={10,18,18,35}, livetime=600,},
				{ monsterId=764, sceneId=84, num=15,range={8,19,22,30}, livetime=600,},
				{ monsterId=765, sceneId=84, num=15,range={47,41,57,50}, livetime=600,},
				{ monsterId=774, sceneId=84, num=1,pos={52,46}, livetime=600,},
			},
			star  = {600, 240, 180,},
			score =
			{
				{ cond={0, 60}, score=6, },
				{ cond={61, 120}, score=5, },
				{ cond={121, 180}, score=4, },
				{ cond={181, 240}, score=3, },
				{ cond={241, 300}, score=2, },
				{ cond={301, 600}, score=1, },
			},
			showAwards =
			{
				{ type = 0, id = 4041, count = 0, bind = 1, },
				{ type = 0, id = 4001, count = 0, bind = 1, },
			},
			starAwards =
			{
				{
					{ type = 0, id = 4041, count = 15, bind = 1, },
					{ type = 0, id = 4001, count = 15, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 20, bind = 1, },
					{ type = 0, id = 4001, count = 20, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 25, bind = 1, },
					{ type = 0, id = 4001, count = 25, bind = 1, },
				},
			},
			firstFullStarAwards =
			{
				{ type = 0, id = 4018, count = 1, bind = 1, },
				{ type = 0, id = 4014, count = 1, bind = 1, },
				{ type = 0, id = 4043, count = 3, bind = 1, },
			},
			cityOwnerAwards =
			{
				{ type = 0, id = 4043, count = 1, bind = 1, },
				{ type = 0, id = 4092, count = 2, bind = 1, },
			},
			enterConsume =
			{
				{type = 0, id = 4261, count = 10, quality = 0, strong = 0, },
			},
			sweepConsumes =
			{
				{ type = 0, id = 4263, count = 1, },
				{ type = 0, id = 4261, count = 10, },
			},
			buyEnterTimesConsumes =
			{
				{type = 10, id = 0, count = 10, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 20, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 30, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 40, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 50, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 60, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 70, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 80, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 90, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 100, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 110, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 130, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 160, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 200, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 250, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 300, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 350, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 400, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 450, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 500, quality = 0, strong = 0, bind = 0},
			},
		},
		{
			cityIdx 		= 2,
			cityName		= Lang.ScriptTips.MagicCityName02,
			cityType		= 2,
			sceneId 		= 86,
			fubenId			= 9,
			fubenTime		= 600,
			enterLevelLimit = {2,0},
			enterPos 		= {22,34},
			dailyEnterTimes = 5,
			dailyBuyTimes 	= 20,
			openServerDay   = 3,
			freshTimeAfterEnter = 10,
			monsters =
			{
				{
					monsterId=751, sceneId=86, num=1,pos={14,22}, livetime=600,
					mobMonsWenDie =
					{
						{ monsterId=753, sceneId=86, num=15,range={9,16,18,26}, livetime=600,},
					},
				},
				{
					monsterId=758, sceneId=86, num=1,pos={53,22}, livetime=600,
					mobMonsWenDie =
					{
						{ monsterId=754, sceneId=86, num=15,range={49,16,55,27}, livetime=600,},
					},
				},
				{
					monsterId=759, sceneId=86, num=1,pos={52,67}, livetime=600,
					mobMonsWenDie =
					{
						{ monsterId=755, sceneId=86, num=15,range={46,61,55,72}, livetime=600,},
					},
				},
				{
					monsterId=760, sceneId=86, num=1,pos={13,69}, livetime=600,
					mobMonsWenDie =
					{
						{ monsterId=756, sceneId=86, num=15,range={11,62,16,73}, livetime=600,},
					},
				},
				{
					monsterId=752, sceneId=86, num=1,pos={33,46}, livetime=600,
					mobMonsWenDie =
					{
						{ monsterId=775, sceneId=86, num=1,pos={32,44}, livetime=600,},
					},
				},
			},
			monsterMaxNum = 61,
			star  = {600, 360, 300,},
			score =
			{
				{ cond={0, 180}, score=8, },
				{ cond={181, 240}, score=7, },
				{ cond={241, 300}, score=6, },
				{ cond={301, 360}, score=5, },
				{ cond={361, 420}, score=4, },
				{ cond={421, 600}, score=3, },
			},
			showAwards =
			{
				{ type = 0, id = 4041, count = 0, bind = 1, },
				{ type = 0, id = 4001, count = 0, bind = 1, },
			},
			starAwards =
			{
				{
					{ type = 0, id = 4041, count = 20, bind = 1, },
					{ type = 0, id = 4001, count = 20, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 25, bind = 1, },
					{ type = 0, id = 4001, count = 25, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 30, bind = 1, },
					{ type = 0, id = 4001, count = 30, bind = 1, },
				},
			},
			firstFullStarAwards =
			{
				{ type = 0, id = 4018, count = 2, bind = 1, },
				{ type = 0, id = 4014, count = 2, bind = 1, },
				{ type = 0, id = 4043, count = 5, bind = 1, },
			},
			cityOwnerAwards =
			{
				{ type = 0, id = 4043, count = 2, bind = 1, },
				{ type = 0, id = 4092, count = 4, bind = 1, },
			},
			enterConsume =
			{
				{type = 0, id = 4261, count = 12, quality = 0, strong = 0, },
			},
			sweepConsumes =
			{
				{ type = 0, id = 4263, count = 1, },
				{ type = 0, id = 4261, count = 12, },
			},
			buyEnterTimesConsumes =
			{
				{type = 10, id = 0, count = 10, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 20, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 30, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 40, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 50, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 60, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 70, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 80, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 90, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 100, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 110, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 130, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 160, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 200, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 250, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 300, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 350, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 400, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 450, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 500, quality = 0, strong = 0, bind = 0},
			},
		},
		{
			cityIdx 		= 3,
			cityName		= Lang.ScriptTips.MagicCityName03,
			cityType		= 3,
			sceneId 		= 85,
			fubenId			= 10,
			fubenTime		= 600,
			enterLevelLimit = {3,0},
			enterPos 		= {11,68},
			dailyEnterTimes = 5,
			dailyBuyTimes 	= 20,
			openServerDay   = 3,
			freshTimeAfterEnter = 10,
			monsters =
			{
				{ monsterId=767, sceneId=85, num=3,range={28,49,38,60}, livetime=600,},
				{ monsterId=767, sceneId=85, num=3,range={22,34,31,43}, livetime=600,},
				{ monsterId=768, sceneId=85, num=3,range={28,49,38,60}, livetime=600,},
				{ monsterId=768, sceneId=85, num=3,range={22,34,31,43}, livetime=600,},
				{ monsterId=767, sceneId=85, num=4,range={20,16,31,28}, livetime=600,},
				{ monsterId=768, sceneId=85, num=4,range={20,16,31,28}, livetime=600,},
				{ monsterId=767, sceneId=85, num=4,range={36,25,47,38}, livetime=600,},
				{ monsterId=767, sceneId=85, num=4,range={36,25,47,38}, livetime=600,},
				{ monsterId=768, sceneId=85, num=4,range={36,25,47,38}, livetime=600,},
				{ monsterId=768, sceneId=85, num=4,range={36,25,47,38}, livetime=600,},
				{ monsterId=767, sceneId=85, num=4,range={18,61,28,62}, livetime=600,},
				{ monsterId=768, sceneId=85, num=4,range={18,61,28,62}, livetime=600,},
				{ monsterId=769, sceneId=85, num=4,range={28,49,38,60}, livetime=600,},
				{ monsterId=769, sceneId=85, num=4,range={20,16,31,28}, livetime=600,},
				{ monsterId=769, sceneId=85, num=4,range={36,25,47,38}, livetime=600,},
				{ monsterId=769, sceneId=85, num=4,range={46,29,57,38}, livetime=600,},
				{ monsterId=776, sceneId=85, num=1,pos={53,35}, livetime=600,},
			},
			baby = { monsterId=761, sceneId=86, num=1,pos={10,67}, livetime=600,},
			star  = {600, 360, 300,},
			score =
			{
				{ cond={0, 240}, score=10, },
				{ cond={241, 300}, score=9, },
				{ cond={301, 360}, score=8, },
				{ cond={361, 420}, score=7, },
				{ cond={421, 480}, score=6, },
				{ cond={481, 600}, score=5, },
			},
			showAwards =
			{
				{ type = 0, id = 4041, count = 0, bind = 1, },
				{ type = 0, id = 4001, count = 0, bind = 1, },
			},
			starAwards =
			{
				{
					{ type = 0, id = 4041, count = 25, bind = 1, },
					{ type = 0, id = 4001, count = 25, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 30, bind = 1, },
					{ type = 0, id = 4001, count = 30, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 35, bind = 1, },
					{ type = 0, id = 4001, count = 35, bind = 1, },
				},
			},
			firstFullStarAwards =
			{
				{ type = 0, id = 4018, count = 3, bind = 1, },
				{ type = 0, id = 4014, count = 3, bind = 1, },
				{ type = 0, id = 4043, count = 7, bind = 1, },
			},
			cityOwnerAwards =
			{
				{ type = 0, id = 4043, count = 3, bind = 1, },
				{ type = 0, id = 4092, count = 7, bind = 1, },
			},
			enterConsume =
			{
				{type = 0, id = 4261, count = 14, quality = 0, strong = 0, },
			},
			sweepConsumes =
			{
				{ type = 0, id = 4263, count = 1, },
				{ type = 0, id = 4261, count = 14, },
			},
			buyEnterTimesConsumes =
			{
				{type = 10, id = 0, count = 10, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 20, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 30, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 40, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 50, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 60, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 70, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 80, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 90, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 100, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 110, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 130, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 160, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 200, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 250, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 300, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 350, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 400, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 450, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 500, quality = 0, strong = 0, bind = 0},
			},
		},
		{
			cityIdx 		= 4,
			cityName		= Lang.ScriptTips.MagicCityName04,
			cityType		= 4,
			sceneId 		= 87,
			fubenId			= 11,
			fubenTime		= 600,
			enterLevelLimit = {4,0},
			enterPosRand 	= { {16,79},{42,79},{66,79},{17,49},{41,49},{67,49},{17,16},{42,16},{67,16}, },
			dailyEnterTimes = 5,
			dailyBuyTimes 	= 20,
			openServerDay   = 3,
			freshTimeAfterEnter = 10,
			monsters =
			{
				{ monsterId=771, sceneId=87, num=15,range={10,103,19,113}, livetime=600, weight=1 },
				{ monsterId=771, sceneId=87, num=15,range={38,104,49,113}, livetime=600, weight=1 },
				{ monsterId=773, sceneId=87, num=15,range={70,104,80,114}, livetime=600, weight=1 },
				{ monsterId=771, sceneId=87, num=15,range={8,61,20,42}, livetime=600, weight=1 },
				{ monsterId=771, sceneId=87, num=15,range={38,64,49,73}, livetime=600, weight=1 },
				{ monsterId=773, sceneId=87, num=15,range={37,21,51,29}, livetime=600, weight=1 },
				{ monsterId=773, sceneId=87, num=15,range={68,20,80,30}, livetime=600, weight=1 },
			},
			boss =
			{
				{ monsterId=777, sceneId=87, num=1,range={38,104,49,113}, livetime=600, weight=1 },
				{ monsterId=770, sceneId=87, num=7,range={8,61,20,72}, livetime=600, weight=1 },
				{ monsterId=771, sceneId=87, num=8,range={38,64,49,73}, livetime=600, weight=1 },
				{ monsterId=772, sceneId=87, num=7,range={7,21,13,94}, livetime=600, weight=1 },
				{ monsterId=773, sceneId=87, num=8,range={68,20,80,30}, livetime=600, weight=1 },
			},
			monsterFresh = 2,
			monsterMaxNum = 61,
			star  = {600, 300, 240,},
			score =
			{
				{ cond={0, 120}, score=13, },
				{ cond={121, 180}, score=12, },
				{ cond={181, 240}, score=11, },
				{ cond={241, 300}, score=10, },
				{ cond={301, 360}, score=9, },
				{ cond={361, 600}, score=8, },
			},
			showAwards =
			{
				{ type = 0, id = 4041, count = 0, bind = 1, },
				{ type = 0, id = 4001, count = 0, bind = 1, },
			},
			starAwards =
			{
				{
					{ type = 0, id = 4041, count = 30, bind = 1, },
					{ type = 0, id = 4001, count = 30, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 35, bind = 1, },
					{ type = 0, id = 4001, count = 35, bind = 1, },
				},
				{
					{ type = 0, id = 4041, count = 40, bind = 1, },
					{ type = 0, id = 4001, count = 40, bind = 1, },
				},
			},
			firstFullStarAwards =
			{
				{ type = 0, id = 4018, count = 5, bind = 1, },
				{ type = 0, id = 4014, count = 5, bind = 1, },
				{ type = 0, id = 4043, count = 10, bind = 1, },
			},
			cityOwnerAwards =
			{
				{ type = 0, id = 4043, count = 4, bind = 1, },
				{ type = 0, id = 4092, count = 10, bind = 1, },
			},
			enterConsume =
			{
				{type = 0, id = 4261, count = 16, quality = 0, strong = 0, },
			},
			sweepConsumes =
			{
				{ type = 0, id = 4263, count = 1, },
				{ type = 0, id = 4261, count = 16, },
			},
			buyEnterTimesConsumes =
			{
				{type = 10, id = 0, count = 10, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 20, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 30, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 40, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 50, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 60, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 70, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 80, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 90, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 100, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 110, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 130, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 160, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 200, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 250, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 300, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 350, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 400, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 450, quality = 0, strong = 0, bind = 0},
				{type = 10, id = 0, count = 500, quality = 0, strong = 0, bind = 0},
			},
		},
	},
}
