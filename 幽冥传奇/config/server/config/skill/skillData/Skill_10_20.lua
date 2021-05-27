return {
{
	actions=
	{
	},
	desc=Lang.Skill.s10L20Desc,
	iconID=10,
	actRange=
	{
		{
		xStart=0,
		xEnd=0,
		yStart=0,
		yEnd=0,
		rangeType=0,
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
							 { type = 0, mj = 0, id = 35, keepTime = 800, delay = 0, always = true },
					},
					specialEffects=
					{
						{ type = 0, mj = 0, id = 80, keepTime = 800, delay = 0, always = true },
					},
			},
		},
	},
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 3, rate = 10000, value = 0, delay = 100,  },
                    },
                    specialEffects={
                    { type = 4, mj = 0, id = 79, keepTime = 500, delay = 0, always = false },
                    },
                },
                {
                    conds = {
                    { cond = 13, value = 1, },
                    {cond = 17,value =5,param =89,},
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 1, id = 843, rate = -2500, rateType = 0, delay = 100 },
                    { mj = 0, timeParam = 1, type = 1, id = 863, rate = -5000, rateType = 0, delay = 100 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 57, value = 0, },
                    { cond = 20, value = 7, },
                    { cond = 15, value = -1, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 19, id = 0, value = 1, vt = 1 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 7, value = 1, vt = 0 },
                    { mj = 0, timeParam = 1, type = 1, id = 812, rate = 0, rateType = 0, delay = 300 },
                    },
                    specialEffects={    },
                },
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 36, value = 1, },
                    { cond = 20, value = 7, },
                    { cond = 15, value = -1, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 19, id = 0, value = 1, vt = 1 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 7, value = 1, vt = 0 },
                    { mj = 0, timeParam = 1, type = 1, id = 812, rate = 0, rateType = 0, delay = 300 },
                    },
                    specialEffects={    },
                },
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 19, value = 7, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 21, delay = 500, id = 7, vt = 0 },
                    },
                    specialEffects={    },
                },
            },
        },
	},
	trainConds=
	{
		{cond=1,value= 1390,consume=true},
		{cond=3,value= 3068, count = 2,consume=true},
		{cond=21,value=130000,consume=false},
	},
	spellConds=
	{
		{cond=8,value=1000,consume=true},
	},
	singTime=0,
	cooldownTime=3500,
},
}