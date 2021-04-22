
local ultra_yeshouxingtai = {           --火焰猫德变身
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRetainBuff",
            OPTIONS = {buff_id = "huomaobianshen_buff_2_heji"},
        },
        {
            CLASS = "action.QSBRetainBuff",
            OPTIONS = {buff_id = "huomaobianshen_buff_3_heji"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "shapeshifting_illidan_1_y"},         -- 变身音效
                        -- },
                        -- {
                        --     CLASS = "action.QSBRetainBuff",
                        --     OPTIONS = {buff_id = "huomaobianshen_buff_2"},
                        -- },
                        -- {
                        --     CLASS = "action.QSBRetainBuff",
                        --     OPTIONS = {buff_id = "huomaobianshen_buff_3"},
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
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack11"},
                                        },                                        
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS =
                                    {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "huomaobianshen_buff_1_heji"},
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 17},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 38},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish"
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = {
                --         {
                --             CLASS = "action.QSBShowActor",
                --             OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                --         },
                --         {
                --             CLASS = "action.QSBBulletTime",
                --             OPTIONS = {turn_on = true, revertable = true},
                --         },
                --         {
                --             CLASS = "action.QSBShowActorArena",
                --             OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                --         },
                --         {
                --             CLASS = "action.QSBBulletTimeArena",
                --             OPTIONS = {turn_on = true, revertable = true},
                --         },
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 1.8},
                --         },
                --         {
                --             CLASS = "action.QSBBulletTime",
                --             OPTIONS = {turn_on = false},
                --         },
                --         {
                --             CLASS = "action.QSBShowActor",
                --             OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                --         },
                --         {
                --             CLASS = "action.QSBBulletTimeArena",
                --             OPTIONS = {turn_on = false},
                --         },
                --         {
                --             CLASS = "action.QSBShowActorArena",
                --             OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                --         },
                --     },
                -- },
            },
        },
    },
}

return ultra_yeshouxingtai