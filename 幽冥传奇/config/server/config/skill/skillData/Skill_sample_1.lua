return {
{
	actions=
	{
		{act=1,effect=1,sound=34,delay=0,},
	},
	desc=Lang.Skill.s1L1Desc,
	iconID=1,
	actRange=
	{
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
				    targetType=0,
					conds=
					{
						{cond = 5,value =1},
					},
					results=
					{
						{mj=0,timeParam=5,type=1,delay=0,  buffType=1,id=80,rate=3000,value=3000,interval=1,vt=0,canDodge =false },
						{mj=0,timeParam=1,type=2,delay=0, buffType=1,id=2},
						{mj=0,timeParam=1,type=3,delay=0,  rate=3000,value=200},
						{mj=0,timeParam=1,type=4,delay=0, rate=3000,value=200},
						{mj=0,timeParam=1,type=5,delay=0, value=-1},
						{mj=0,timeParam=1,type=6,delay=0, value=-1},
						{mj=0,timeParam=1,type=7,delay=0, buffType =1,value=100,vt=0 },
						{mj=0,timeParam=1,type=8,delay=0, rate=1000,value=3000},
						{mj=0,timeParam=1,type=9,delay=0, value=-1},
						{mj=0,timeParam=1,type=10,delay=0,value=1},
						{mj=0,timeParam=1,type=11,delay=0, id=1,value=1},
						{mj=0,timeParam=1,type=16,delay=0, buffType=1,id=1000},
						{mj=0,timeParam=1,type=53,id=2},
						{mj=0,timeParam=1,type=54,id=8,value=8},
					},
					specialEffects=
					{
						{type=1,mj=0,id=22,keepTime=2000,delay=500,always=false},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=1,consume=false,exceptVip=false },
		{cond=6,value=1,consume=false},
		{cond=32,value=1,consume=false},
	},
	spellConds=
	{
		{cond=7,value=10,consume=true},
		{cond=8,value=10,consume=true},
		{cond=13,value=3,consume=true},
		{cond=35,value=2,consume=true},
	},
	singTime=1000,
        mjSingTimeEffect=
        {
           {mj=1, value=-100,},
           {mj=2, value=-200,},
        },
	cooldownTime=1000,
	triggerRatio = 10,
    mjCooldownEffect=
    {
       {mj=1, value=-100,},
       {mj=2, value=-200,},
    },
    afterAtkWaitTime = 300,
},
}