
local pf_cnxiaowu03_zidong2 = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_chengnianxiaowu03_attack14_1", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 2},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 0},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "pf_chengnianxiaowu03_attack14_1", is_hit_effect = false, haste = true},
        --         },
        --     },
        -- },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_chengnianxiaowu03_attack14_2", speed = 1200, hit_effect_id = "pf_chengnianxiaowu03_attack14_3"},
                },
            },
		},
    },
}

return pf_cnxiaowu03_zidong2