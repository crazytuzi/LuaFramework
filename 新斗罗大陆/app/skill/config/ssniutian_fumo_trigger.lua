-- 技能 牛天大招附魔触发切换BUFF
-- 技能ID 551
-- 附魔后切BUFF
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_dazhao_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 4,
                        {expression = "self:has_buff:ssniutian_fumo_buff2_1", select = 1},
                        {expression = "self:has_buff:ssniutian_fumo_buff2_2", select = 2},
                        {expression = "self:has_buff:ssniutian_fumo_buff2_3", select = 3},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "ssniutian_fumo_buff1_1"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "ssniutian_fumo_buff1_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "ssniutian_fumo_buff1_3"},
                        },
                    },
				},   
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "ssniutian_fumo2"},
				},         
            },
        },
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return ssniutian_dazhao_trigger

