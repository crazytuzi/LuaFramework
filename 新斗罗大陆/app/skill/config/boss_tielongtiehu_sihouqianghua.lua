-- 技能 死后强化
-- 铁龙或铁虎死后使用，强化另一人
--[[
	boss 铁龙、铁虎
	副本3-4
	psf 2018-1-27
]]--

local boss_tielongtiehu_sihouqianghua = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_tielongtiehu_sihouqianghua