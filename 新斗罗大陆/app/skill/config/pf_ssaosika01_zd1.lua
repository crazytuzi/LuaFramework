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
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0/ 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika01_attack12_1"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true, except_attacker = true,effect_id = "pf_ssaosika01_attack12_3"},
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
                            OPTIONS = {delay_time = 42/ 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika01_attack12_2"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true,effect_id = "pf_ssaosika01_attack12_4"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true, effect_id = "pf_ssaosika01_attack01_3"},
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
                                                {expression = "self:has_buff:pf_ssaosika01_bd2&target:has_buff:pf_ssaosika01_bd2_debuff=false&(target:hp/target:max_hp<0.35)", select = 1}
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSelector",
                                            ARGS = {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBApplyBuff",
                                                            OPTIONS = {is_target = true, buff_id = "pf_ssaosika01_bd2_buff"}
                                                        },
                                                        {
                                                            CLASS = "action.QSBApplyBuff",
                                                            OPTIONS = {is_target = true, buff_id = "pf_ssaosika01_bd2_debuff"}
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                                -- {
                                --     CLASS = "action.QSBApplyBuff",
                                --     OPTIONS = {is_target = true, buff_id = "ssaosika_zd1_buff1"},
                                -- },
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