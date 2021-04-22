-- 技能 唐昊神技判断
-- 技能ID 39124~9
-- 判断目标血量决定是否位面失衡
-- 若目标被位面锁定,则不会移除位面失衡
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_shenji_trigger_2 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssptanghao_shenji_debuff1_2", is_target = true},
                },
                {
                    CLASS = "action.QSBDecreaseAbsorbByProp",
                    OPTIONS = {max_hp_percent  = 1,attacker_current_hp_percent_limit = 0.14},
                }, 
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                        { "target:is_pvp==false","target:decrease_hp:self:hp*11.2"},
                        -- { "target:is_pvp==false","target:decrease_hp:self:maxAttack*24"},
                        { "target:is_pvp==true","target:decrease_hp:self:hp*0.14"},
                    }
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = {
                                failed_select = -1,
                                {expression = "self:has_buff:anqi_baihubi_xixue_1_1", select = 1},
                                {expression = "self:has_buff:anqi_baihubi_xixue_1_2", select = 2},
                                {expression = "self:has_buff:anqi_baihubi_xixue_1_3", select = 3},
                                {expression = "self:has_buff:anqi_baihubi_xixue_1_4", select = 4},
                                {expression = "self:has_buff:anqi_baihubi_xixue_1_5", select = 5},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {
                        
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_baihubi_buff_huixue1",is_target = false },
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_baihubi_buff_huixue2",is_target = false },
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_baihubi_buff_huixue3",is_target = false },
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_baihubi_buff_huixue4",is_target = false },
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_baihubi_buff_huixue5",is_target = false },
                                },

                            },
                        }, 
                    },
                },
            },
        },  
         
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2,
                {expression = "target:is_actor_dead", select = 3},
                {expression = "self:max_hp*0.25>target:hp", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayGodSkillAnimation",
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf3_ssptanghao_shenji_debuff_2", is_target = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "pf3_ssptanghao_shenji_buff", is_target = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attackee = true, status = "ssptanghao_lock",reverse_result = true},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "pf3_ssptanghao_shenji_debuff_2", is_target = true},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "pf3_ssptanghao_shenji_buff", is_target = false},
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

return ssptanghao_shenji_trigger_2


