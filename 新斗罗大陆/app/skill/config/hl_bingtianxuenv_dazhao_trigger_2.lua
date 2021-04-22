-- 技能 冰天雪女大招触发冰冻
-- 技能ID 35061~65
-- 概率冰冻,冰锁BUFF提升概率
--[[
	hunling 冰天雪女
	ID:2007 
	psf 2019-6-10
]]--

local hl_bingtianxuenv_dazhao_trigger = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
				{expression = "self:random<(self:buff_num:hl_bingtianxuenv_pugong_debuff)*0.2+0.25", select = 1},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = { buff_id = "hl_bingtianxuenv_dazhao_debuff"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return hl_bingtianxuenv_dazhao_trigger