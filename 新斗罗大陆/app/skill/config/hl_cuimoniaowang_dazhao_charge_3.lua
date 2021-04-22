-- 技能 翠魔鸟王大招触发充能
-- 技能ID 35107~11
-- 根据队友攻击伤害 对其治疗 并消耗图腾充能
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local hl_cuimoniaowang_dazhao_charge = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
			CLASS = "action.QSBSaveTreatByInheritedDamage",
			OPTIONS = {buff_id = "hl_cuimoniaowang_buff_3" ,limite_attack_percent = 1.8},--单次充能不超过魂灵攻击X%
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_cuimoniaowang_dazhao_charge