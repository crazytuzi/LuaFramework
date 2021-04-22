
local renmianmozhu_zibao_buff = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 37 / 24  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {   
                        --      {
                        --         CLASS = "composite.QSBSequence",
                        --         ARGS = {
                        --             {
                        --                 CLASS = "action.QSBArgsConditionSelector",
                        --                 OPTIONS = 
                        --                 {
                        --                     failed_select = 1,
                        --                     {expression = "target:duyezhizhu_fushidebuff=1", select = 2},

                        --                 },
                        --              },
                        --          },
                        --      },
                        -- {
                        --     CLASS = "composite.QSBSelector",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBHitTarget",                                                                                    
                        --         },
                        --         {
                        --             CLASS = "action.QSBHitTarget",
                        --             OPTIONS = {property_promotion = {magic_damage_percent_beattack = 1}},
                        --         },
                        --     },
                        -- },


                            {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = { all_teammates = true, buff_id = "zibaozhizhu_shanghai"},                                
                            },
                            {
                                    CLASS = "action.QSBHitTarget",
                            },

                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "renmianmozhu3_dead_3" , is_hit_effect = false },
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
                            OPTIONS = {delay_time = 37 / 24  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --   CLASS = "action.QSBPlayEffect",
                                --   OPTIONS = {is_hit_effect = false,effect_id = "zdb_atk11_3"},
                                -- },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = { skill_id = 950849  ,wait_finish = false},
                                },
                                -- {
                                --     CLASS = "action.QSBHitTarget",
                                -- },
                            },
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return renmianmozhu_zibao_buff 