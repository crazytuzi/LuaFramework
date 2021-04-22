
local aegwynn_pugong_fumo = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "igw_pugong_2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "igw_pugong_2", speed = 1750, hit_effect_id = "igw_pugong_3", jump_info = {jump_number = 1}, rail_number = 3, rail_inter_frame = 1},
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 1},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "igw_pugong_2"},
        --         },
        --     },
        -- },




    },
}

return aegwynn_pugong_fumo