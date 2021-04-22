-- 技能 牛天真技失传补救
-- 技能ID 190310
-- 判断场上还有没有青龙守护
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_sstianqingniumang01_zhenji_trigger2_2 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 3,
                {expression = "self:has_buff:pf_sstianqingniumang01_zhenji_niutian_buff_3", select = 2},
                {expression = "self:has_buff:pf_sstianqingniumang01_zhenji_niutian_buff_2", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsNumber",
                            OPTIONS = {teammate_and_self = true, buff_stacks = true, stub_buff_id = "pf_sstianqingniumang01_zhenji_buff_2"},
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
                                            OPTIONS = {skill_id = 290311, wait_finish = false},
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
                        {
                            CLASS = "action.QSBArgsNumber",
                            OPTIONS = {teammate_and_self = true, buff_stacks = true, stub_buff_id = "pf_sstianqingniumang01_zhenji_buff_3"},
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
                                            OPTIONS = {skill_id = 290311, wait_finish = false},
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

return pf_sstianqingniumang01_zhenji_trigger2_2