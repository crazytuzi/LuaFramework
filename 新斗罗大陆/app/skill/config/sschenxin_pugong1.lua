-- 技能 ss剑道尘心普攻
-- 技能ID 572
-- 顾名思义 物理
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--


local function SSCHENXIN_PUGONG_FINISH(_buff)
    local apply_buff = {
        CLASS = "action.QSBApplyBuff",
        OPTIONS = {is_target = true, buff_id = _buff},
    }
    local clear_count = {
        CLASS = "action.QSBRemoveBuffByStatus",
        OPTIONS = {status = "sschenxin_count"},
    }
    local sschenxin_pugong_finish = {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBRemoveBuffByStatus",
                OPTIONS = {status = "sschenxin_sj1"},--sschenxin_shenji_buff1~5
            },
            {
                CLASS = "action.QSBRemoveBuffByStatus",
                OPTIONS = {status = "sschenxin_sj2"},--sschenxin_shenji_qianghua_buff1~5
            },
            {
                CLASS = "action.QSBRemoveBuff",
                OPTIONS = {is_attacker = true, buff_id = "sschenxin_pugong_buff"},
            },
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 1,
                    {expression = "self:buff_num:sschenxin_shenji_count_5=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_5>5", select = 6},
                    {expression = "self:buff_num:sschenxin_shenji_count_2=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_2=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_2=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_2=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_2=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_2>5", select = 6},
                    {expression = "self:buff_num:sschenxin_shenji_count_3=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_3=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_3=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_3=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_3=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_3>5", select = 6},
                    {expression = "self:buff_num:sschenxin_shenji_count_4=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_4=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_4=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_4=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_4=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_4>5", select = 6},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_1>5", select = 6},
                }
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {
                    apply_buff,
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            clear_count,apply_buff,apply_buff,
                        },
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            clear_count,apply_buff,apply_buff,apply_buff,
                        },
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            clear_count,apply_buff,apply_buff,apply_buff,apply_buff,
                        },
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            clear_count,apply_buff,apply_buff,apply_buff,apply_buff,apply_buff,
                        },
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            clear_count,apply_buff,apply_buff,apply_buff,apply_buff,apply_buff,apply_buff,
                        },
                    },
                },
            },
        },
    }
    return sschenxin_pugong_finish
end




local ssmahongjun_pugong1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_attacker = true, buff_id = "sschenxin_pugong_buff"},
        },
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2,
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff1", select = 1},
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff2", select = 1},
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff3", select = 1},
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff4", select = 1},
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff5", select = 1},
                {expression = "self:has_buff:sschenxin_shenji_qianghua_buff6", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                --神技普攻
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack02"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 42},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "sschenxin_attack02_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 23},
                                },
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 1,
                                        {expression = "self:has_buff:sschenxin_shenji_buff_5", select = 5},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_4", select = 4},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_3", select = 3},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_2", select = 2},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_shenji_qianghua_buff_1"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {all_enemy = true, buff_id = "sschenxin_shenji_qianghua_debuff_1"},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayGodSkillAnimation",
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_shenji_qianghua_buff_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {all_enemy = true, buff_id = "sschenxin_shenji_qianghua_debuff_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBTriggerSkill",
                                                    OPTIONS = {skill_id = 39085, wait_finish = false},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayGodSkillAnimation",
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_shenji_qianghua_buff_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {all_enemy = true, buff_id = "sschenxin_shenji_qianghua_debuff_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBTriggerSkill",
                                                    OPTIONS = {skill_id = 39086, wait_finish = false},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayGodSkillAnimation",
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_shenji_qianghua_buff_4"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {all_enemy = true, buff_id = "sschenxin_shenji_qianghua_debuff_4"},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBTriggerSkill",
                                                    OPTIONS = {skill_id = 39087, wait_finish = false},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayGodSkillAnimation",
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_shenji_qianghua_buff_5"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {all_enemy = true, buff_id = "sschenxin_shenji_qianghua_debuff_5"},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBTriggerSkill",
                                                    OPTIONS = {skill_id = 39088, wait_finish = false},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayGodSkillAnimation",
                                                },
                                            },
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBRemoveBuffByStatus",
                                    OPTIONS = {status = "sschenxin_sj1"},--sschenxin_shenji_buff1~5
                                },
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 1,
                                        {expression = "self:has_buff:sschenxin_shenji_buff_5", select = 5},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_4", select = 4},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_3", select = 3},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_2", select = 2},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_1"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_2"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_3"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_4"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_5"),
                                    },
                                },
                            },
                        },
                    },
                },
                --普攻
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 32},
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
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "sschenxin_attack01_1", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 12},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuffByStatus",
                                    OPTIONS = {status = "sschenxin_sj1"},--sschenxin_shenji_buff1~5
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "sschenxin_attack01_2", speed = 1500, hit_effect_id = "sschenxin_attack01_3_1"},
                                },
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 1,
                                        {expression = "self:has_buff:sschenxin_shenji_buff_5", select = 5},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_4", select = 4},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_3", select = 3},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_2", select = 2},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_1"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_2"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_3"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_4"),
                                        SSCHENXIN_PUGONG_FINISH("sschenxin_shenji_debuff_5"),
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

return ssmahongjun_pugong1

