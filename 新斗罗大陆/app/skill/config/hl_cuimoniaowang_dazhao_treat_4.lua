-- 技能 翠魔鸟王大招触发治疗
-- 技能ID 35102~06
-- 根据队友攻击伤害 对其治疗 并消耗图腾充能
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local hl_cuimoniaowang_dazhao_treat = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        -- {
			-- CLASS = "action.QSBPlayEffect",
			-- OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_3_1", is_hit_effect = true, haste = true},
		-- },
		-- {
			-- CLASS = "action.QSBPlayEffect",
			-- OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_3_2", is_hit_effect = true, haste = true},
		-- },
		{
			CLASS = "action.QSBApplyBuffMultiple",
			OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_treat_buff", target_type = "teammate"},
		},
		{
			CLASS = "action.QSBSetInheritedDamageBySavedTreat",
			OPTIONS = {buff_id = "hl_cuimoniaowang_buff_4" ,limite_attack_percent = 2.1},--单次治疗不超过魂灵攻击X%
		},
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_cuimoniaowang_dazhao_treat