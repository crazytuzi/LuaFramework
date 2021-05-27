return {
{
	actions=
	{
		{act=0,effect=10020,sound=18,delay=200,},
	},
	desc=Lang.Skill.s4L31Desc,
	iconID=4,
	actRange=
	{
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
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=16000,value=0},
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
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=15500,value=0},
					},
					specialEffects=
					{
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=1,
		yStart=0,
		yEnd=1,
		rangeType=2,
		rangeCenter=1,
		acts=
			{
				{
					conds=
					{
						{cond = 1,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=15500,value=0},
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
			{cond=1,value=300,consume=false},
		{cond=21,value=32500,consume=true},
		{cond=3,value= 446, count = 4,consume=true},
	},
	spellConds=
	{
		{cond=8,value=156,consume=true},
		{cond=13,value=1,consume=true},
	},
	singTime=0,
	cooldownTime=0,
},
}