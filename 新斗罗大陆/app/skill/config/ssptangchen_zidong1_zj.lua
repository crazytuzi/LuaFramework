
local pf_cnxiaowu_zidong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 19},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_attack12_1", is_hit_effect = false}, --自动1施法
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 19 },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"ssptangchen_zidong1_zj_treat"}, is_target = false},--真技额外回血Buff
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 1,
                        {expression = "self:buff_num:ssptangchen_sj1_jt1=1", select = 2},
                        {expression = "self:buff_num:ssptangchen_sj2_jt1=1", select = 3},
                        {expression = "self:buff_num:ssptangchen_sj3_jt1=1", select = 4},
                        {expression = "self:buff_num:ssptangchen_sj4_jt1=1", select = 5},
                        {expression = "self:buff_num:ssptangchen_sj5_jt1=1", select = 6},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj0_xueyin"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj1_xueyin"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj2_xueyin"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj3_xueyin"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj4_xueyin"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "ssptangchen_sj5_xueyin"},
                        },                        
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 1,
                        {expression = "self:buff_num:ssptangchen_sj0_jt1=1", select = 1},
                        {expression = "self:buff_num:ssptangchen_sj1_jt1=1", select = 2},
                        {expression = "self:buff_num:ssptangchen_sj2_jt1=1", select = 3},
                        {expression = "self:buff_num:ssptangchen_sj3_jt1=1", select = 4},
                        {expression = "self:buff_num:ssptangchen_sj4_jt1=1", select = 5},
                        {expression = "self:buff_num:ssptangchen_sj5_jt1=1", select = 6},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.1,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.2,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.3,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.4,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.5,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.6,check_target_by_skill = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 23},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "ssptangchen_zidong1_zj_treat", is_target = false},--真技额外回血Buff移除
                },
            },
        },
    },
}

return pf_cnxiaowu_zidong1