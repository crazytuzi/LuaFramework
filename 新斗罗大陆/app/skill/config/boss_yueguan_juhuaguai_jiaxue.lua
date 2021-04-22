-- 技能 月关召唤菊花怪临终加血
-- 技能ID 50420
-- 死前加血
--[[
	boss 月关的菊花怪
	ID:3318 副本7--4
	psf 2018-4-6
]]--

local boss_yueguan_juhuaguai_jiaxue = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "dead"}
                },

            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 35},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",--加血
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 15},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}

return boss_yueguan_juhuaguai_jiaxue

