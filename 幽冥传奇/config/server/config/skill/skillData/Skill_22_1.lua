return {
{
	actions=
	{
		{act=1,effect=18,sound=48,delay=0,},
	},
	desc=Lang.Skill.s22L1Desc,
	iconID=22,
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
					conds=
					{
						{cond=3,value=1},
					},
					results=
					{
					},
					specialEffects=
					{
						{type=5,mj=0,id=18,keepTime=0,delay=0,always=false},
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
						{type=3,mj=0,id=17,keepTime=100,delay=200,always=true},
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
						{type=4,mj=0,id=19,keepTime=200,delay=300,always=true},
					},
				},
			},
		},
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
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=33,delay=600,rate=8000,rateType=2,value=500},
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
	{
		{cond=1,value=3,consume=false},
	},
	spellConds=
	{
		{cond=8,value=0,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=2000,
},
}