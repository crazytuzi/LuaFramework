return {
{
	iconID = 24,
	desc = Lang.Skill.s104L3Desc,
	singTime = 0,
	cooldownTime = 10000,
	actions = {
            { act = 2, effect = 0, sound = 11, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = -8,
            xEnd =8,
            yStart = -8,
            yEnd = 8,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 3, value = 1, },
                    },
                    results = {
                    { timeParam = 10, type = 1, delay = 0, id = 521, rate = 0, value = 0, interval = 1, },
                    },
                    specialEffects={
                    { type = 5, mj = 0, id = 9, keepTime = 0, delay = 0, always = false },
                    },
                },
            },
            },
            {
            xStart = -8,
            xEnd = 8,
            yStart = -8,
            yEnd = 8,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 35, value = 1, },
                    { cond = 17, value = 1, param = 38},
                    },
                    results = {
                    },
                },
            },
            },
            {
            xStart = -8,
            xEnd = 8,
            yStart = -8,
            yEnd = 8,
            rangeType = 3,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 35, value = 1, },
                    },
                    results = {
                    { timeParam = 10, type = 1, delay = 0, id = 521, rate = 0, value = 0, interval = 1, },
                    },
                    specialEffects={
                    { type = 5, mj = 0, id = 9, keepTime = 0, delay = 0, always = false },
                    },
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