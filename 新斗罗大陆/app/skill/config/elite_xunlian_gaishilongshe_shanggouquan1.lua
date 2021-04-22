-- 技能 BOSS盖世龙蛇上勾拳(拍打那下)
-- ID 50415
-- 两下攻击,一下拉近(触发50415),一下击飞
--[[
	boss 盖世龙蛇
	ID:3246 副本2-4
	psf 2018-4-4
]]--

local elite_xunlian_gaishilongshe_shanggouquan1 = {
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

return elite_xunlian_gaishilongshe_shanggouquan1
