return {
{
	actions=
	{
		{act=1,effect=0,sound=58,},
	},
	desc=Lang.Skill.s45L1Desc,
	iconID=2000,
	actRange=
	{
		{
			xStart=-10,
			xEnd=10,
			yStart=-10,
			yEnd=10,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
					   {cond = 6,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=4,delay=300, rate=17000,value=1},
				    },
					specialEffects=
					{
					},
				},
			},
		},
		{
			xStart=-10,
			xEnd=10,
			yStart=-10,
			yEnd=10,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
					   {cond = 5,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=4,delay=300, rate=35000,value=1},
				    },
					specialEffects=
					{
					},
				},
			},
		},
		{
			xStart=-10,
			xEnd=10,
			yStart=-10,
			yEnd=10,
			rangeType=3,
			rangeCenter=1,
			acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond = 13,value =1},
					},
					results=
					{
					},
					specialEffects=
					{
						{type=4,mj=0,id=28,keepTime=2000,delay=300,always=false},
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
		{cond=13,value=15,consume=true},
	},
	singTime=0,
	cooldownTime=120000,
} ,
}