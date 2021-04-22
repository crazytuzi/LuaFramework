-- 技能 牛天大招计数
-- 技能ID 549
-- 根据场上队友数量触发，每有一个队友给自己一个计数
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_dazhao_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true, status = "ssniutian_dazhao"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "action.QSBHitTarget",	
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "ssniutian_dazhao_teammate_buff"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssniutian_dazhao_trigger

