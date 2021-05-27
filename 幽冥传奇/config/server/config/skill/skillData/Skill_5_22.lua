return {
{
	actions=
	{
	},
	desc=Lang.Skill.s5L22Desc,
	iconID=5,
	actRange=
	{
		{
		xStart=-0,
		xEnd=0,
		yStart=-0,
		yEnd=0,
		rangeType=3,
		rangeCenter=1,
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
						{type=4,mj=0,id=10090,keepTime=400,delay=0,always=false},
					},
				},
			},
		},
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=2,
		rangeType=2,
		rangeCenter=1,
		acts=
			{
				{
					conds=
					{
						{cond=15,value=-1},
						{cond=3,value=0},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=38,ignoreTargetDis=1,delay=0,id=5,value=1,interval=50},
						{mj=0,timeParam=1,type=32,id=352,ignoreTargetDis=1,rate=10000, rateType=0, delay=400},
													{mj=0,timeParam=1,type=66,id=91},
						{mj=0,timeParam=1,type=66,id=92},
						{mj=0,timeParam=1,type=66,id=93},
						{mj=0,timeParam=1,type=66,id=94},
						{mj=0,timeParam=1,type=66,id=95},
						{mj=0,timeParam=1,type=66,id=98},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=15,value=-1},
						{cond=3,value=0},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=200,type=38,ignoreTargetDis=1,delay=0,id=5,value=1,interval=50},
						{mj=0,timeParam=1,type=32,id=352,ignoreTargetDis=1,rate=10000, rateType=0, delay=400},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=15,value=-1},
						{cond=3,value=0},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,delay=0,id=0,value=1,interval=50},
						{mj=0,timeParam=1,type=32,id=352,ignoreTargetDis=1,rate=10000, rateType=0, delay=400},
						{mj=0,timeParam=1,type=3,delay=300, rate=8000,value=0},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=15,value=-1},
						{cond=3,value=0},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,delay=0,id=0,value=1,interval=50},
						{mj=0,timeParam=1,type=32,id=352,ignoreTargetDis=1,rate=10000, rateType=0, delay=400},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=15,value=-1},
						{cond=3,value=0},
						{cond=13,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,type=38,ignoreTargetDis=1,delay=0,id=0,value=1,interval=50},
						{mj=0,timeParam=1,type=32,id=352,ignoreTargetDis=1,rate=10000, rateType=0, delay=400},
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
		yEnd=2,
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
						{mj=0,timeParam=200,id=5,type=37,delay=0, value=1,interval=50,vt=0,rate=30,buffType=0},
					},
					specialEffects=
					{
						{type=1,mj=0,id=10090,keepTime=150,delay=0,always=false},
					},
				},
				{
					conds=
					{
						{cond=22,value=5},
						{cond=3,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,id=5,type=37,delay=0, value=1,interval=50,vt=1,rate=30},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=22,value=5},
						{cond=3,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,id=0,type=37,delay=0, value=1,interval=50,vt=0,rate=30},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=22,value=5},
						{cond=3,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,id=0,type=37,delay=0, value=1,interval=50,vt=1,rate=30},
					},
					specialEffects=
					{
					},
				},
				{
					conds=
					{
						{cond=22,value=5},
						{cond=3,value=1},
					},
					results=
					{
						{mj=0,timeParam=200,type=21,delay=0, value=5},
						{mj=0,timeParam=1,id=0,type=37,delay=0, value=1,interval=50,vt=0,rate=30},
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
		{cond=1,value=300,consume=false},
		{cond=21,value=54000,consume=false},
		{cond=3,value= 449, count = 3,consume=true},
	},
	spellConds=
	{
		{cond=8,value=254,consume=true},
	},
	singTime=0,
	cooldownTime=4000,
},
}