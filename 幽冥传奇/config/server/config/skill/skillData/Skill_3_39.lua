return {
{
	actions=
	{
		{act=0,effect=10010,sound=30,delay=200,},
	},
	desc=Lang.Skill.s3L39Desc,
	iconID=3,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=19400,value=0},
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
						{cond = 13,value =1},
					},
					results=
					{
						{type=34,value=1},
						{mj=0,timeParam=1,type=3,delay=300, rate=28000,value=0},
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
			{cond=1,value=150,consume=true},
		{cond=21,value=48000,consume=true},
		{cond=3,value= 445, count = 4,consume=true},
	},
	spellConds=
	{
		{cond=35,value=1,consume=false},
	},
	singTime=0,
	cooldownTime=0,
},
}