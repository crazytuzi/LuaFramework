return {
{
	actions=
	{
		{act=0,effect=0,sound=59,delay=0,},
	},
	desc=Lang.Skill.s31L3Desc,
	iconID=2000,
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
					conds=
					{
					   {cond=3,value=1},
					},
					results=
					{
					},
					specialEffects=
					{
						{type=5,mj=0,id=29,keepTime=0,delay=0,always=false},
					},
				},
			},
		},
		{
			xStart=-12,
			xEnd=12,
			yStart=-12,
			yEnd=12,
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
						{mj=0,timeParam=1,type=3,delay=0, rate=8000,value=0},
					},
					specialEffects=
					{
					{type=0,mj=0,id=68,keepTime=400,delay=500,always=false},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=300,consume=false},
	},
	spellConds=
	{
	},
	singTime=0,
	cooldownTime=180000,
} ,
}