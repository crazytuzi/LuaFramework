-- 技能 比比东大招 死亡蛛皇
-- 技能ID 392
-- 物理单段群攻
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_dazhao_trigger1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		{
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="bibidong_skill_1"},
        },
		{
            CLASS = "action.QSBPlayStrokesAnimation",
        },
		{
			CLASS = "action.QSBUncancellable",
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "bibidong_cz_zihuan", is_hit_effect = false},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 77},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack11_1_1a", is_hit_effect = false},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 58},
                },
                {
					CLASS = "composite.QSBParallel",
					ARGS = {
						-- {
						-- 	CLASS = "action.QSBPlayEffect",
						-- 	OPTIONS = {effect_id = "bibidong_attack11_1_2a", is_hit_effect = false},
						-- },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_attack11_1_3a", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_attack11_3a", is_hit_effect = true},
						},
						{
							CLASS = "action.QSBShakeScreen",
							OPTIONS = {amplitude = 20, duration = 0.25, count = 2,},
						},
					},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 62},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "bibidong_dazhao_siwang"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "bibidong_hetiji_siwang"},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "bibidong_shihun_element"},
						},
						{
							CLASS = "action.QSBHitTarget",
							OPTIONS = {property_promotion = { critical_chance = 0.25,critical_damage = 0.25 }},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "bibidong_dazhao_shihun"},
						},
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem1"},
						-- },
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem2"},
						-- },
						-- {
							-- CLASS = "action.QSBApplyBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem3"},
						-- },
					},
				},
            },
        },
    },
}

return bibidong_dazhao_trigger1

