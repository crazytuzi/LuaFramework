return {
{
	actions=
	{
		{act=0,effect=11010,sound=33,delay=200,},
	},
	desc=Lang.Skill.s8L1Desc,
	iconID=8,
	actRange=
	{
		{
			xStart=0,
			xEnd=0,
			yStart=-0,
			yEnd=0,
			rangeType=0,
			rangeCenter=0,
			acts=
			{
				{
					conds=
					{
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=18000,value=0},
					},
					specialEffects=
					{
					},
				},
			},
		},
		{
			xStart=1,
			xEnd=1,
			yStart=1,
			yEnd=-1,
			rangeType=2,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{cond = 1,value =1},
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=7000,value=0},
					},
					specialEffects=
					{
					},
				},
			},
		},
		{
			xStart=-1,
			xEnd=-1,
			yStart=1,
			yEnd=1,
			rangeType=2,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{cond = 1,value =1},
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=7000,value=0},
					},
					specialEffects=
					{
					},
				},
			},
		},
		{
			xStart=0,
			xEnd=0,
			yStart=2,
			yEnd=2,
			rangeType=2,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{cond = 1,value =1},
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=7000,value=0},
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
		{cond=13,value=2,consume=false},
	},
	singTime=0,
	cooldownTime=1000,
},
}