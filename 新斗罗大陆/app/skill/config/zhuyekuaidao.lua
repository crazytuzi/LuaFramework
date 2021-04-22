
local zhuyekuaidao = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.75},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_tornado = true, speed = 350, tornado_size = {width = 200, height =130}, start_pos = {x = 0, y = 65, is_animation = false}},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                    -- {
        --                 CLASS = "action.QSBPlayLoopEffect",
        --                 OPTIONS = { effect_id = "boss_baihehongkuang_2"},
                    -- },
                 --    {
        --                 CLASS = "action.QSBDelayTime",
        --                 OPTIONS = {delay_time = 2},
        --             },
                    -- {
        --                 CLASS = "action.QSBStopLoopEffect",
        --                 OPTIONS = { effect_id = "boss_baihehongkuang_2"},
        --             },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "boss_liuerlong_huoyanbo_hongkuang", is_target = false},
                },
            },
        },
    },
}

return zhuyekuaidao