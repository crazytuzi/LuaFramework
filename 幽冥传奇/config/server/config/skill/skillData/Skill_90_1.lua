return {
{
	actions=
	{
		{act=1,effect=0,sound=46,delay=0,},
	},
	desc=Lang.Skill.s90L1Desc,
	iconID=5000,
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
					},
					results=
					{
					  {timeParam=1,type=1,delay=300,id=681,rate=0,intervalRate=0,maxDur=0,intervalAddType=3,rateType=4},
					  {timeParam=1,type=1,delay=300,id=682,rate=0,intervalRate=0,maxDur=0,intervalAddType=3,rateType=4},
					  {timeParam=1,type=1,delay=300,id=683,rate=0,intervalRate=0,maxDur=0,intervalAddType=3,rateType=4},
					},
					specialEffects=
					{
						{type=7,mj=0,id=300,keepTime=2000,delay=0,always=false},
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
	},
	singTime=0,
	cooldownTime=60000,
	triggerRatio = 500,
},
}