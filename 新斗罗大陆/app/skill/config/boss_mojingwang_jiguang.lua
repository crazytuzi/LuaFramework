-- 技能 激光
-- 技能ID 50878
-- 扑腾召小怪
--[[
	boss 魔鲸王
	ID:3699 3700
	psf 2018-7-19
]]--

local boss_mojingwang_jiguang =                                       
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBPlayLoopEffect",
					OPTIONS = {effect_id = "xiemohujingboss_jiguang_17_16", is_hit_effect = false, follow_actor_animation = true},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 100},
				},
				{
					CLASS = "action.QSBStopLoopEffect",
					 OPTIONS = {effect_id = "xiemohujingboss_jiguang_17_16"},
				},
			},
		},					
		{
			 CLASS = "composite.QSBSequence",
			 ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 80},
				},
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
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = false},
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

return boss_mojingwang_jiguang