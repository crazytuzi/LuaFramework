
local summon_2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        -- 上免疫控制buff
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_stun"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_fear"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_silence"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_knockback"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_time_stop"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_winding_of_cane"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_stun_charge"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_freeze"},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = 
            {
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.8},
	            },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -2},
	            },
                -- 清楚免疫控制buff
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_stun"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_fear"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_silence"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_knockback"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_time_stop"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_winding_of_cane"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_stun_charge"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "immunize_freeze"},
                        },
                    },
                },
            },
        },

    },
}

return summon_2