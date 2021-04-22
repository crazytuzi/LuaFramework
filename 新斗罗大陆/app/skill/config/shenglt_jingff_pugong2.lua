-- 技能 金刚狒狒远程普攻
-- 技能ID 53275
--[[
	金刚狒狒 4101
	升灵台
	psf 2020-4-13
]]--

local shenglt_jingff_pugong2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack03"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
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
                    OPTIONS = {is_hit_effect = false, haste = true},
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
                            CLASS = "action.QSBBullet",
                            OPTIONS = {start_pos = {x = 125,y = 85},},
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

return shenglt_jingff_pugong2