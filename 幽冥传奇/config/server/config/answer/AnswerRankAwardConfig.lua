
--#include "..\..\language\LangCode.txt"
AnswerRankAwardConfig =
{
	dailyRank =
	{
		rankName  	= Lang.Rank.TodayAnswerRank,
		rankNameHis = Lang.Rank.YesterdayAnswerRank,
		rankLimit 	= 10,
		displayCount = 50,
		mailTitle  	= Lang.ScriptTips.AnswerMailTitle01,
		mailContent	= Lang.ScriptTips.AnswerMailContent01,
		mailLogId 	= 157,
		mailLogStr 	= Lang.ScriptTips.AnswerLog01,
		notClearRank= false,
		rankAwards =
		{
			{
				cond={1, 1},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
						   { type = 0, id = 4048, count = 12, bind = 1, },
					    },
					},
					{
						openServerDay = {15, 60},
						award =
						{
						   { type = 0, id = 4048, count = 13, bind = 1, },
					    },
					},
					{
						openServerDay = {61, 120},
						award =
						{
						   { type = 0, id = 4048, count = 20, bind = 1, },
					    },
					},
					{
						openServerDay = {120, 99999},
						award =
						{
						   { type = 0, id = 4048, count = 24, bind = 1, },
					    },
					},
				},
			},
			{
				cond={2, 3},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
						{ type = 0, id = 4048, count = 10, bind = 1, },
					    },
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4048, count = 12, bind = 1, },
					    },
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4048, count = 16, bind = 1, },
					},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
						{ type = 0, id = 4048, count = 20, bind = 1, },
					},
					},
				},
			},
			{
				cond={4, 10},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
						{ type = 0, id = 4048, count = 8, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4048, count = 10, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4048, count = 12, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4048, count = 16, bind = 1, },
					},
					},
				},
			},
			{
				cond={11, 20},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
						{ type = 0, id = 4048, count = 6, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4048, count = 8, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4048, count = 10, bind = 1, },
					},
					},
					{
						openServerDay = {121, 9999},
						award =
						{
						{ type = 0, id = 4048, count = 12, bind = 1, },
					},
					},
				},
			},
			{
				cond={21, 50},
				awards =
				{
					{
						openServerDay = {1, 14},
						award =
						{
						{ type = 0, id = 4048, count = 4, bind = 1, },
					},
					},
					{
						openServerDay = {15, 60},
						award =
						{
						{ type = 0, id = 4048, count = 6, bind = 1, },
					},
					},
					{
						openServerDay = {61, 120},
						award =
						{
						{ type = 0, id = 4048, count = 8, bind = 1, },
					},
					},
					{
						openServerDay = {121, 99999},
						award =
						{
						{ type = 0, id = 4048, count = 10, bind = 1, },
					},
					},
				},
			},
		},
	},
}
