return {
{
	iconID = 22,
	desc = Lang.Skill.s22L1Desc,
	singTime = 0,
	cooldownTime = 0,
	actions = {
            { act = 1, effect = 0, sound = 0, delay = 0, wait = 800 },
	},
	actRange = {
            {
            xStart = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 3, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 1, id = 634, rate = -0, rateType = 0, delay = 0 },
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