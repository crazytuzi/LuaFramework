local sspbosaixi_zd1_qx = 
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
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 13},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "sspbosaixi_attack13_1", is_hit_effect = false},
				},
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "sspbosaixi_attack13_2", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "sspbosaixi_attack13_3", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "sspbosaixi_attack13_4", is_hit_effect = false},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 1},
                -- },
                -- {
                --     CLASS = "action.QSBStopLoopEffect",
                --     OPTIONS = {effect_id = "sspbosaixi_attack13_4", is_hit_effect = false},
                -- },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
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
                                        {expression = "target:buff_num:sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:sspbosaixi_sj5_debuff1>0", select = 3},
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
                                        {expression = "target:buff_num:sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:sspbosaixi_sj5_debuff1>0", select = 3},
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
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.2,check_target_by_skill = true},
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 5},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.2,check_target_by_skill = true},
                                                },
                                            },
                                        },
                                       {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.4,check_target_by_skill = true},
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 5},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.4,check_target_by_skill = true},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.6,check_target_by_skill = true},
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 5},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {damage_scale = 0.6,check_target_by_skill = true},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0,check_target_by_skill = true},
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
}

return sspbosaixi_zd1_qx


