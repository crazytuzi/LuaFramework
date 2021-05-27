return {
{
	actions=
	{
		{act=0,effect=10030,sound=31,delay=200,},
	},
	desc=Lang.Skill.s53L1Desc,
	iconID=6,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=-0,
		yEnd=0,
		rangeType=0,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=13000,value=0},
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
		yStart=-1,
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
		xStart=1,
		xEnd=1,
		yStart=-1,
		yEnd=0,
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
		{cond=13,value=1,consume=true},
	},
	singTime=0,
	cooldownTime=10000,
},
}