-- 技能 金发狮獒AOE
-- 技能ID 53305
--[[
	金发狮獒 4117
	升灵台
	psf 2020-4-13
]]--

local shenglt_jinfsa_dazhao2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack11_3"},
		},
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "shenglt_jinfashiao_attack11_1_3", is_hit_effect = false, haste = true},
        },  
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
				{
                    CLASS = "action.QSBHitTarget",
                },  
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 39},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                }, 
            },
        },
    },
}

return shenglt_jinfsa_dazhao2