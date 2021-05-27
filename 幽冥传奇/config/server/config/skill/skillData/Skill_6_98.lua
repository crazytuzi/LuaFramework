return {
{
	actions=
	{
		{act=0,effect=10030,sound=31,delay=200,},
	},
	desc=Lang.Skill.s6L98Desc,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=59500,value=0},
						{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=98},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=49700,value=0},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=49700,value=0},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=49700,value=0},
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
		{cond=1,value=1000,consume=false},
		{cond=21,value=2000000,consume=true},
		{cond=3,value= 447, count = 120,consume=true},
	},
	spellConds=
	{
		{cond=8,value=282,consume=true},
		{cond=13,value=1,consume=true},
	},
	singTime=0,
	cooldownTime=10000,
},
}