return {
{
	iconID = 13,
	desc = Lang.Skill.s13L1Desc,
	singTime = 0,
	cooldownTime = 1000,
	actions = {
            { act = 2, effect = 0, sound = 6, delay = 0, wait = 800 },
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
                    { type = 4, mj = 0, id = 10, keepTime = 1000, delay = 100, always = true },
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
            rangeCenter = 2,
            acts = {
                {
                    conds = {
                    { cond = 31, value = 0, },
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 4, delay = 100, rate = 7000, value = 0 },
                    },
                    specialEffects={
					},
                },
            },
            },
	},
	trainConds = {
	},
	spellConds = {
            { cond = 13, value = 6, consume = false },
	},
},
}