-- 技能 盖世龙蛇 毒性皮肤 上毒
-- ID 253
-- 给最后攻击过自己的人上毒
--[[
	hero 盖世龙蛇
	ID:1022 
	psf 2018-6-28
]]--

local gaishilongshe_beidong2_trigger = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				input = {
					datas = {
						"gaishilongshe_gongji_debuff;y",
						"gaishilongshe_zhongdu_debuff;y"
					},
				},
				output = {output_type = "data"},
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

return gaishilongshe_beidong2_trigger
