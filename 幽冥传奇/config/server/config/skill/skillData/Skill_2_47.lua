return {
{
	actions=
	{
		{act=0,effect=10000,sound=29,delay=500,},
	},
	desc=Lang.Skill.s2L47Desc,
	iconID=2,
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
						{cond = 3,value =true},
					},
					results=
					{
						{mj=0,timeParam=1,type=7,delay=0,id=81,value=9400,vt=0},
						{mj=0,timeParam=1,type=7,delay=0,id=82,value=47000,vt=0},
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
		{cond=15,value=1,consume=false},
	},
	singTime=0,
	cooldownTime=100,
},
}