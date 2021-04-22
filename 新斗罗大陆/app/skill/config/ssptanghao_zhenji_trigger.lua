-- 技能 唐昊真技清除强化
-- 技能ID 190385
-- (真技计数3次后触发) 清除真技的强化攻击BUFF
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_zhenji_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuffByStatus",
            OPTIONS = {status = "ssptanghao_zj"}
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_zhenji_trigger