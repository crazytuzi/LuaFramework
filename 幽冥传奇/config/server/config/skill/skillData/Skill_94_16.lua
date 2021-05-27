return {
{
	iconID = 13,
	desc = Lang.Skill.s94L16Desc,
	singTime = 0,
	cooldownTime = 0,
	actions = {
            { act = 2, effect = 0, sound = 6, delay = 0, wait = 500 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 3,
            rangeCenter = 2,
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
                    { mj = 0, timeParam = 1, type = 4, delay = 100, rate = 15500, value = 0 },
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