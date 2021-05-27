return {
{
	actions=
		{
			{act=1,effect=1,sound=34,delay=200,},
		},
	desc=Lang.Skill.s11L23Desc,
	iconID=11,
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
						{type=5,mj=0,id=1,keepTime=0,delay=0,always=false},
					},
				},
			},
		},
		{
		xStart=-1,
		xEnd=1,
		yStart=-1,
		yEnd=1,
		rangeType=3,
		rangeCenter=1,
		acts=
			{
				{
				conds=
					{
						{cond=15,value=-1},
						{cond=13,value=1},
						{cond=3,value=0},
					},
				results=
					{
						{mj=0,timeParam=1,type=4,delay=300,rate=4700,value=11500},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,id=8,value=1,interval=300},
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
				{
				conds=
					{
						{cond=15,value=-1},
						{cond=13,value=1},
						{cond=3,value=0},
						{cond=22,value=8},
					},
				results=
					{
						{mj=0,timeParam=1,type=4,delay=300,rate=4700,value=11500},
						{mj=0,timeParam=1,type=21,delay=0,value=8},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,id=8,value=1,interval=300},
					},
				specialEffects=
					{
					},
				},
				{
				conds=
					{
						{cond=15,value=-1},
						{cond=13,value=1},
						{cond=3,value=0},
						{cond=22,value=8},
					},
				results=
					{
						{mj=0,timeParam=1,type=4,delay=300,rate=4700,value=11500},
						{mj=0,timeParam=1,type=21,delay=0,value=8},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,id=8,value=1,interval=300},
					},
				specialEffects=
					{
					},
				},
				{
				conds=
					{
						{cond=15,value=-1},
						{cond=13,value=1},
						{cond=3,value=0},
						{cond=22,value=8},
					},
				results=
					{
						{mj=0,timeParam=1,type=4,delay=300,rate=4700,value=11500},
						{mj=0,timeParam=1,type=21,delay=0,value=8},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,id=8,value=1,interval=300},
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
			{cond=8,value=253,consume=true},
		},
	singTime=0,
	cooldownTime=4000,
},
}