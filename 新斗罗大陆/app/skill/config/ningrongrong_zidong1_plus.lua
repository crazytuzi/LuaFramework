-- 技能 宁荣荣 琉璃幻光 强化版
-- 技能ID 190115
-- 射出多发(1+5)随机子弹治疗队友(后五发必定治疗血最少的),第一发固定当前目标
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--

local ningrongrong_zidong1_plus = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningrongrong_attack13_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningrongrong_attack13_1_1", is_hit_effect = false},
                },
            },
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
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 32 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 37 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 42 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 47 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 52 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 57 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
    },
}

return ningrongrong_zidong1_plus
