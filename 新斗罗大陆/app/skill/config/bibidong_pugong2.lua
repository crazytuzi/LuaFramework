-- 技能 比比东普攻2
-- 技能ID 390
-- 顾名思义 魔法
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_pugong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
					OPTIONS = {effect_id = "bibidong_attack02_1", is_hit_effect = false},
				},
            },
        },
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
			}
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "bibidong_attack02_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
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
							OPTIONS = {start_pos = {x = 175,y = 80}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",
									OPTIONS = {start_pos = {x = 175,y = 80}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 2},
								},
								{
									CLASS = "action.QSBBullet",
									OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",
									OPTIONS = {start_pos = {x = 175,y = 80}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 2},
								},
								{
									CLASS = "action.QSBBullet",
									OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
								},
								{
									CLASS = "action.QSBBullet",
									OPTIONS = {start_pos = {x = 175,y = 80}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
								},
							},
						},
					},
				},
            },
        },
    },
}

return bibidong_pugong2

