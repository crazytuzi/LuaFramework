
local guerdan_juexing_1 = {              -- 古尔丹附魔技能触发伤害技能
	CLASS = "composite.QSBParallel",
    ARGS = {
        {                                    -- 施法特效
            CLASS = "composite.QSBSequence",
            ARGS = {

				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_siwang_3", is_target_effect = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return guerdan_juexing_1