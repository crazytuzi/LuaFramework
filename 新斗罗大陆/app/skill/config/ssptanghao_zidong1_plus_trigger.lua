-- 技能 唐昊自动1真技强化触发
-- 技能ID 190384
-- 给目标及其周围敌方上BUFF
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_zidong1_plus_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_zidong1_plus_trigger