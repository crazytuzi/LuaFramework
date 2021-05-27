return {
{
	iconID = 3,
	desc = Lang.Skill.s84L12Desc,
	singTime = 0,
	cooldownTime = 10000,
	actions = {
            { act = 0, effect = 10020, sound = 2, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 2,
            rangeType = 2,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 3, rate = 32000, value = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
	},
	trainConds = {
 { cond = 43, value = 1, consume = false },
 { cond = 1, value = 1, consume = false },
 { cond = 45, value = 251, consume = false },
	},
	spellConds = {
            { cond = 13, value = 2, consume = false },
	},
},
}