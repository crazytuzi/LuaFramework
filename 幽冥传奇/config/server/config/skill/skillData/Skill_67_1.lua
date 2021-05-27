return {
{
	actions=
	{
		{act=1,effect=20030,sound=58,delay=0,},
	},
	desc=Lang.Skill.s67L1Desc,
	iconID=19,
	actRange=
	{
		{
			xStart=-13,
			xEnd=13,
			yStart=-13,
			yEnd=13,
			rangeType=3,
			rangeCenter=2,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 13,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=1,id=63, rate=-1000, rateType=2, delay=400},
						{mj=0,timeParam=1,type=1,id=64, rate=-1000, rateType=2, delay=400},
						{mj=0,timeParam=30,type=1,id=62, rate=-1000, rateType=2, delay=400},
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
		{cond=13,value=13,consume=false},
	},
	singTime=0,
	cooldownTime=3500,
},
}