-- 技能 金发狮獒大招群体BUFF
-- 技能ID 35038
-- 群体BUFF
--[[
	hunling 金发狮獒
	ID:2006
	psf 2019-6-14
]]--

local hl_jinfsa_dazhao_buff_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 4,
				{expression = "self:buff_num:hl_jinfsa_pugong_buff>3", select = 3},
				{expression = "self:buff_num:hl_jinfsa_pugong_buff>2", select = 2},
				{expression = "self:buff_num:hl_jinfsa_pugong_buff>1", select = 1},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_jinfsa_dazhao_buff;y"},
						},
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_jinfsa_dazhao_buff;y"},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {lowest_hp_teammate = true, buff_id = "hl_jinfsa_dazhao_buff;y"},
						},
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_jinfsa_dazhao_buff;y"},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {teammate_and_self = true, buff_id = "hl_jinfsa_dazhao_buff;y"},
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return hl_jinfsa_dazhao_buff_trigger