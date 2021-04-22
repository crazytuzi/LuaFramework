-- 技能 金发狮獒连击
-- 技能ID 53304
--[[
	金发狮獒 4117
	升灵台
	psf 2020-4-13
]]--



local shenglt_jinfsa_dazhao1 = {
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
                    OPTIONS = {delay_frame = 11},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "shenglt_jinfashiao_attack11_1_1", is_hit_effect = false, haste = true},
				},  
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
				{
                    CLASS = "composite.QSBParallel",
                    ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "shenglt_jinfashiao_attack01_1_1", is_hit_effect = false, haste = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
                    },
                },  
            },
        },
		{
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 27},
						},
						{
                            CLASS = "composite.QSBParallel",
                            ARGS = {		
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11_2"},
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "shenglt_jinfashiao_attack11_1_2" ,is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 6},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 6},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 6},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 6},
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
							CLASS = "action.QSBLockTarget",
							OPTIONS = { is_lock_target = false}
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
            },
        },
    },
}

return shenglt_jinfsa_dazhao1