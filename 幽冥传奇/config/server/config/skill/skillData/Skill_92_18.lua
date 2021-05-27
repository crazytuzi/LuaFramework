return {
{
	iconID = 11,
	desc = Lang.Skill.s92L18Desc,
	singTime = 0,
	cooldownTime = 0,
	actions = {
            { act = 2, effect = 1, sound = 5, delay = 0, wait = 500 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
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
                    { type = 4, mj = 0, id = 2, keepTime = 800, delay = 100, always = true },
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
            rangeCenter = 2,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, delay = 300, timeParam = 1, type = 4, rate = 17500, value = 0 },
                    { mj = 0, timeParam = 1, type = 1, id = 316, rate = 0, rateType = 2, delay = 200 },
                    { mj = 0, timeParam = 1, type = 1, id = 336, rate = 0, rateType = 2, delay = 200 },
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