return {
{
	actions=
	{
		{act=1,effect=4,sound=37,delay=300,},
		{act=1,effect=0,sound=38,delay=300,},
	},
	desc=Lang.Skill.s14L38Desc,
	iconID=14,
	actRange=
	{
		{
		xStart=-1,
		xEnd=-1,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=110000,type=35,delay=0,rate=10400,value=22800,id=5},
													{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=99},
					},
					specialEffects=
					{
						{type=4,mj=0,id=5,keepTime=1500,delay=200,always=false},
					},
				},
			},
		},
		{
		xStart=1,
		xEnd=1,
		yStart=0,
		yEnd=0,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=110000,type=35,delay=0,rate=10400,value=22800,id=5},
					},
					specialEffects=
					{
							{type=4,mj=0,id=5,keepTime=1500,delay=200,always=false},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=-1,
		yEnd=1,
		rangeType=3,
		rangeCenter=2,
		acts=
			{
				{
					targetType=1,
					conds=
					{
						{cond=1,value=1},
					},
					results=
					{
						{mj=0,timeParam=0,interval=110000,type=35,delay=0,rate=10400,value=22800,id=5},
					},
					specialEffects=
					{
						{type=4,mj=0,id=5,keepTime=1500,delay=200,always=false},
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
		{cond=8,value=637,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=1000,
},
}