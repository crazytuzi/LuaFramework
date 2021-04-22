-- 技能 暴龙之王斩杀
-- 技能ID 53325
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_zhansha = 
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = true},
		},
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
				{ "self:hp>0","self:increase_hp:self:maxHp*0.1","under_status"},
			}
		},
		-- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "shenglt_baolongzhiwang_podan_debuff",all_enemy = true},
		-- },
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "shenglt_baolongzhiwang_hunt_buff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "shenglt_baolongzhiwang_hungry_debuff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "shenglt_baolongzhiwang_carrion_debuff",remove_all_same_buff_id = true},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}
return shenglt_baolongzhiwang_zhansha