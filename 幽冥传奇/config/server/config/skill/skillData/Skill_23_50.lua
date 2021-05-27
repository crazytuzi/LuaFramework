return {
{
	actions=
	{
		{act=1,effect=15,sound=49,delay=0,},
		{act=1,effect=0,sound=50,delay=0,},
	},
	desc=Lang.Skill.s23L50Desc,
	iconID=23,
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
					targetType=1,
					conds=
					{
					},
					results=
					{
					},
					specialEffects=
					{
						{type=4,mj=0,id=15,keepTime=400,delay=0,always=true},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=0,
		rangeType=4,
		rangeCenter=2,
		acts=
				{
					{
					targetType=1,
					conds=
					{
					},
					results=
					{
					},
					specialEffects=
					{
						{type=3,mj=0,id=49,keepTime=500,delay=100,always=true},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=0,
		acts=
				{
					{
					targetType=1,
					conds=
					{
					},
					results=
					{
					},
					specialEffects=
					{
						{type=4,mj=0,id=16,keepTime=200,delay=550,always=false},
					},
				},
			},
		},
		{
			xStart=0,
			xEnd=0,
			yStart=0,
			yEnd=0,
			rangeType=3,
			rangeCenter=0,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 5,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=528, rate=-2900, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=529, rate=-2900, rateType=2, delay=400},
						{mj=0,timeParam=85,type=1,id=530, rate=-390, rateType=2, delay=400},
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
		{
			xStart=0,
			xEnd=0,
			yStart=0,
			yEnd=0,
			rangeType=3,
			rangeCenter=0,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 6,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=528, rate=-2900, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=529, rate=-2900, rateType=2, delay=400},
						{mj=0,timeParam=10,type=1,id=530, rate=-390, rateType=2, delay=400},
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
		{cond=8,value=353,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=1200,
},
}