-- 技能 水冰儿暴风雪
-- 技能ID 50657
-- 召唤放置陷阱的NPC
--[[
	boss 水冰儿
	ID:3176 智慧试炼
	psf 2018-5-31
]]--

local boss_shuibinger_storm_wt = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "composite.QSBSequence",
			ARGS = { 
				{
					CLASS = "action.QSBPlayAnimation",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = false},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		}, 
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
			   
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.2},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "boss_shuibinger_baofengxue",is_hit_effect = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.15},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "boss_shuibinger_baofengxue",is_hit_effect = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.15},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "boss_shuibinger_baofengxue",is_hit_effect = true},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.3},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.3},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.3},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
							},
						},
					},
				},
			},
		},				
	},
}     

return boss_shuibinger_storm_wt