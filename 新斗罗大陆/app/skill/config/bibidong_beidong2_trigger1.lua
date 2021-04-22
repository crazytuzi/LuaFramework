-- 技能 比比东支配噬魂单体攻击
-- 技能ID 402
-- 单体攻击
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_beidong2_trigger1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
			CLASS = "action.QSBArgsIsTeammate",
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						-- {
							-- CLASS = "action.QSBPlayEffect",
							-- OPTIONS = {effect_id = "bibidong_beidong2_3", is_hit_effect = true},
						-- },
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 30},
						},
						{
							CLASS = "action.QSBHitTarget",
							OPTIONS = {target_enemy_lowest_hp_percent = true},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_beidong2_3", is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 30},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_beidong2_trigger1

