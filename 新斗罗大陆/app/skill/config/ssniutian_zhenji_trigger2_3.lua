-- 技能 牛天真技失传补救
-- 技能ID 190311
-- 补一个青龙守护
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_zhenji_trigger2_3 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 3,
                {expression = "self:has_buff:ssniutian_zhenji_niutian_buff_3", select = 2},
                {expression = "self:has_buff:ssniutian_zhenji_niutian_buff_2", select = 1},
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
                            OPTIONS = {buff_id = "ssniutian_zhenji_niutian_buff_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"ssniutian_zhenji_start_buff","ssniutian_zhenji_buff_2_temp","ssniutian_zhenji_init_buff_2"}},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "ssniutian_zhenji_niutian_buff_3"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "ssniutian_zhenji_niutian_buff_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"ssniutian_zhenji_start_buff","ssniutian_zhenji_buff_3","ssniutian_zhenji_init_buff_3"}},
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

return ssniutian_zhenji_trigger2_3