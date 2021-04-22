-- 技能 盖世龙蛇 大招随机上BUFF
-- ID 243
-- 大招AOE触发该技能
--[[
	hero 盖世龙蛇
	ID:1022 
	psf 2018-6-28
]]--


local gaishilongshe_dazhao_trigger = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				info = {count = 2},
				input = {
					datas = {
						"gaishilongshe_dazhao_fangyu_debuff;y",
						"gaishilongshe_dazhao_gongji_debuff;y",
						"gaishilongshe_dazhao_zhongdu_debuff;y",
						"gaishilongshe_dazhao_zhiliao_debuff",
					},
					formats = {
						{weight = 1,replace_interval = 3}--必然2个BUFF
					},
				},
				output = {output_type = "table"},
				args_translate = { select = "buff_id"}
			},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {no_cancel = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return gaishilongshe_dazhao_trigger
