local boss_dixuemozhu_wudihudun = 
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS =
                    {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 0.5},
                        -- },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                              {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = false},
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
                                    CLASS = "action.QSBSummonMonsters",
                                    OPTIONS = {wave = -1,attacker_level = true},
                                  },
                                  {
                                    CLASS = "action.QSBRemoveBuff",     
                                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                                  },
                                },
                              },
                              {
                                CLASS = "composite.QSBSequence",
                                ARGS = 
                                {
                                  {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20/24},
                                  },
                                  {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 40, duration = 0.25, count = 1,},
                                  },
                                },
                              },
                            }, 
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },    
                },
            },
        }
return boss_dixuemozhu_wudihudun