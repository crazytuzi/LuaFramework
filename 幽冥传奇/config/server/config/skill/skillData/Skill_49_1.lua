return {
{
	actions=
	{
		{act=1,effect=20040,sound=54,delay=400,},
	},
	desc=Lang.Skill.s49L1Desc,
	iconID=13,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=0,
		rangeType=4,
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
						{type=0,mj=0,id=20040,keepTime=300,delay=100,always=true},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=-4,
		yEnd=0,
		rangeType=2,
		rangeCente=1,
		acts=
				{
					{
					conds=
					{
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=4,delay=600,rate=10000,value=0},
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
	},
	spellConds=
	{
		{cond=13,value=2,consume=false},
	},
	singTime=0,
	cooldownTime=2000,
},
}