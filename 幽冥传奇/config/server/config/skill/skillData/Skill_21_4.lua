return {
{
	actions=
	{
		{act=1,effect=13,sound=45,delay=0,},
		{act=1,effect=0,sound=46,delay=0,},
	},
	desc=Lang.Skill.s21L4Desc,
	iconID=21,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=-0,
		yEnd=0,
		rangeType=0,
		rangeCenter=1,
		acts=
			{
				{
					conds=
					{
						{cond = 13,value =0},
					},
					results=
					{
						{mj=0,timeParam=100,type=20,delay=0,vt=1, id=17,value=1},
						{mj=0,timeParam=24,type=1,delay=0,id=179,rate=500,rateType=2,},
						{mj=0,timeParam=1,type=66,id=100},
					},
					specialEffects=
					{
						{type=4,mj=0,id=14,keepTime=1000,delay=500,always=false},
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
		rangeCenter=1,
		acts=
			{
				{
					conds=
					{
						{cond = 22,value =17},
						{cond = 3,value =1},
					},
					results=
					{
						{mj=0,timeParam=24,type=1,delay=0,id=179,rate=500,rateType=2,},
					},
					 specialEffects=
					{
						{type=4,mj=0,id=14,keepTime=1000,delay=500,always=false},
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
			rangeCenter=1,
			acts=
			{
				{
					targetType=0,
					conds=
					{
						{cond = 3,value =1},
					},
					results=
					{
						{mj=0,timeParam=1,type=21,delay=0, id=17,vt=1},
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
		{cond=8,value=636,consume=true},
	},
	singTime=0,
	cooldownTime=3000,
},
}