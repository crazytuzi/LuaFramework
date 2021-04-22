-- 技能 牛天真技传承OR初始化
-- 技能ID 190307~190309
-- 如果牛天仍在场，给血量最少的其他队友BUFF
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_sstianqingniumang01_zhenji_trigger1_1 = {
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
                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_init_buff_1"},
                        },
                        {
                            CLASS = "action.QSBTianQingNiuMangJianShang",
                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_buff_1",start_percent = 0.2,reduction_percent = 0.5,end_percent = 1.2}
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
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "pf_sstianqingniumang01_zhenji_buff_1"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {lowest_hp_teammate = true, just_hero = true, buff_id = {"pf_sstianqingniumang01_zhenji_start_buff","pf_sstianqingniumang01_zhenji_buff_1","pf_sstianqingniumang01_zhenji_init_buff_1"}},
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

return pf_sstianqingniumang01_zhenji_trigger1_1