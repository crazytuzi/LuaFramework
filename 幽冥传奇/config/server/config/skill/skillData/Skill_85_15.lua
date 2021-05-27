return {
{
	iconID = 4,
	desc = Lang.Skill.s85L15Desc,
	singTime = 0,
	cooldownTime = 16000,
	actions = {
            { act = 0, effect = 10030, sound = 3, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 4,
            rangeType = 2,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 3, rate = 25000, value = 0 },
                    { mj = 0, delay = 0, timeParam = 200, type = 20, id = 4, value = 1, vt = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
            {
            xStart = -1,
            xEnd = 1,
            yStart = 0,
            yEnd = 4,
            rangeType = 2,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 20, value = 4, },
                    },
                    results = {
                    { mj = 0, delay = 100, timeParam = 1, type = 3, rate = 12500, value = 0 },
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