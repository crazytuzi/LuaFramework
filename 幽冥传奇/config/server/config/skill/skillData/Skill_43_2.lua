return {
{
	iconID = 21,
	desc = Lang.Skill.s21L1Desc,
	singTime = 0,
	cooldownTime = 1000,
	actions = {
            { act = 1, effect = 0, sound = 8, delay = 0, wait = 800 },
	},
	actRange = {
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
                    },
                    results = {
                    { mj = 0, timeParam = 1, type = 4, delay = 200, rate = 10000, value = 0 },
                    },
                    specialEffects={
                    { type = 3, mj = 0, id = 10050, keepTime = 300, delay = 0, always = false },
                    { type = 4, mj = 0, id = 7, keepTime = 500, delay = 200, always = false },
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