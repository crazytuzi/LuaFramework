return {
{
	actions=
	{
		{act=1,effect=26,sound=57,delay=0,},
	},
	desc=Lang.Skill.s28L37Desc,
	iconID=28,
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
						{type=5,mj=0,id=26,keepTime=0,delay=0,always=false},
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
						{type=4,mj=0,id=27,keepTime=800,delay=400,always=true},
					},
				},
			},
		},
		{
			xStart=2,
			xEnd=2,
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
						{type=4,mj=0,id=27,keepTime=800,delay=600,always=true},
					},
				},
			},
		},
		{
			xStart=0,
			xEnd=0,
			yStart=3,
			yEnd=3,
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
						{type=4,mj=0,id=27,keepTime=800,delay=800,always=true},
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
			rangeCenter=0,
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
						{mj=0,timeParam=1,type=33,delay=800, rate=18300,rateType=2,value=33000},
												{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=100},
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
		{cond=8,value=1059,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=850,
},
}