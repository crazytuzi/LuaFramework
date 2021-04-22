-- 技能 鬼魅自动1 鬼魅魍魉
-- 技能ID 166
-- http://myst729.github.io/bezier-curve/
--[[
	hero 鬼魅
	ID:1017 
	psf 2019-3-26
]]--

local guimei_guimeiwangliang = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {revertable = true,},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "guimei_attack13_1"},
				},
				{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 35},
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
            },
        }, 
		{
			CLASS = "action.QSBAttackFinish",
		},		
    },
}

return guimei_guimeiwangliang

