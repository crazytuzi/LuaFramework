return {
{
	iconID = 24,
	desc = Lang.Skill.s24L8Desc,
	singTime = 0,
	cooldownTime = 1000,
	actions = {
            { act = 2, effect = 61, sound = 11, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = -1,
            xEnd = 1,
            yStart = -1,
            yEnd = 1,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 6, value = 1, },
                    },
                    results = {
                    { timeParam = 10, type = 1, delay = 100, id = 526, rate = 0, value = 0, interval = 1, },
                    },
                    specialEffects={
                    { type = 5, mj = 0, id = 9, keepTime = 0, delay = 0, always = false },
                    },
                },
            },
            },
            {
            xStart = -1,
            xEnd = 1,
            yStart = -1,
            yEnd = 1,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 6, value = 1, },
                    { cond = 17, value = 1, param = 38},
                    },
                    results = {
                    { timeParam = 1, type = 13, delay = 100, rate = 1300, value = 0, },
                    },
                },
            },
            },
	},
	trainConds = {
            { cond = 1, value = 57, consume = false },
            { cond = 43, value = 1, consume = false },
	},
	spellConds = {
            { cond = 8, value = 1200, consume = true },
	},
},
}