return {
{
	actions=
	{
	},
	desc=Lang.Skill.s9L11Desc,
	iconID=9,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=0,
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
							{mj=0,timeParam=200, type=64, delay=100, id = 6, value=7,interval = 40,},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=13,value=1},
						{cond=15,value=-1},
						{cond=42,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=753,rate=0, rateType=0, delay=200},
					},
					specialEffects=
					{
						{ type = 1, mj = 0, id = 83, keepTime = 600, delay =  150, always = false },
					},
				},
				{
					conds=
					{
						{cond=42,value=-1},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,type=7,id=18,keepTime = 600, delay = 100, always = false},
					},
					specialEffects=
					{
					},
				},
			},
		},
		{
		xStart=-1,
		xEnd=1,
		yStart=-1,
		yEnd=1,
		rangeType=3,
		rangeCenter=0,
		acts=
			{
				{
					conds=
					{
						{cond=42,value=1},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=3,delay=200,rate=15000,  delay=400},
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
		{cond=1,value= 900,consume=true},
		{cond=3,value= 3067, count = 2,consume=true},
		{cond=21,value=38000,consume=false},
	},
	spellConds=
	{
		{cond=8,value=102,consume=true},
	},
	singTime=0,
	cooldownTime=4000,
},
}