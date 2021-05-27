return {
{
	iconID = 14,
	desc = Lang.Skill.s14L1Desc,
	singTime = 0,
	cooldownTime = 30000,
	actions = {
            { act = 2, effect = 0, sound = 7, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 3, value = 1, },
                    { cond = 17, value = 54, param = 1 },
                    },
                    results = {
                    { timeParam = 1, type = 1, delay = 300, id = 339, rate = 0, interval = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
	},
	trainConds = {
	},
	spellConds = {
            { cond = 8, value = 10, consume = true },
	},
},
}