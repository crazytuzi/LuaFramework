return {
{
	actions=
	{
		{act=0,effect=0,sound=0,delay=0,wait=0},
	},
	desc=Lang.Skill.s1L1Desc,
	iconID=1,
	actRange=
	{
		{
			xStart=-3,
			xEnd=3,
			yStart=0,
			yEnd=3,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
					{ cond = 13, value = 1, },
					},
					results=
					{
				    { mj = 0, delay = 100, timeParam = 1, type = 3, rate = 10000, value = 0 },
					},
					specialEffects=
					{
					{ type = 4,  mj = 0, id = 63, keepTime = 500, delay = 0, always = false },
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
		{cond=13,value=2,consume=false},
	},
	singTime=0,
	cooldownTime=1000,
},
}