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
                            OPTIONS = {delay_time = 3},
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
                            OPTIONS = {delay_time = 3},
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
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "ssayin_mianyi"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "ssayin_dazhao_fumo3"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssayin_dazhao_fumo3"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 3 },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 13},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },                        
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="pf_ssayin02_skill"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 11},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin02_attack11_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin02_attack11_2", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 53},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin02_attack11_3", is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 55},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin02_attack11_4", is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = 
                            {
                                failed_select = 1,
                                {expression = "self:self_teammates_num=1", select = 1},
                                {expression = "self:self_teammates_num=2", select = 2},
                                {expression = "self:self_teammates_num=3", select = 3},
                                {expression = "self:self_teammates_num=4", select = 4},
                                {expression = "self:self_teammates_num>4", select = 4},                                                             
                            },
                        },
                        {
                            CLASS = "composite.QSBSelector",
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
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 0.5},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.25},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 2},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                    },
                                }, 
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
                                                    OPTIONS = {delay_time = 0.5},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.25},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 2},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        },
                                    },
                                }, 
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
                                                    OPTIONS = {delay_time = 0.5},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.1},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.7},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        },  
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 2.3},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                    },
                                }, 
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
                                                    OPTIONS = {delay_time = 0.5},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.1},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 1.7},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        },  
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 2.3},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 2.9},
                                                },
                                                {
                                                    CLASS = "action.QSBArgsSelectTarget", 
                                                    OPTIONS = 
                                                    { lowest_hp = true,is_teammate = true, include_self = true, just_hero = true},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {pass_key = {"selectTarget"}},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, pass_key = {"selectTarget"}},
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
                            OPTIONS = {delay_frame = 40},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf_ssayin02_dazhao_buff2_1",teammate_and_self = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf_ssayin02_dazhao_buff2_4",teammate_and_self = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf_ssayin02_dazhao_buff2_4_2",teammate_and_self = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf_ssayin02_dazhao_buff2_6",teammate = true},
                        },                         
                    },
                },                              
            },
        },
    },
}

return common_xiaoqiang_victory