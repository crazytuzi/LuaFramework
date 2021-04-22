-- 技能 BOSS焱 X型火焰伤害
-- 技能ID 50371
-- boss 焱 ID:3287 副本9-4
-- lyl 2018-5-7

local zudui_boss_yan_crossfire_damage = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		},        
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		{    
		    CLASS = "composite.QSBParallel",
		    ARGS = {
				{
					CLASS = "action.QSBHitTarget",
				},
				{	
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff",is_target = true,no_cancel = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_l",is_target = true,no_cancel = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_r",is_target = true,no_cancel = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_b",is_target = true,no_cancel = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_huowushuang_crossfire_prompt",is_target = true,no_cancel = true},
				},
		    },
		},
		{    
		    CLASS = "composite.QSBParallel",
		    ARGS = {
		        {
		        	CLASS = "action.QSBRemoveBuff",
		        	OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff", is_target = false},
		        },
		        {
		        	CLASS = "action.QSBRemoveBuff",
		        	OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_l", is_target = false},
		        },		        
		        {
		        	CLASS = "action.QSBRemoveBuff",
		        	OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_r", is_target = false},
		        },
		        {
		        	CLASS = "action.QSBRemoveBuff",
		        	OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_b", is_target = false},
		        },
		        {
		        	CLASS = "action.QSBRemoveBuff",
		        	OPTIONS = {buff_id = "boss_huowushuang_crossfire_prompt", is_target = false},
		        },
		    },
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return zudui_boss_yan_crossfire_damage