
local pf_bosaixi_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = },
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "new_yangwudi_atk12_1", is_hit_effect = false},
                },
            },
        },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "new_yangwudi_atk12_1", is_hit_effect = false},
        -- },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    OPTIONS = {delay_frame = 31},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 0,y = 130}, effect_id = "new_yangwudi_atk11_2", speed = 2000, hit_effect_id = "typg_3"},
                },
            },
        },
    },
}

return pf_bosaixi_pugong1

