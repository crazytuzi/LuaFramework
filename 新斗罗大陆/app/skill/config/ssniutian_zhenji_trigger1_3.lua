-- 技能 牛天真技传承OR初始化
-- 技能ID 190307~190309
-- 如果牛天仍在场，给血量最少的其他队友BUFF，没队友了触发一次失传技
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_zhenji_trigger1_3 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "ssniutian_zhenji_init"}
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                --初始化BUFF
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "ssniutian_zhenji_init_buff_2"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "ssniutian_zhenji_init_buff_3"},
                        },
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = {
                                failed_select = 2,
                                {expression = "self:has_buff:ssniutian_zhenji_niutian_buff_2", select = 1},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "ssniutian_zhenji_niutian_buff_2"},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "ssniutian_zhenji_buff_2"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "ssniutian_zhenji_niutian_buff_3"}
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "ssniutian_zhenji_buff_3"}
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTianQingNiuMangJianShang",
                            OPTIONS = {buff_id = "ssniutian_zhenji_buff_3",start_percent = 0.2,reduction_percent = 0.2,end_percent = 2.8}
                        },
                    },
                },
                --BUFF结束效果
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsHasActor",
                            OPTIONS = {actor_id = 1052,teammate = true,includeSelf = true}
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBRemoveBuff",
                                                    OPTIONS = {buff_id = "ssniutian_zhenji_buff_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBRemoveBuff",
                                                    OPTIONS = {buff_id = "ssniutian_zhenji_buff_3"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {lowest_hp_teammate = true, just_hero = true, buff_id = {"ssniutian_zhenji_start_buff","ssniutian_zhenji_buff_3","ssniutian_zhenji_init_buff_3"}},
                                                },
                                            },
                                        },
                                        --BUFF没加上（无其他队友）时，触发失传技
                                        {
                                            CLASS = "action.QSBArgsNumber",
                                            OPTIONS = {teammate_and_self = true, buff_stacks = true, stub_buff_id = "ssniutian_zhenji_buff_3"},
                                        },
                                        {
                                            CLASS = "composite.QSBSelectorByNumber",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    OPTIONS = {flag = 0},
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBTriggerSkill",	
                                                            OPTIONS = {skill_id = 190311, wait_finish = false},
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
                },
            },
        }, 
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssniutian_zhenji_trigger1_3