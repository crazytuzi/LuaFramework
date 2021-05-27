return {
{
	iconID = 21,
	desc = Lang.Skill.s102L8Desc,
	singTime = 0,
	cooldownTime = 0,
	actions = {
            { act = 2, effect = 0, sound = 8, delay = 0, wait = 500 },
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
                    },
                    results = {    },
                    specialEffects={
                    { type = 5, mj = 0, id = 6, keepTime = 0, delay = 0, always = false },
                    },
                },
            },
            },
            {
            xStart = -1,
            xEnd = 1,
            yStart = -1,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 63, value = 163, param = 42 },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 12500, value = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 21, value = 1, vt = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 21, value = 1, vt = 1 },
                    { mj = 0, timeParam = 1, type = 1, id = 446, rate = 0, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 1, type = 1, id = 466, rate = 0, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 1, type = 1, id = 486, rate = 0, rateType = 2, delay = 200 },
                    },
                    specialEffects={
                    { type = 3, mj = 0, id = 10050, keepTime = 300, delay = 0, always = false },
                    { type = 4, mj = 0, id = 7, keepTime = 500, delay = 200, always = false },
                    },
                },
            },
            },
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 62, value = 163, param = 42 },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 19000, value = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 21, value = 1, vt = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 21, value = 1, vt = 1 },
                    { mj = 0, timeParam = 1, type = 1, id = 446, rate = 0, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 1, type = 1, id = 466, rate = 0, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 1, type = 1, id = 486, rate = 0, rateType = 2, delay = 200 },
                    },
                    specialEffects={
                    { type = 3, mj = 0, id = 10100, keepTime = 300, delay = 0, always = false },
                    { type = 4, mj = 0, id = 32, keepTime = 500, delay = 200, always = false },
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
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 62, value = 163, param = 42 },
                    { cond = 20, value = 21, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 200, rate = 11000, value = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart = 0,
            xEnd = 0,
            yStart = 10,
            yEnd = 10,
            rangeType = 2,
            rangeCenter = 1,
            acts = {
                {
                    targetType = 1,
                    conds = {
                    { cond = 22, value = 21, },
                    { cond = 63, value = 163, param = 42 },
                    },
                    results = {    },
                    specialEffects={
                    { type = 3, mj = 0, id = 10050, keepTime = 300, delay = 500, always = false },
                    },
                },
            },
            },
            {
            xStart = 0,
            xEnd = 0,
            yStart = 10,
            yEnd = 10,
            rangeType = 2,
            rangeCenter = 1,
            acts = {
                {
                    targetType = 1,
                    conds = {
                    { cond = 22, value = 21, },
                    { cond = 62, value = 163, param = 42 },
                    },
                    results = {    },
                    specialEffects={
                    { type = 3, mj = 0, id = 10100, keepTime = 300, delay = 500, always = false },
                    },
                },
            },
            },
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
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 21, delay = 0, id = 21, vt = 1 },
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