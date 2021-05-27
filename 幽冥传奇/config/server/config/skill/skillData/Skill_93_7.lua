return {
{
	iconID = 12,
	desc = Lang.Skill.s93L7Desc,
	singTime = 0,
	cooldownTime = 10000,
	actions = {
            { act = 2, effect = 0, sound = 2, delay = 0, wait = 500 },
	},
	actRange = {
            {
            xStart = -1,
            xEnd = -1,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 2,
            acts = {
                {
                    targetType = 1,
                    conds = {
                    { cond = 1, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 0, interval = 60000, type = 35, delay = 0, rate = 8250, value = 0, id = 3 },
                    },
                    specialEffects={    },
                },
            },
            },
            {
            xStart = 1,
            xEnd = 1,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 2,
            acts = {
                {
                    targetType = 1,
                    conds = {
                    { cond = 1, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 0, interval = 60000, type = 35, delay = 0, rate = 8250, value = 0, id = 3 },
                    },
                    specialEffects={    },
                },
            },
            },
            {
            xStart = 0,
            xEnd = 0,
            yStart = -1,
            yEnd = 1,
            rangeType = 3,
            rangeCenter = 2,
            acts = {
                {
                    targetType = 1,
                    conds = {
                    { cond = 1, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 0, interval = 60000, type = 35, delay = 0, rate = 8250, value = 0, id = 3 },
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
            { cond = 13, value = 6, consume = false },
	},
},
}