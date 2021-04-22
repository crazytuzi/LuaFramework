-- 技能 盖世龙蛇气势抛投(击飞那下)
-- ID 239
-- 两下攻击,一下拍晕,一下击飞
--[[
	hero 盖世龙蛇
	ID:1022 
	psf 2018-6-28
]]--

local gaishilongshe_zidong1 = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		}, 
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
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
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 18/24},
                },
				{
                    CLASS = "action.QSBTriggerSkill",
					OPTIONS = { skill_id = 254,wait_finish = true},
                }, 
			},	
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 34/24},
                },
				{
                    CLASS = "action.QSBHitTarget",
                },
				{
					CLASS = "action.QSBArgsRandom",
					OPTIONS = {
						input = {
							datas = {
								"gaishilongshe_fangyu_debuff;y",
								"gaishilongshe_zhiliao_debuff;y"
							},
						},
						output = {output_type = "data"},
						args_translate = { select = "buff_id"}
					},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = true, no_cancel = true},
				},
			},	
		},
	},
}

return gaishilongshe_zidong1
