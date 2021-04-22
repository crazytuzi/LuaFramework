-- 技能 唐昊神技炸环伤害
-- 技能ID 39132
-- 打三次伤害
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_shenji_damage_trigger = {
	CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 8},
        },
        -- {
        --     CLASS = "action.QSBDecreaseHpByTargetProp",	
        --     OPTIONS = {attacker_attack_limit = 24,current_hp_percent = 0.16},
		-- },
		{
			CLASS = "action.QSBHitTarget",
			OPTIONS = {ignore_absorb_percent = 1},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 5},
        },
        {
			CLASS = "action.QSBHitTarget",
			OPTIONS = {ignore_absorb_percent = 1},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 5},
        },
        {
			CLASS = "action.QSBHitTarget",
			OPTIONS = {ignore_absorb_percent = 1},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_shenji_damage_trigger