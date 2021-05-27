return {
{
	actions=
	{
		{act=1,effect=4,sound=37,delay=300,},
		{act=1,effect=0,sound=38,delay=300,},
	},
	desc=Lang.Skill.s14L1Desc,
	iconID=5,
	actRange=
	{
		{
		xStart=-1,
		xEnd=-1,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=40000,type=35,delay=0,rate=3000,value=600,id=56},
					},
					specialEffects=
					{
						{type=4,mj=0,id=56,keepTime=1000,delay=200,always=false},
					},
				},
			},
		},
		{
		xStart=1,
		xEnd=1,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=40000,type=35,delay=0,rate=3000,value=600,id=56},
					},
					specialEffects=
					{
							{type=4,mj=0,id=56,keepTime=1000,delay=200,always=false},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=-1,
		yEnd=1,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=40000,type=35,delay=0,rate=3000,value=600,id=56},
					},
					specialEffects=
					{
						{type=4,mj=0,id=56,keepTime=1000,delay=200,always=false},
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
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=70000,
},
}