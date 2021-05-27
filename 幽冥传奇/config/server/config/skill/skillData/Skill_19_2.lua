return {
{
	actions=
	{
		{act=1,effect=0,sound=33,delay=0,},
	},
	desc=Lang.Skill.s19L2Desc,
	iconID=19,
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
					{},
					results=
					{},
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
			rangeType=3,
			rangeCenter=2,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=32, rate=-1000, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=33, rate=-1000, rateType=2, delay=400},
						{mj=0,timeParam=120,type=1,id=31, rate=-1000, rateType=2, delay=400},
												{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=99},
					},
					specialEffects=
					{
						{type=4,mj=0,id=16,keepTime=400,delay=400,always=false},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=30,consume=false},
		{cond=21,value=1000,consume=false},
	},
	spellConds=
	{
		{cond=8,value=155,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=1500,
},
}