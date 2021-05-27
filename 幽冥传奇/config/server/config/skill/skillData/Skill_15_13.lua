return {
{
	actions=
	{
		{act=2,effect=0,sound=39,delay=0,},
		{act=2,effect=0,sound=40,delay=0,},
	},
	desc=Lang.Skill.s15L13Desc,
	iconID=15,
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
						{type=4,mj=0,id=6,keepTime=0,delay=400,always=true},
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
			rangeCenter=1,
			acts=
			{
				{
					conds=
					{
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=4,delay=450,rate=7400,value=7800,interval=0},
												{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=99},
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
		{cond=8,value=707,consume=true},
	},
	singTime=0,
	cooldownTime=650,
},
}