
local boss_dugubo_shihuaningshi = {
    CLASS = "composite.QSBParallel",
	OPTIONS = {revertable = true},
    ARGS = {
		-- 上免疫控制buff
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
                {
                    CLASS = "composite.QSBParallel",
                    OPTIONS = {revertable = true},
                    ARGS = {
        				{
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 6},
                                -- },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "dugubo_attack11_1", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 6},
                                -- },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "dugubo_attack11_1_1", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 70},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return boss_dugubo_shihuaningshi

