return {
{
	iconID = 22,
	desc = Lang.Skill.s103L4Desc,
	singTime = 0,
	cooldownTime = 10000,
	actions = {
            { act = 2, effect = 0, sound = 9, delay = 0, wait = 500 },
	},
	actRange = {
            {
            xStart = -1,
            xEnd = 1,
            yStart = -1,
            yEnd = 1,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 5000, value = 0 },
                    { mj = 0, timeParam = 30, type = 1, id = 1140, rate = -1700, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 22, value = 1, vt = 0 },
                    },
                    specialEffects={
                    { type = 4, mj = 0, id = 8, keepTime = 400, delay = 0, always = false },
                    },
                },
            },
            },
            {
            xStart = -1,
            xEnd = 1,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 20, value = 22, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 5000, value = 0 },
                    { mj = 0, timeParam = 30, type = 1, id = 1140, rate = -1700, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 22, value = 1, vt = 0 },
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
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 20, value = 22, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 5000, value = 0 },
                    { mj = 0, timeParam = 30, type = 1, id = 1140, rate = -1700, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 22, value = 1, vt = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
            {
            xStart = -3,
            xEnd = 3,
            yStart = -3,
            yEnd = 3,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 19, value = 22, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 21, delay = 0, id = 22, vt = 0 },
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