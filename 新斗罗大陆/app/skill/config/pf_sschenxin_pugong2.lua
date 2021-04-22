-- 技能 ss剑道尘心高级皮肤神技强化普攻
-- 技能ID 39089
-- 根据飞剑数量有不同效果
--[[
	魂师 剑道尘心
	ID:1056
        psf 2020-4-21
	螺笛 2020-4-21
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
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 1,
                    {expression = "self:buff_num:sschenxin_shenji_count_5=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_5=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_5>5", select = 6},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=1", select = 1},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=2", select = 2},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=3", select = 3},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=4", select = 4},
                    {expression = "self:buff_num:sschenxin_shenji_count_1=5", select = 5},
                    {expression = "self:buff_num:sschenxin_shenji_count_1>5", select = 6},
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



local sschenxin_pugong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBPlayAnimation",
        --     OPTIONS = {animation = "attack02"},
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 42},
        --         },
        --         {
        --             CLASS = "action.QSBAttackFinish",
        --         },
        --     },
        -- },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_sschenxin01_attack02_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {highest_attack = true,prior_role = "dps",not_copy_hero = true, change_all_node_target = true},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 1,
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_5", select = 5},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_4", select = 4},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_3", select = 3},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_2", select = 2},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {highest_attack_enemy = true,prior_role = "dps",
                                    buff_id = "sschenxin_select_enemy_debuff"},
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy"}
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 125,y = 250}, effect_id = "pf_sschenxin01_attack01_2", speed = 1500, hit_effect_id = "pf_sschenxin01_attack01_2"},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {highest_attack_enemy = true,prior_role = "dps",
                                    buff_id = "sschenxin_select_enemy_debuff"},
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy"}
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 139085, wait_finish = false},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {highest_attack_enemy = true,prior_role = "dps",
                                    buff_id = "sschenxin_select_enemy_debuff"},
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy"}
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 139086, wait_finish = false},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {highest_attack_enemy = true,prior_role = "dps",
                                    buff_id = "sschenxin_select_enemy_debuff"},
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy"}
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 139087, wait_finish = false},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {highest_attack_enemy = true,prior_role = "dps",
                                    buff_id = "sschenxin_select_enemy_debuff"},
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy"}
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 139088, wait_finish = false},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 10},
                -- },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 1,
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_5", select = 5},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_4", select = 4},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_3", select = 3},
                        {expression = "self:has_buff:pf_sschenxin_shenji_buff_2", select = 2},
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
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}


return sschenxin_pugong2