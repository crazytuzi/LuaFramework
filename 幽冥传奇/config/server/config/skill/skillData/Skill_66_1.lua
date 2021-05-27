return {
{
	actions=
	{
		{act=1,effect=23,sound=53,delay=0,},
	},
	desc=Lang.Skill.s66L1Desc,
	iconID=24,
	actRange=
	{
		{
			xStart=0,
			xEnd=0,
			yStart=0,
			yEnd=0,
			rangeType=3,
			rangeCenter=2,
			acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond = 3,value =1},
					},
					results=
					{
					},
					specialEffects=
					{
						{type=4,mj=0,id=23,keepTime=380,delay=450,always=false},
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
			rangeCenter=2,
			acts=
			{
				{
					conds=
					{
						{cond = 3,value = 1 },
						{cond = 17,value = 23, param=116},
						{cond = 17,value = 27, param=116},
					},
					results=
					{
						{mj=0,timeParam=2,type=1,delay=500, rate=500, rateType=2, id=22,},
						{mj=0,timeParam=2,type=1,delay=500, rate=500, rateType=2, id=23,},
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
	},
	singTime=0,
	cooldownTime=100000,
},
}