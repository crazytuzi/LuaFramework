return {
{
	actions=
	{
		{act=0,effect=0,sound=0,delay=0},
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
			rangeCenter=0,
			acts=
			{
				{
				    targetType = 1,
					conds=
					{},
					results=
					{},
					specialEffects=
					{
					{ type = 0, mj = 0, id = 41, keepTime = 400, delay = 0, always = true },
					{ type = 0, mj = 0, id = 41, keepTime = 600, delay = 400, always = true },
					},
				},
			},
		},
		{
			xStart=-1,
			xEnd=1,
			yStart=-1,
			yEnd=1,
			rangeType=3,
			rangeCenter=0,
			acts=
			{
				{
					conds=
					{
					{ cond = 13, value = 1, },
					},
					results=
					{
					{ mj = 0, timeParam = 1, type = 4, delay = 0, rate = 3000, value = 0 },
					{ mj = 0, timeParam = 1, type = 4, delay = 400, rate = 7000, value = 0 },
					},
					specialEffects=
					{},
				},
			},
		},
	},
	trainConds=
	{
	},
	spellConds=
	{
		{cond=13,value=4,consume=false},
	},
	singTime=0,
	cooldownTime=500,
},
}