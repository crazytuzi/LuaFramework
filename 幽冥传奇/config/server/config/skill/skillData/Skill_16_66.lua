return {
{
	actions=
	{
		{act=1,effect=0,sound=41,delay=0,},
	},
	desc=Lang.Skill.s16L66Desc,
	iconID=16,
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
						{cond = 3,value =1},
						{cond = 17,value =54,param=112},
					},
					results=
					{
						{timeParam=1,type=1,delay=300,id=971,rate=0,intervalRate=3000,maxDur=300,intervalAddType=0,rateType=4},
					},
					specialEffects=
					{
						{type=4,mj=0,id=8,keepTime=154,delay=0,always=false},
					},
				},
			},
		},
	},
	trainConds=
	{
		{cond=1,value=1000,consume=false},
		{cond=21,value=520000,consume=true},
		{cond=3,value= 450, count = 20,consume=true},
	},
	spellConds=
	{
		{cond=8,value=1296,consume=true},
	},
	singTime=0,
	cooldownTime=3000,
},
}