return {
{
	iconID = 14,
	desc = Lang.Skill.s95L10Desc,
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
                    { timeParam = 1, type = 1, delay = 300, id = 348, rate = 0, interval = 0 },
                    { timeParam = 1, type = 1, delay = 300, id = 368, rate = 0, interval = 0 },
                    { timeParam = 1, type = 1, delay = 300, id = 388, rate = 0, interval = 0 },
                    { timeParam = 1, type = 1, delay = 300, id = 408, rate = 0, interval = 0 },
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
	},
},
}