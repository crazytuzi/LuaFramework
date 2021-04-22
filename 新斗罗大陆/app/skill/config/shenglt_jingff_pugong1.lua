-- 技能 金刚狒狒近战普攻
-- 技能ID 53274
--[[
	金刚狒狒 4101
	升灵台
	psf 2020-4-13
]]--

local shenglt_jingff_pugong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "jingangfeifei_attack01_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
            },
        },
    },
}

return shenglt_jingff_pugong1