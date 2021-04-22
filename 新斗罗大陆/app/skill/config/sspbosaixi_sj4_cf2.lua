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
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj4_debuff1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj4_debuff2"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
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
                                failed_select = 2,
                                {expression = "self:is_pvp=true", select = 1},
                            },
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                    OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.2},
                                },
                                {
                                    CLASS = "action.QSBDecreaseHpByTargetProp", --造成自身攻击力30%伤害
                                    OPTIONS = {attack_percent = 6},
                                },
                            },
                        },
                    },
                },                                                       
            },
        },
    },
}

return common_xiaoqiang_victory