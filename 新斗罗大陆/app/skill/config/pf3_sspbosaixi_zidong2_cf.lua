local sspbosaixi_zidong2_cf = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
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
                        failed_select = 2,
                        {expression = "self:is_pvp=true", select = 1},
                    }
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
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = 
                                    {
                                        failed_select = 4,
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj5_debuff1>0", select = 3},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.25},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.3},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.35},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0},
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
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = 
                                    {
                                        failed_select = 4,
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:pf3_sspbosaixi_sj5_debuff1>0", select = 3},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.2,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.4,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.6,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0,check_target_by_skill = true},
                                        },
                                        -- {
                                        --     CLASS = "action.QSBAttackFinish",
                                        -- },
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

return sspbosaixi_zidong2_cf


