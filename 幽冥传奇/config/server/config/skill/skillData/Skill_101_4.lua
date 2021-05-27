return {
{
	iconID = 82,
	desc = Lang.Skill.s101L4Desc,
	singTime = 0,
	cooldownTime = 50000,
	actions = {
            { act = 2, effect = 54, sound = 4, delay = 0, wait = 500 },
	},
	actRange = {
            {
            xStart  = -2,
            xEnd = -2,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                   targetType = 1,
                    conds = {    },
                    results = {    },
                    specialEffects={
                    { type = 4, mj = 0, id = 55, keepTime = 1000, delay = 300, always = true },
                    },
                },
            },
            },
            {
            xStart  = 2,
            xEnd = 2,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                   targetType = 1,
                    conds = {    },
                    results = {    },
                    specialEffects={
                    { type = 4, mj = 0, id = 55, keepTime = 1000, delay = 300, always = true },
                    },
                },
            },
            },
            {
            xStart  = 0,
            xEnd = 0,
            yStart = -2,
            yEnd = -2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                   targetType = 1,
                    conds = {    },
                    results = {    },
                    specialEffects={
                    { type = 4, mj = 0, id = 55, keepTime = 1000, delay = 300, always = true },
                    },
                },
            },
            },
            {
            xStart  = 0,
            xEnd = 0,
            yStart = 2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                   targetType = 1,
                    conds = {    },
                    results = {    },
                    specialEffects={
                    { type = 4, mj = 0, id = 55, keepTime = 1000, delay = 300, always = true },
                    },
                },
            },
            },
            {
            xStart  = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 5, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type =33, delay = 300, rate = 60000, intervalRate = 60000,value = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 101, value = 1, vt = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart  = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 6, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type =33, delay = 300, rate = 4750, intervalRate = 4750,value = 0 },
                    { mj = 0, timeParam = 200, type = 20, delay = 0, id = 101, value = 1, vt = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart  = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 5, value = 1, },
                    { cond = 20, value = 101, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 300, rate = 60000,intervalRate =  60000, value = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart  = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 6, value = 1, },
                    { cond = 20, value = 101, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 33, delay = 300, rate = 4750,intervalRate =  4750, value = 0 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart  = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    { cond = 11, value = 1500, },
                    { cond = 17, value = 117, param=91,buffid = -1,},
                    { cond = 19, value = 101, },
                    },
                    results = {
{ mj = 0, timeParam = 20, type = 1, id = 969, rate = -3400, rateType = 2, delay = 200 },
                    },
                    specialEffects={
                    },
                },
            },
            },
            {
            xStart  = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 0,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                   { mj = 0, timeParam = 1, type = 21, delay = 200, id = 101, value = 1, vt = 0 },
                    },
                    specialEffects={ },
                },
            },
            },
	},
	trainConds = {
            { cond = 21, value = 600, consume = false },
	},
	spellConds = {
            { cond = 13, value = 6, consume = false },
	},
},
}