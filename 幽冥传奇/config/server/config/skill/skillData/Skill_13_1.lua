return {
{
	actions=
	{
		{act=1,effect=29,sound=36,delay=0,},
	},
	desc=Lang.Skill.s13L1Desc,
	iconID=13,
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
						{cond = 3,value =1},
					},
					results=
					{
						{mj=0,delay=100,timeParam=1,type=39,value=14,aiId=1,id=0},
					},
					specialEffects=
					{
						{type=4,mj=0,id=29,keepTime=0,delay=100,always=true},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=5,consume=false},
	},
	spellConds=
	{
		{cond=8,value=57,consume=true},
	},
	singTime=0,
	cooldownTime=10000,
},
}