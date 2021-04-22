-- 技能 鬼虎影袭
-- 范围五段AOE，期间自身隐藏
--[[
	boss 朱竹青
	ID:3306 副本3-16
	psf 2018-1-22
]]--

local boss_zhuzhuqing_yingxi = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		},        
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack15"},
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBManualMode",
							OPTIONS = {enter = true, revertable = true},
						},
						-- {
							-- CLASS = "action.QSBImmuneCharge",
							-- OPTIONS = {enter = true, revertable = true},
						-- },
						-- {
							-- CLASS = "action.QSBActorFadeOut",
							-- OPTIONS = {duration = 0.15, revertable = true},
						-- },
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 23},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						-- {
							-- CLASS = "action.QSBActorFadeIn",
							-- OPTIONS = {duration = 0.15, revertable = true},
						-- },
						{
							CLASS = "action.QSBImmuneCharge",
							OPTIONS = {enter = false},
						},
						{
							CLASS = "action.QSBManualMode",
							OPTIONS = {exit = true},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_zhuzhuqing_yingxi
