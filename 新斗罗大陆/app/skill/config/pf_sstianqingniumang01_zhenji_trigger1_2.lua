-- 技能 牛天真技传承OR初始化
-- 技能ID 190307~190309
-- 如果牛天仍在场，给血量最少的其他队友BUFF，没队友了触发一次失传技
--[[
    魂师 牛天
    ID:1052
    psf 2020-2-12
]]--

local pf_sstianqingniumang01_zhenji_trigger1_2 = {
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
                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_init_buff_2"},
                        },
                        {
                            CLASS = "action.QSBTianQingNiuMangJianShang",
                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_buff_2",start_percent = 0.2,reduction_percent = 0.35,end_percent = 2}
                        },
                        {
                            CLASS = "action.QSBTianQingNiuMangJianShang",
                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_buff_2_temp",start_percent = 0.2,reduction_percent = 0.35,end_percent = 2}
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
                                                    OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_buff_2"},
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {lowest_hp_teammate = true, just_hero = true, buff_id = {"pf_sstianqingniumang01_zhenji_start_buff","pf_sstianqingniumang01_zhenji_buff_2","pf_sstianqingniumang01_zhenji_init_buff_2"}},
                                                },
                                            },
                                        },
                                        --BUFF没加上（无其他队友）时，触发失传技
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

return pf_sstianqingniumang01_zhenji_trigger1_2