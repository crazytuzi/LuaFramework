return {
{
	iconID = 22,
	desc = Lang.Skill.s22L1Desc,
	singTime = 0,
	cooldownTime = 5000,
	actions = {
            { act = 1, effect = 0, sound = 9, delay = 0, wait = 800 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 30, type = 1, id = 499, rate = -900, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 22, value = 1, vt = 0 },
                    },
                    specialEffects={
                    { type = 4, mj = 0, id = 8, keepTime = 400, delay = 0, always = false },
                    },
                },
            },
            },
	},
	trainConds = {
	},
	spellConds = {
            { cond = 13, value = 6, consume = false },
	},
},
}