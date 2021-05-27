return {
{
	iconID = 13,
	desc = Lang.Skill.s13L18Desc,
	singTime = 0,
	cooldownTime = 300,
	actions = {
            { act = 2, effect = 56, sound = 6, delay = 0, wait = 300 },
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
                    { type = 0, mj = 0, id = 10, keepTime = 1200, delay = 200, always = true },
                    },
                },
            },
            },
            {
            xStart = -2,
            xEnd = 2,
            yStart = -2,
            yEnd = 2,
            rangeType = 3,
            rangeCenter = 2,
            acts = {
                {
                    conds = {
                    { cond = 13, value = 1, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 4, delay = 500, rate = 16500, value = 0 },
                    },
                    specialEffects={    },
                },
            },
            },
	},
	trainConds = {
            { cond = 1, value = 35, consume = false },
            { cond = 43, value = 1, consume = false },
	},
	spellConds = {
            { cond = 8, value = 281, consume = true },
            { cond = 13, value = 6, consume = false },
	},
},
}