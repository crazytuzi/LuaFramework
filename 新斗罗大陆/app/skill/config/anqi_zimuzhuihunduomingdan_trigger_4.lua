-- 技能 暗器 子母追魂夺命胆触发技
-- ID 40146
-- 随机触发子胆或母胆技能
--[[
	暗器 字母追魂夺命胆
	ID:1514 
	psf 2018-8-17
]]--


local anqi_zimuzhuihunduomingdan_trigger_4 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				info = {count = 1},
				input = {
					datas = {40139,40144},
					formats = {2,1},
				},
				output = {output_type = "data"},
				args_translate = { select = "skill_id"}
			},
		},
		{
			CLASS = "action.QSBTriggerSkill",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_zimuzhuihunduomingdan_trigger_4
