-- 技能 BOSS比比东 践踏
-- 技能ID 50831
-- 变身踩一脚
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_jianta = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
            CLASS = "action.QSBPlaySound"
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.4},
				},
                {
					CLASS = "action.QSBTrap", 
					OPTIONS = 
					{ 
						trapId = "zhaowujitiaoyue_hongquan",
						args = 
						{
							{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
						},
					},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2.4},
				},
                {
                    CLASS = "action.QSBShakeScreen",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },       
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack15_1", is_hit_effect = false},
				},												
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack15_1_1b", is_hit_effect = false},
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
							CLASS = "action.QSBHitTarget",
						},									
					},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_bibidong_jianta_buff",no_cancel = true},
				},				
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack15",no_stand = true},
				},					
				-- {
				-- 	CLASS = "action.QSBApplyBuff",
				-- 	OPTIONS = {buff_id = "boss_mohuabibidong_bianshen_3682_buff"},
				-- },
				-- {
		  --           CLASS = "composite.QSBSequence",
		  --           ARGS = 
		  --           {
		  --               {
				-- 			CLASS = "action.QSBDelayTime",
				-- 			OPTIONS = {delay_time = 44},
				-- 		},
		                {
		                    CLASS = "action.QSBAttackFinish",
		                },
		        --     },
		        -- },
                
            },
        },
    },
}

return boss_bibidong_jianta