local boss_bosaixi_leiji = 
{   
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBDelayTime",
        --     OPTIONS = {delay_frame = 64},
        -- },
        -- {
        --     CLASS = "action.QSBHitTarget",
        -- },
        -- {
        --     CLASS = "action.QSBAttackFinish"
        -- },
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
                          OPTIONS = {delay_time = 0.75},
                        }, 
                        {
                          CLASS = "action.QSBTrap",  
                          OPTIONS = 
                          { 
                              trapId = "jiguan_gandianxianjing",
                              args = 
                              {
                                  {delay_time = 23 / 24 , pos = { x = 430, y = 150}} ,
                                  {delay_time = 23 / 24 , pos = { x = 1100, y = 325}} ,
                                  -- {delay_time = 25 / 24 , pos = { x = 850, y = 600}} ,
                                  {delay_time = 27 / 24 , pos = { x = 340, y = 350}} ,
                                  -- {delay_time = 29 / 24 , pos = { x = 150, y = 550}} ,
                                  {delay_time = 29 / 24 , pos = { x = 1300, y = 400}} ,
                                  {delay_time = 29 / 24 , pos = { x = 700, y = 185}},
                                  {delay_time = 35 / 24 , pos = { x = 200, y = 352}} ,
                                  -- {delay_time = 35 / 24 , pos = { x = 500, y = 555}},
                                  {delay_time = 35 / 24 , pos = { x = 1120, y = 477}} ,
                                  {delay_time = 37 / 24 , pos = { x = 640, y = 235}} ,
                                  {delay_time = 39 / 24 , pos = { x = 100, y = 446.8}} ,
                                  -- {delay_time = 41 / 24 , pos = { x = 370, y = 246}} ,
                                  {delay_time = 41 / 24 , pos = { x = 1250, y = 100}} ,
                                  {delay_time = 41 / 24 , pos = { x = 580, y = 290}} ,
                                  {delay_time = 43 / 24 , pos = { x = 770, y = 335.4}},
                                  {delay_time = 47 / 24 , pos = { x = 420, y = 500}} ,
                                  {delay_time = 47 / 24 , pos = { x = 950, y = 355}},
                                  {delay_time = 47 / 24 , pos = { x = 700, y = 460}},
                                  {delay_time = 47 / 24 , pos = { x = 540, y = 292}} ,
                             },
                          },
                       },
                   },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 41 /24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 5, duration = 7 / 24, count = 5,},
                        },
                    },
                },
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "jiguan_gandian", pos = {x = 680, y = 360}, ground_layer = true},
                -- },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="jiguan_gandian"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_bosaixi_leiji