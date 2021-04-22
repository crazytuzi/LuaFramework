-- 技能 ss剑道尘心高级皮肤自动1
-- 技能ID 576
-- 打一下
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
    螺笛 2020-5-13
]]--

local sschenxin_zidong1 = 
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
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:is_pvp=true", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsSelectTarget",
                            OPTIONS = {highest_attack = true,prior_role = "dps",default_select = true,
                            not_copy_hero = true, change_all_node_target = true},
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
                    OPTIONS = {delay_frame = 44},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_sschenxin01_attack13_1", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_sschenxin01_attack13_2", speed = 1500, hit_effect_id = "pf_sschenxin01_attack01_3"},
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

return sschenxin_zidong1

