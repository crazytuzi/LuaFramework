-- 技能 盖世龙蛇气势抛投(拍打那下)
-- ID 254
-- 两下攻击,一下拍晕,一下击飞
--[[
	hero 盖世龙蛇
	ID:1022 
	psf 2018-6-28
]]--

local gaishilongshe_zidong1_trigger = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBHitTarget",
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return gaishilongshe_zidong1_trigger
