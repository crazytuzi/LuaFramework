return {
{
	actions=
	{
		{act=1,effect=0,sound=0,delay=0},
	},
	desc=Lang.Skill.s1L1Desc,
	iconID=1,
	actRange=
	{
		{
			xStart=-8,
			xEnd=8,
			yStart=-8,
			yEnd=8,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{ cond = 13, value = 1, },
						{ cond = 11, value = 7500, },
					},
					results=
					{
						 { mj = 0, timeParam = 1, type = 1, id = 1307, rate = -0, rateType = 0, delay = 200 },
						 { mj = 0, timeParam = 5000, type = 20, delay = 0, id = 114, value = 1, vt = 0 },
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
		{cond=13,value=5,consume=false},
	},
	singTime=0,
	cooldownTime=15000,
},
}