return {
{
	actions=
	{
		{act=0,effect=10040,sound=32,delay=200,},
	},
	desc=Lang.Skill.s7L31Desc,
	iconID=7,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=18000,value=0},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=24500,value=0},
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
		yStart=3,
		yEnd=3,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=24500,value=0},
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
		yStart=4,
		yEnd=4,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=24500,value=0},
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
		yStart=5,
		yEnd=5,
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
						{mj=0,timeParam=1,type=3,delay=300, rate=24500,value=0},
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
			{cond=1,value=400,consume=false},
		{cond=21,value=64000,consume=true},
		{cond=3,value= 448, count = 4,consume=true},
	},
	spellConds=
	{
		{cond=8,value=300,consume=true},
		{cond=15,value=1,consume=false},
		{cond=35,value=3,consume=true},
		{cond=13,value=3,consume=true},
},
	singTime=0,
	cooldownTime=12000,
},
}