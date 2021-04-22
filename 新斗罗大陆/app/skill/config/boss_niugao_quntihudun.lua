-- 技能 群体护盾
-- 群体加BUFF，因为动画没受击点，所以在这里手动写
--[[
	boss 牛皋
	ID:3305 副本3-12
	psf 2018-1-22
]]--

local shifa_tongyong = {

	CLASS = "composite.QSBParallel",
	ARGS = {
		{
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="niugao_skill"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack11_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },	
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 77},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 81},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
	},
}

return shifa_tongyong