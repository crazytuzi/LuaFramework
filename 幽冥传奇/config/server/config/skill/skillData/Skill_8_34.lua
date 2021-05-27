return {
{
	actions=
	{
		{act=0,effect=10050,sound=33,delay=200,},
	},
	desc=Lang.Skill.s8L34Desc,
	iconID=8,
	actRange=
	{
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
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=28500,value=0},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=23500,value=0},
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
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=300, rate=23500,value=0},
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
						{mj=0,timeParam=1,type=3,delay=300, rate=23500,value=0},
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
		{cond=1,value=400,consume=true},
		{cond=3,value= 1630, count = 4,consume=true},
		{cond=21,value=76000,consume=false},
	},
	spellConds=
	{
		{cond=8,value=320,consume=true},
		{cond=13,value=2,consume=true},
	},
	singTime=0,
	cooldownTime=15000,
},
}