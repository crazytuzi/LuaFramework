return {
{
	actions=
	{
		{act=1,effect=0,sound=46,delay=0,},
	},
	desc=Lang.Skill.s98L10Desc,
	appearanceId = 360,
	iconID=5000,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=0,
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
						{type=4,mj=0,id=105,keepTime=200,delay=300,always=true},
					},
				},
			},
		},
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
						{cond = 1,value =1},
					},
					results=
					{
					  {mj=0,timeParam=1,type=3,delay=1000, rate=6000,value=0},
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
	},
	singTime=0,
	cooldownTime=30000,
	triggerRatio = 4000,
},
}