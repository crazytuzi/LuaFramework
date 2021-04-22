-- 技能 象甲宗狂暴
-- 技能ID 50355
-- 狂暴 就是个施法通用,buff在skill表里加了
-- 新机制可能会用到这个脚本,所以预留
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_fall = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		},        
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					ARGS = {
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
							},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
	},
}

return boss_xiangjiazong_fall