return {
{
	actions=
	{
		{act=0,effect=10000,sound=1,delay=0},
	},
	desc=Lang.Skill.s1L1Desc,
	iconID=1,
	actRange=
	{
		{
			xStart=0,
			xEnd=0,
			yStart=0,
			yEnd=1,
			rangeType=2,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=10000,value=0},
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
		{cond=13,value=1,consume=true},
		{cond=35,value=1,consume=false},
	},
	singTime=0,
	cooldownTime=1000,
},
}