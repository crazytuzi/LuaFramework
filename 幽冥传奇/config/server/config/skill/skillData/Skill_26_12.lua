return {
{
	actions=
	{
		{act=1,effect=0,sound=53,delay=0,},
	},
	desc=Lang.Skill.s26L12Desc,
	iconID=26,
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
					targetType=0,
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
			rangeCenter=1,
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
						{mj=0,timeParam=6,type=1,delay=500, rate=500, rateType=2, id=263,},
						{mj=0,timeParam=6,type=1,delay=500, rate=500, rateType=2, id=264,},
												{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=100},
					},
					specialEffects=
					{
					},
				},
			},
		},
	},
	trainConds=
	{{cond=43,value=1,consume=false},
	},
	spellConds=
	{
		{cond=8,value=1040,consume=true},
	},
	singTime=0,
	cooldownTime=1500,
},
}