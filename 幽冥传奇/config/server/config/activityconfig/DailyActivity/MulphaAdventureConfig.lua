
--#include "..\..\..\language\LangCode.txt"
MulphaAdventureEvent =
{
	startPoint	  = 1,
	awards		  = 2,
	rest			= 3,
	randomEvent	 = 4,
	fight			= 5,
	canNotPassFight = 6,
}
MulphaAdventureRandomEvent =
{
	goAhead = 1,
	fallBack = 2,
	diceCount = 3,
}
MulphaAdventureConfig =
{
	rankCount = 3,
	minRankStep = 50,
	buttonRankCount = 50,
	dailyGetDiceCount = 10,
	SpecialRoundAppearNeedCount = 10,
	buyDicePointNeed = 10,
	buyDicePointNeedAdd = 2,
	diceMaxNum = 6,
	diceMinNum = 1,
	randomDiceNum =
	{
		{ weight = 2, diceNum = 1, },
		{ weight = 3, diceNum = 2, },
		{ weight = 3, diceNum = 3, },
		{ weight = 2, diceNum = 4, },
		{ weight = 1, diceNum = 5, },
		{ weight = 1, diceNum = 6, },
	},
	dailyOnlineDiceNumAdd =
	{
		{ second = 3600,   addCount = 1,  },
		{ second = 7200,   addCount = 1,  },
		{ second = 10800,  addCount = 1,  },
		{ second = 14400,  addCount = 1,  },
		{ second = 18000,  addCount = 1,  },
		{ second = 21600,  addCount = 1,  },
		{ second = 25200,  addCount = 1,  },
		{ second = 28800,  addCount = 1,  },
		{ second = 32400,  addCount = 1,  },
		{ second = 36000,  addCount = 1,  },
	},
	RoundAwards =
	{
		{
			RoundCount = 2,
			awards =
			{
				{ type = 0, id = 4448, count = 2, bind = 1, },
				{ type = 0, id = 4058, count = 5, bind = 1, },
			},
		},
		{
			RoundCount = 4,
			awards =
			{
				{ type = 0, id = 4448, count = 3, bind = 1, },
				{ type = 0, id = 4058, count = 10, bind = 1, },
			},
		},
		{
			RoundCount = 6,
			awards =
			{
				{ type = 0, id = 4448, count = 4, bind = 1, },
				{ type = 0, id = 4058, count = 15, bind = 1, },
			},
		},
		{
			RoundCount = 8,
			awards =
			{
				{ type = 0, id = 4448, count = 5, bind = 1, },
				{ type = 0, id = 4058, count = 20, bind = 1, },
			},
		},
		{
			RoundCount = 10,
			awards =
			{
				{ type = 0, id = 4448, count = 6, bind = 1, },
				{ type = 0, id = 4058, count = 30, bind = 1, },
			},
		},
	},
	normalRound =
	{
		{
			desc = Lang.ScriptTips.MulphaAdventure001,
			icon = 1,
			eventType = MulphaAdventureEvent.startPoint,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4023, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4028, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4033, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure003,
			icon = 5,
			eventType = MulphaAdventureEvent.rest,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure004,
			icon = 3,
			eventType = MulphaAdventureEvent.randomEvent,
			randomEvent =
			{
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.goAhead,
					awardNum = 1,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.fallBack,
					awardNum = 1,
				},
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure005,
			awardDesc = Lang.ScriptTips.MulphaAdventure007,
			eventType = MulphaAdventureEvent.fight,
			icon = 6,
			boss =
			{
				{ monsterId = 1145, sceneId = 121, num = 1,  pos = {22,31}, livetime = 600,},
			},
			monsters =
			{
			},
			passConsumes = { { type = 3, id = 0, count = 1000000, bind = 1, },},
			randomReward =
			{
				{
					weight = 14,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 1,
				},
			},
			fubenId		 = 30,
			sceneId		 = 121,
			enterPos		= {22,21},
			fubenTime		= 600,
			reloginType	 = 1,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure004,
			icon = 3,
			eventType = MulphaAdventureEvent.randomEvent,
			randomEvent =
			{
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.goAhead,
					awardNum = 1,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.fallBack,
					awardNum = 3,
				},
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4448, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure005,
			awardDesc = Lang.ScriptTips.MulphaAdventure007,
			eventType = MulphaAdventureEvent.fight,
			icon = 6,
			boss =
			{
				{ monsterId = 1145, sceneId = 121, num = 1,  pos = {22,31}, livetime = 600,},
			},
			monsters =
			{
			},
			passConsumes = { { type = 3, id = 0, count = 2000000, bind = 1, },},
			randomReward =
			{
				{
					weight = 14,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 1,
				},
			},
			fubenId		 = 30,
			sceneId		 = 121,
			enterPos		= {22,21},
			fubenTime		= 600,
			reloginType	 = 1,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4038, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure004,
			icon = 3,
			eventType = MulphaAdventureEvent.randomEvent,
			randomEvent =
			{
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.goAhead,
					awardNum = 1,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.fallBack,
					awardNum = 1,
				},
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure003,
			icon = 5,
			eventType = MulphaAdventureEvent.rest,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure004,
			icon = 3,
			eventType = MulphaAdventureEvent.randomEvent,
			randomEvent =
			{
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.goAhead,
					awardNum = 1,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.fallBack,
					awardNum = 2,
				},
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4033, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure003,
			icon = 5,
			eventType = MulphaAdventureEvent.rest,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4038, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure005,
			awardDesc = Lang.ScriptTips.MulphaAdventure007,
			eventType = MulphaAdventureEvent.fight,
			icon = 6,
			boss =
			{
				{ monsterId = 1145, sceneId = 121, num = 1,  pos = {22,31}, livetime = 600,},
			},
			monsters =
			{
			},
			passConsumes = { { type = 3, id = 0, count = 3000000, bind = 1, },},
			randomReward =
			{
				{
					weight = 14,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 1,
				},
			},
			fubenId		 = 30,
			sceneId		 = 121,
			enterPos		= {22,21},
			fubenTime		= 600,
			reloginType	 = 1,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4028, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure003,
			icon = 5,
			eventType = MulphaAdventureEvent.rest,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure005,
			awardDesc = Lang.ScriptTips.MulphaAdventure007,
			eventType = MulphaAdventureEvent.fight,
			icon = 6,
			boss =
			{
				{ monsterId = 1145, sceneId = 121, num = 1,  pos = {22,31}, livetime = 600,},
			},
			monsters =
			{
			},
			passConsumes = { { type = 3, id = 0, count = 4000000, bind = 1, },},
			randomReward =
			{
				{
					weight = 14,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 1,
				},
			},
			fubenId		 = 30,
			sceneId		 = 121,
			enterPos		= {22,21},
			fubenTime		= 600,
			reloginType	 = 1,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure004,
			icon = 3,
			eventType = MulphaAdventureEvent.randomEvent,
			randomEvent =
			{
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.goAhead,
					awardNum = 1,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.fallBack,
					awardNum = 3,
				},
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4023, count = 1, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure006,
			awardDesc = Lang.ScriptTips.MulphaAdventure007,
			eventType = MulphaAdventureEvent.canNotPassFight,
			icon = 4,
			boss =
			{
				{ monsterId = 1146, sceneId = 121, num = 1,  pos = {22,31}, livetime = 600,},
			},
			monsters =
			{
			},
			passConsumes = { { type = 3, id = 0, count = 10000000, bind = 1, },},
			randomReward =
			{
				{
					weight = 6,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 1,
				},
				{
					weight = 3,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 2,
				},
				{
					weight = 1,
					subType = MulphaAdventureRandomEvent.diceCount,
					awardNum = 3,
				},
			},
			fubenId		 = 30,
			sceneId		 = 121,
			enterPos		= {22,21},
			fubenTime		= 600,
			reloginType	 = 1,
		},
	},
	specialRound =
	{
		{
			desc = Lang.ScriptTips.MulphaAdventure001,
			icon = 1,
			eventType = MulphaAdventureEvent.startPoint,
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4091, count = 30, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4024, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4029, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4034, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4039, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4091, count = 30, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4048, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4052, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4448, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4043, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4064, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4069, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4091, count = 30, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4024, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4029, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4034, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4039, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4048, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4052, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4448, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4043, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4069, count = 3, bind = 1, },
			},
		},
		{
			desc = Lang.ScriptTips.MulphaAdventure002,
			icon = 2,
			eventType = MulphaAdventureEvent.awards,
			awards =
			{
				{ type = 0, id = 4093, count = 3, bind = 1, },
			},
		},
	},
}
