-- 技能 比比东真技
-- 技能ID 190259
-- 蜘蛛追踪
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zhenji_damage =
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "animation", is_loop = true, is_keep_animation = true},
		},
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {is_keep_animation = true}
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 60},
				},
				{
					CLASS = "action.QSBActorFadeOut",
					OPTIONS = {duration = 0.01, revertable = true},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_zhenji1_3", is_hit_effect = false},
						},
					},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 31},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
				{
					CLASS = "action.QSBSuicide", 
				},
			},
		},
		-- {
			-- CLASS = "action.QSBChargeToTarget",
			-- OPTIONS = {is_position = true,scale_actor_face = 1, speed = 350},
		-- },
	},
}

return bibidong_zhenji_damage