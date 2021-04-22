-- 技能 千仞雪附魔触发晕眩
-- 技能ID 180107
-- 打伤害
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_dazhao_trigger_fumo = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		-- {
			-- CLASS = "action.QSBHitTarget",
		-- },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "1s_stun",no_cancel = true},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qianrenxue_dazhao_trigger_fumo