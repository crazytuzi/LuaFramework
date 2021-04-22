-- 技能 月关 菊花怪死亡
-- ID 190078
-- 给我方月关一层yueguan_zhenji_buff1  
-- (先给所有队友yueguan_zhenji_trigger_debuff,如果月关有chenxin_zhenji_buff,会免疫该DEBUFF, 该DEBUFF免疫yueguan_zhenji_buff1)
--[[
	hero 月关
	ID:1018
	psf 2018-11-14
]]--
local yueguan_juhuaguai_dead = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {teammate = true, buff_id = "yueguan_zhenji_trigger_debuff"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {teammate = true, buff_id = "yueguan_zhenji_buff1"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{		
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true, status = "yueguan_berserk"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = 
					{
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBArgsRandom",
									OPTIONS = {
										input = {
											datas = {
												"yueguan_zhenji_buff1",
												"yueguan_zhenji_trigger_debuff",
											},
											formats = {1,4},
										},
										output = {output_type = "data"},
										args_translate = { select = "buff_id"}
									},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {teammate = true},
								},
							},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
	},
}

return yueguan_juhuaguai_dead 

