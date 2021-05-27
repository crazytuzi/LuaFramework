return {
{
	actions=
	{
		{ act = 0, effect = 0, sound = 0, delay = 0},
		{ act = 0, effect = 0, },
        { act = 0, effect = 0, },
	},
	desc=Lang.Skill.s1L1Desc,
	iconID=1,
	actRange=
	{
		{
			xStart=0,
			xEnd=0,
			yStart=0,
			yEnd=0,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					targetType = 1,
					conds=
					{
						{ cond = 3, value = 1, },
					},
					results=
					{
					},
					specialEffects=
					{
						{ type = 7, mj = 0, id = 83, keepTime = 800, delay = 0, always = true },
						{ type = 7, mj = 0, id = 83, keepTime = 800, delay = 400, always = true },
						{ type = 7, mj = 0, id = 83, keepTime = 800, delay = 800, always = true },
					},
				},
			},
		},
		{
			xStart=-2,
			xEnd=2,
			yStart=-2,
			yEnd=2,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{ cond = 13, value = 1, },
						{ cond = 33, value = 3000, },
					},
					results=
					{
						{ mj = 0, timeParam = 1, type = 4, delay = 100, rate = 10000, value = 0},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{ cond = 13, value = 1, },
						{ cond = 33, value = 3000, },
					},
					results=
					{
						{ mj = 0, timeParam = 1, type = 4, delay = 600, rate = 15000, value = 0},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{ cond = 13, value = 1, },
						{ cond = 33, value = 3000, },
					},
					results=
					{
						{ mj = 0, timeParam = 1, type = 4, delay = 1100, rate = 20000, value = 0},
					},
					specialEffects=
					{
					},
				},
			},
		},
	},
	trainConds=
	{
	},
	spellConds=
	{
		{cond=18,value=30,consume=false},
		{cond=13,value=4,consume=false},
	},
	singTime=0,
	cooldownTime= 10000,
},
}