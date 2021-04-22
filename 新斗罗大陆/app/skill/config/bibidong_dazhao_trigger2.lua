-- 技能 比比东大招 噬魂蛛皇
-- 技能ID 393
-- 魔法多段单攻
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_dazhao_trigger2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="bibidong_skill_2"},
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
			OPTIONS = {effect_id = "bibidong_cz_huanghuan", is_hit_effect = false},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 75},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "bibidong_dazhao_shihun"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "bibidong_hetiji_shihun"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "bibidong_shihun_element"},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "bibidong_dazhao_siwang"},
						},
						-- {
							-- CLASS = "action.QSBRemoveBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem1"},
						-- },
						-- {
							-- CLASS = "action.QSBRemoveBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem2"},
						-- },
						-- {
							-- CLASS = "action.QSBRemoveBuff",
							-- OPTIONS = {buff_id = "bibidong_shihun_gem3"},
						-- },
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 7},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack11_1_1b", is_hit_effect = false},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack11_3b", is_hit_effect = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_attack11_1_2b", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "bibidong_attack11_1_3b", is_hit_effect = false},
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
                    OPTIONS = {delay_frame = 57},
                },
                {
					CLASS = "action.QSBBullet",	
					OPTIONS = {
						effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
						shake = {amplitude = 10, duration = 0.10, count = 1},damage_scale = 0.9,
					}
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
					CLASS = "action.QSBBullet",	
					OPTIONS = {
						effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
						shake = {amplitude = 10, duration = 0.12, count = 1},damage_scale = 1,
					}
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
					CLASS = "action.QSBBullet",	
					OPTIONS = {
						effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
						shake = {amplitude = 12, duration = 0.15, count = 1},damage_scale = 1.1,
					}
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
					CLASS = "action.QSBBullet",	
					OPTIONS = {
						effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
						shake = {amplitude = 15, duration = 0.17, count = 1},damage_scale = 1.25,
					}
				},
            },
        },
		--真技
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 62},
                },
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 4,
						{expression = "self:buff_num:bibidong_zhenji_plus_buff=1", select = 1},
						{expression = "self:buff_num:bibidong_zhenji_plus_buff=2", select = 2},
						{expression = "self:buff_num:bibidong_zhenji_plus_buff=3", select = 3},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {
								effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
								shake = {amplitude = 5, duration = 0.07, count = 1},
							}
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {
										effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
										shake = {amplitude = 5, duration = 0.07, count = 1},
									}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 1},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {
										effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
										shake = {amplitude = 7, duration = 0.07, count = 1},
									}
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {
										effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
										shake = {amplitude = 5, duration = 0.07, count = 1},
									}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 1},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {
										effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
										shake = {amplitude = 7, duration = 0.07, count = 1},
									}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 1},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {
										effect_id = "tmzd_2", speed = 9999, hit_effect_id = "bibidong_attack14_3",
										shake = {amplitude = 10, duration = 0.07, count = 1},
									}
								},
							},
						},
					},
				},
            },
        },
    },
}

return bibidong_dazhao_trigger2

