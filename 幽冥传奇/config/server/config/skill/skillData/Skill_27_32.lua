return {
{
	actions=
	{
		{act=1,effect=0,sound=49,delay=0,},
		{act=1,effect=0,sound=50,delay=0,},
	},
	desc=Lang.Skill.s27L32Desc,
	iconID=27,
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
						{cond=3,value=1},
					},
					results=
					{},
					specialEffects=
					{
						{type=4,mj=0,id=24,keepTime=400,delay=0,always=true},
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
						{type=4,mj=0,id=25,keepTime=400,delay=400,always=false},
					},
				},
			},
		},
		{
			xStart=-3,
			xEnd=3,
			yStart=-3,
			yEnd=3,
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
						{mj=0,timeParam=1,type=1,id=624, rate=-2300, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=625, rate=-2300, rateType=2, delay=400},
						{mj=0,timeParam=70,type=1,id=626, rate=-330, rateType=2, delay=400},
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
			xStart=-3,
			xEnd=3,
			yStart=-3,
			yEnd=3,
			rangeType=3,
			rangeCenter=0,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 1,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=624, rate=-2300, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=625, rate=-2300, rateType=2, delay=400},
						{mj=0,timeParam=10,type=1,id=626, rate=-330, rateType=2, delay=400},
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
		{cond=8,value=950,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=1000,
},
}