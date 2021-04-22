local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.6},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = false},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 75 /30},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                }, 
                {                           --竞技场黑屏
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 75 / 30},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 2 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11"},
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 15},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="ssaosika_skill"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 7},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            { 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_1"},
                                                }, 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_5"},
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
                                            OPTIONS = {delay_frame = 50},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_4"},
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
                                            OPTIONS = {delay_time = 60/ 30 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_2"},
                                                },
                                                {
                                                  CLASS = "action.QSBHitTarget",
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBArgsConditionSelector",
                                                            OPTIONS = 
                                                            {
                                                                failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
                                                                {expression = "self:has_buff:pf_ssaosika02_bd2&target:has_buff:pf_ssaosika02_bd2_debuff=false&(target:hp/target:max_hp<0.35)", select = 1}
                                                            },
                                                        },
                                                        {
                                                            CLASS = "composite.QSBSelector",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBApplyBuff",
                                                                            OPTIONS = {is_target = true, buff_id = "pf_ssaosika02_bd2_buff"}
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBApplyBuff",
                                                                            OPTIONS = {is_target = true, buff_id = "pf_ssaosika02_bd2_debuff"}
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    },
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
                                            OPTIONS = {delay_time = 90/ 30 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_2"},
                                                },
                                                {
                                                  CLASS = "action.QSBHitTarget",
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
                                            OPTIONS = {delay_time = 120/ 30 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_2"},
                                                },
                                                {
                                                  CLASS = "action.QSBHitTarget",
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
                                            OPTIONS = {delay_time = 150/ 30 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika02_attack11_2"},
                                                },
                                                {
                                                  CLASS = "action.QSBHitTarget",
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        {
          CLASS = "action.QSBAttackFinish",
        },
    },
}

return common_xiaoqiang_victory