return {
{
	iconID = 22,
	desc = Lang.Skill.s22L1Desc,
	singTime = 0,
	cooldownTime = 6000,
	actions = {
            { act = 1, effect = 0, sound = 0, delay = 0, wait = 800 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 0,
            acts = {
                {
					targetType = 1,
                    conds = {
                    },
                    results = {
                    },
                    specialEffects={
                    { type = 4, mj = 0, id = 18, keepTime = 600, delay = 0, always = true },
                    },
                },
            },
            },
            {
            xStart = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 3, delay = 200, rate = 9000, value = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 11, value = 5000, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 1, id = 428, rate = -0, rateType = 0, delay = 200 },
                    },
                    specialEffects={
                    },
                },
            },
            },
	},
	trainConds = {
	},
	spellConds = {
            { cond = 13, value = 3, consume = false },
	},
},
}