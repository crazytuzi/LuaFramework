return {
{
	actions=
	{
		{act=1,effect=2,sound=35,delay=100,},
	},
	desc=Lang.Skill.s12L2Desc,
	iconID=12,
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
						{type=5,mj=0,id=2,keepTime=0,delay=0,always=false},
					},
				},
			},
		},
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
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=1,type=4,delay=200,rate=9200,value=1400},
												{mj=0,timeParam=1,type=66,id=90},
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
						{type=4,mj=0,id=3,keepTime=100,delay=100,always=true},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=20,consume=false},
		{cond=21,value=1000,consume=false},
	},
	spellConds=
	{
		{cond=8,value=61,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=580,
},
}