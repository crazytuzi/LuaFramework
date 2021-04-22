-- 技能 ss剑道尘心自动2
-- 技能ID 578
-- 召陷阱强化
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local sschenxin_pugong1 = 
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
                    OPTIONS = {delay_frame = 76},
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
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:is_pvp=true", select = 1},
                    }
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {highest_attack = true,prior_role = "dps",default_select = true,
                    not_copy_hero = true, change_all_node_target = true},
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "sschenxin_attack14_1", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 63},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "sschenxin_attack14_3", is_hit_effect = false},
                },
                {
					CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_zidong2_plus_buff", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {multiple_target_with_skill = true, sector_target = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {tt =1,buff_id = {"sschenxin_zidong2_plus_guanghuan_buff","sschenxin_zidong2_plus_guanghuan_debuff"}},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_zhenji7_buff", select = 1},
                        {expression = "self:random<0.66", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 6,
                                        {expression = "self:has_buff:sschenxin_shenji_buff_1", select = 1},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_2", select = 2},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_3", select = 3},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_4", select = 4},
                                        {expression = "self:has_buff:sschenxin_shenji_buff_5", select = 5},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBTriggerSkill",
                                            OPTIONS = {skill_id = 39090, wait_finish = false},
                                        },
                                        {
                                            CLASS = "action.QSBTriggerSkill",
                                            OPTIONS = {skill_id = 39091, wait_finish = false},
                                        },
                                        {
                                            CLASS = "action.QSBTriggerSkill",
                                            OPTIONS = {skill_id = 39092, wait_finish = false},
                                        },
                                        {
                                            CLASS = "action.QSBTriggerSkill",
                                            OPTIONS = {skill_id = 39093, wait_finish = false},
                                        },
                                        {
                                            CLASS = "action.QSBTriggerSkill",
                                            OPTIONS = {skill_id = 39094, wait_finish = false},
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

return sschenxin_pugong1

