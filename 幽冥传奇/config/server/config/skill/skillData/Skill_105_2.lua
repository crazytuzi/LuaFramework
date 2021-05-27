return {
{
	iconID = 83,
	desc = Lang.Skill.s105L2Desc,
	singTime = 0,
	cooldownTime = 30000,
	actions = {
            { act = 2, effect = 0, sound = 7, delay = 0, wait = 300 },
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
                    results = {
                    },
                    specialEffects={
                    { type = 5, mj = 0, id = 21, keepTime = 0, delay = 0, always = false },
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
            rangeCenter = 1,
            acts = {
                {
                    conds = {
                    { cond = 1, value = 0, },
                    { cond = 2, value = 1, },
                    },
                    results = {
                    { timeParam = 1, type = 1, delay = 100, id = 1065, rate = 0, value = 0, },
                    { timeParam = 1, type = 1, delay = 100, id = 1085, rate = 0, value = 0, },
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
	},
},
}