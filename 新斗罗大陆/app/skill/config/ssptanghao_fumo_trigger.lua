-- 技能 唐昊觉醒位面锁定存满治疗触发
-- 技能ID 39132
-- 移除位面锁定BUFF
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_fumo_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuffByStatus",
            OPTIONS = {status = "ssptanghao_lock"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_fumo_trigger