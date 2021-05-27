return {
{
	actions=
	{
		{act=1,effect=11,sound=44,delay=0,},
	},
	desc=Lang.Skill.s18L30Desc,
	iconID=1005,
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
						{type=5,mj=0,id=11,keepTime=0,delay=0,always=false},
					},
	                        },
	                },
	        },
		{
			xStart=-1,
			xEnd=0,
			yStart=-1,
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
						{type=4,mj=0,id=40,keepTime=800,delay=300,always=true},
					},
				},
			},
		},
		{
			xStart=0,
			xEnd=1,
			yStart=0,
			yEnd=1,
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
						{type=4,mj=0,id=40,keepTime=800,delay=500,always=true},
					},
				},
			},
		},
		{
			xStart=0,
			xEnd=1,
			yStart=-1,
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
						{type=4,mj=0,id=40,keepTime=800,delay=700,always=true},
					},
				},
			},
		},
		{
			xStart=-1,
			xEnd=0,
			yStart=0,
			yEnd=1,
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
						{type=4,mj=0,id=40,keepTime=800,delay=700,always=true},
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
						{mj=0,timeParam=1,type=4,delay=700, rate=17200,value=27000},
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
	},
	trainConds=
	{{cond=43,value=1,consume=false},
	},
	spellConds=
	{
		{cond=8,value=1320,consume=true},
		{cond=13,value=12,consume=true},
	},
	singTime=0,
	cooldownTime=850,
},
}