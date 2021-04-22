-- 技能 象甲宗缠绕陷阱绊倒
-- 技能ID (已弃用)
-- 目前没用,用别的机制实现可能会用到,预留
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_trapsetter_stumble = {
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

return boss_xiangjiazong_trapsetter_stumble