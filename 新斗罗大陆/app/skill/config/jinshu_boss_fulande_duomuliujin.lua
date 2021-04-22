
local boss_fulande_duomuliujin = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_tornado = true, sort_layer_with_actor = true, tornado_size = {width = 700, height =120}, start_pos = {x = 0, y = 0, is_animation = false}},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 1},
        --         },
        --         {
        --             CLASS = "action.QSBBullet",
        --             OPTIONS = {is_tornado = true, tornado_size = {width = 700, height =150}, start_pos = {x = 0, y = 30, is_animation = false}},
        --         },
        --     },
        -- },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_fulande_duomuliujin_hongkuang", is_target = false},
        },
    },
}

return boss_fulande_duomuliujin