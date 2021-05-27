return {
{
	iconID = 2,
	desc = Lang.Skill.s2L1Desc,
	singTime = 0,
	cooldownTime = 1000,
	actions = {
            { act = 0, effect = 10010, sound = 1, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = 1,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 5,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 31, value = 0, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 3, rate = 6000, value = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
	},
	trainConds = {
	},
	spellConds = {
            { cond = 13, value = 1, consume = false },
	},
},
}