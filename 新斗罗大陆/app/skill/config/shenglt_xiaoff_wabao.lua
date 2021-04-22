-- 技能 小狒狒挖宝
-- 技能ID 53280
--[[
	小狒狒 4102
	升灵台
	psf 2020-4-13
]]--

local shenglt_jingff_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_1"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return shenglt_jingff_dazhao