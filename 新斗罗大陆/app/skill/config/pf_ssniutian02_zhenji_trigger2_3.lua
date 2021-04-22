-- 技能 牛天真技失传补救
-- 技能ID 190311
-- 补一个青龙守护
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_ssniutian02_zhenji_trigger2_3 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 3,
                {expression = "self:has_buff:pf_sstianqingniumang02_zhenji_niutian_buff_3", select = 2},
                {expression = "self:has_buff:pf_sstianqingniumang02_zhenji_niutian_buff_2", select = 1},
            }
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
                            OPTIONS = {buff_id = "pf_sstianqingniumang02_zhenji_niutian_buff_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"pf_sstianqingniumang02_zhenji_start_buff","pf_sstianqingniumang02_zhenji_buff_2_temp","pf_sstianqingniumang02_zhenji_init_buff_2"}},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "pf_sstianqingniumang02_zhenji_niutian_buff_3"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "pf_sstianqingniumang02_zhenji_niutian_buff_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"pf_sstianqingniumang02_zhenji_start_buff","pf_sstianqingniumang02_zhenji_buff_3","pf_sstianqingniumang02_zhenji_init_buff_3"}},
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

return pf_ssniutian02_zhenji_trigger2_3