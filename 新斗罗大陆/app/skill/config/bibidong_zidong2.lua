-- 技能 比比东自动2
-- 技能ID 397
-- 射很多
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
			}
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack14_1_2", is_hit_effect = false},
				},				
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack14_1_4", is_hit_effect = false},
				},
            },
        },
		-- {
  --           CLASS = "composite.QSBSequence",
  --           ARGS = {
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 20},
  --               },
  --               {
		-- 			CLASS = "action.QSBPlayEffect",
		-- 			OPTIONS = {effect_id = "bibidong_attack14_1_1", is_hit_effect = false},
		-- 		},
  --           },
  --       },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack14_1_3", is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
				{
					CLASS = "action.QSBBullet",	
					OPTIONS = {start_pos = {x = 175,y = 80}}
				},
				{
					CLASS = "action.QSBBullet",	
					OPTIONS = {start_pos = {x = 185,y = 85},target_random = true}
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",	
					OPTIONS = {start_pos = {x = 175,y = 75},target_random = true}
				},
            },
        },
		--噬魂
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true, status = "bibidong_shihun",},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 175,y = 75},target_random = true}
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85},target_random = true}
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 175,y = 75},target_random = true}
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuffMultiple",	
									OPTIONS = {target_type = "teammate",buff_id = "bibidong_immune_zidong2_debuff"}
								},
								{
									CLASS = "action.QSBApplyBuffMultiple",	
									OPTIONS = {target_type = "teammate",buff_id = "bibidong_zidong2_buff;y"}
								},
							},
						},
					},
				},
            },
        },
		--真技分身
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 44},
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
							OPTIONS = {start_pos = {x = 185,y = 85}}
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85}}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 2},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85}}
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85}}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 1},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85}}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 1},
								},
								{
									CLASS = "action.QSBBullet",	
									OPTIONS = {start_pos = {x = 185,y = 85}}
								},
							},
						},
					},
				},
            },
		},
		--真技回怒
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
				{
                    CLASS = "action.QSBAttackFinish",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
					CLASS = "action.QSBAttackByBuffNum",
					OPTIONS = {buff_id = "bibidong_zidong2_debuff", trigger_skill_id = 190256, skill_level = 1,target_type = "enemy"},
				},
            },
        },
		
    },
}

return bibidong_zidong2

