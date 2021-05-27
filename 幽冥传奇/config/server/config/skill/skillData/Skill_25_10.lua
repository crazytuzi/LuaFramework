return {
{
	iconID = 25,
	desc = Lang.Skill.s25L10Desc,
	singTime = 0,
	cooldownTime = 30000,
	actions = {
            { act = 2, effect = 60, sound = 19, delay = 0, wait = 300 },
	},
	actRange = {
            {
            xStart = 0,
            xEnd = 0,
            yStart = 0,
            yEnd = 0,
            rangeType = 0,
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 3, value = 1, },
                    },
                    results = {
                    { timeParam = 1, type = 1, delay = 100, id = 588, rate = 0, value = 0, },
                    },
                    specialEffects={
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
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    { cond = 6, value = 1, },
                    },
                    results = {
                    { timeParam = 1, type = 1, delay = 100, id = 548, rate = 0, value = 0, },
                    { timeParam = 1, type = 1, delay = 100, id = 568, rate = 0, value = 0, },
                    },
                    specialEffects={    },
                },
            },
            },
	},
	trainConds = {
            { cond = 1, value = 72, consume = false },
            { cond = 43, value = 1, consume = false },
	},
	spellConds = {
            { cond = 8, value = 2100, consume = true },
	},
},
}